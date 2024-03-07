```sql
with wscs as (
    select
        d_week_seq,
        sum(case when (d_day_name = 'Sunday') then sales_price else null end) sun_sales,
        sum(case when (d_day_name = 'Monday') then sales_price else null end) mon_sales,
        sum(case when (d_day_name = 'Tuesday') then sales_price else null end) tue_sales,
        sum(case when (d_day_name = 'Wednesday') then sales_price else null end) wed_sales,
        sum(case when (d_day_name = 'Thursday') then sales_price else null end) thu_sales,
        sum(case when (d_day_name = 'Friday') then sales_price else null end) fri_sales,
        sum(case when (d_day_name = 'Saturday') then sales_price else null end) sat_sales
    from
        (
            select
                ws_sold_date_sk sold_date_sk,
                ws_ext_sales_price sales_price
            from
                web_sales
            union all
            select
                cs_sold_date_sk sold_date_sk,
                cs_ext_sales_price sales_price
            from
                catalog_sales
        ) as tmp
    join date_dim on date_dim.d_date_sk = tmp.sold_date_sk
    group by
        d_week_seq
),
y as (
    select * from wscs where d_year = 1998
),
z as (
    select * from wscs where d_year = 1998 + 1
)
select
    y.d_week_seq,
    round(y.sun_sales / z.sun_sales, 2),
    round(y.mon_sales / z.mon_sales, 2),
    round(y.tue_sales / z.tue_sales, 2),
    round(y.wed_sales / z.wed_sales, 2),
    round(y.thu_sales / z.thu_sales, 2),
    round(y.fri_sales / z.fri_sales, 2),
    round(y.sat_sales / z.sat_sales, 2)
from
    y
join z on y.d_week_seq = z.d_week_seq - 53
order by
    y.d_week_seq;
```