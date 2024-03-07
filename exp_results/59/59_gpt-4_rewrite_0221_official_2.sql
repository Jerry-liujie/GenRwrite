with wss as (
    select
        d_week_seq,
        ss_store_sk,
        sum(case when (d_day_name = 'Sunday') then ss_sales_price else 0 end) sun_sales,
        sum(case when (d_day_name = 'Monday') then ss_sales_price else 0 end) mon_sales,
        sum(case when (d_day_name = 'Tuesday') then ss_sales_price else 0 end) tue_sales,
        sum(case when (d_day_name = 'Wednesday') then ss_sales_price else 0 end) wed_sales,
        sum(case when (d_day_name = 'Thursday') then ss_sales_price else 0 end) thu_sales,
        sum(case when (d_day_name = 'Friday') then ss_sales_price else 0 end) fri_sales,
        sum(case when (d_day_name = 'Saturday') then ss_sales_price else 0 end) sat_sales
    from
        store_sales
    join date_dim on d_date_sk = ss_sold_date_sk
    group by
        d_week_seq,
        ss_store_sk
)
select
    s_store_name,
    s_store_id,
    d_week_seq,
    sun_sales / lag(sun_sales) over (partition by s_store_id order by d_week_seq),
    mon_sales / lag(mon_sales) over (partition by s_store_id order by d_week_seq),
    tue_sales / lag(tue_sales) over (partition by s_store_id order by d_week_seq),
    wed_sales / lag(wed_sales) over (partition by s_store_id order by d_week_seq),
    thu_sales / lag(thu_sales) over (partition by s_store_id order by d_week_seq),
    fri_sales / lag(fri_sales) over (partition by s_store_id order by d_week_seq),
    sat_sales / lag(sat_sales) over (partition by s_store_id order by d_week_seq)
from
    wss
join store on ss_store_sk = s_store_sk
order by
    s_store_name,
    s_store_id,
    d_week_seq
limit 100;