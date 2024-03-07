```
with combined_sales as (
    select
        ss_customer_sk as customer_sk,
        ss_item_sk as item_sk,
        'store' as sale_type
    from
        store_sales
    join date_dim on ss_sold_date_sk = d_date_sk and d_month_seq between 1199 and 1199 + 11
    union all
    select
        cs_bill_customer_sk as customer_sk,
        cs_item_sk as item_sk,
        'catalog' as sale_type
    from
        catalog_sales
    join date_dim on cs_sold_date_sk = d_date_sk and d_month_seq between 1199 and 1199 + 11
)
select
    count(distinct case when sale_type = 'store' then customer_sk end) as store_only,
    count(distinct case when sale_type = 'catalog' then customer_sk end) as catalog_only,
    count(distinct case when sale_type = 'store' and sale_type = 'catalog' then customer_sk end) as store_and_catalog
from
    combined_sales
limit 100;
```