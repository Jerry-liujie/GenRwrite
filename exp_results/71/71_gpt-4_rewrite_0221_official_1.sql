```
with sales as (
    select
        ws_ext_sales_price as ext_price,
        ws_sold_date_sk as sold_date_sk,
        ws_item_sk as sold_item_sk,
        ws_sold_time_sk as time_sk
    from
        web_sales
    where
        ws_sold_date_sk in (select d_date_sk from date_dim where d_moy = 12 and d_year = 2002)
    union all
    select
        cs_ext_sales_price as ext_price,
        cs_sold_date_sk as sold_date_sk,
        cs_item_sk as sold_item_sk,
        cs_sold_time_sk as time_sk
    from
        catalog_sales
    where
        cs_sold_date_sk in (select d_date_sk from date_dim where d_moy = 12 and d_year = 2002)
    union all
    select
        ss_ext_sales_price as ext_price,
        ss_sold_date_sk as sold_date_sk,
        ss_item_sk as sold_item_sk,
        ss_sold_time_sk as time_sk
    from
        store_sales
    where
        ss_sold_date_sk in (select d_date_sk from date_dim where d_moy = 12 and d_year = 2002)
)
select
    i_brand_id brand_id,
    i_brand brand,
    t_hour,
    t_minute,
    sum(ext_price) ext_price
from
    item
join
    sales on sales.sold_item_sk = item.i_item_sk
join
    time_dim on sales.time_sk = time_dim.t_time_sk
where
    item.i_manager_id = 1
    and (time_dim.t_meal_time = 'breakfast' or time_dim.t_meal_time = 'dinner')
group by
    i_brand,
    i_brand_id,
    t_hour,
    t_minute
order by
    ext_price desc,
    i_brand_id;
```