```
with am_sales as (
    select
        count(*) as amc
    from
        web_sales
    join time_dim on ws_sold_time_sk = time_dim.t_time_sk
    join household_demographics on ws_ship_hdemo_sk = household_demographics.hd_demo_sk
    join web_page on ws_web_page_sk = web_page.wp_web_page_sk
    where
        time_dim.t_hour between 12 and 13
        and household_demographics.hd_dep_count = 6
        and web_page.wp_char_count between 5000 and 5200
),
pm_sales as (
    select
        count(*) as pmc
    from
        web_sales
    join time_dim on ws_sold_time_sk = time_dim.t_time_sk
    join household_demographics on ws_ship_hdemo_sk = household_demographics.hd_demo_sk
    join web_page on ws_web_page_sk = web_page.wp_web_page_sk
    where
        time_dim.t_hour between 14 and 15
        and household_demographics.hd_dep_count = 6
        and web_page.wp_char_count between 5000 and 5200
)
select
    cast(amc as decimal(15, 4)) / cast(pmc as decimal(15, 4)) as am_pm_ratio
from
    am_sales,
    pm_sales
order by
    am_pm_ratio
limit
    100;
```