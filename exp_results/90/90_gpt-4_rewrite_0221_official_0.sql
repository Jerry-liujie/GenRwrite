```sql
select
    cast(sum(case when t_hour between 12 and 12 + 1 then 1 else 0 end) as decimal(15, 4)) / 
    cast(sum(case when t_hour between 14 and 14 + 1 then 1 else 0 end) as decimal(15, 4)) as am_pm_ratio
from
    web_sales
join
    household_demographics
on
    ws_ship_hdemo_sk = hd_demo_sk
join
    time_dim
on
    ws_sold_time_sk = t_time_sk
join
    web_page
on
    ws_web_page_sk = wp_web_page_sk
where
    hd_dep_count = 6
    and wp_char_count between 5000 and 5200
order by
    am_pm_ratio
limit
    100;
```