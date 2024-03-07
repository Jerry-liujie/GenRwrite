```sql
with item_ids as (
    select
        i_item_id
    from
        item
    where
        i_color in ('powder', 'orchid', 'pink')
),
sales as (
    select
        i_item_id,
        sum(ss_ext_sales_price) as total_sales
    from
        store_sales
    join item_ids on ss_item_sk = i_item_id
    join date_dim on ss_sold_date_sk = d_date_sk and d_year = 2000 and d_moy = 3
    join customer_address on ss_addr_sk = ca_address_sk and ca_gmt_offset = -6
    union all
    select
        i_item_id,
        sum(cs_ext_sales_price) as total_sales
    from
        catalog_sales
    join item_ids on cs_item_sk = i_item_id
    join date_dim on cs_sold_date_sk = d_date_sk and d_year = 2000 and d_moy = 3
    join customer_address on cs_bill_addr_sk = ca_address_sk and ca_gmt_offset = -6
    union all
    select
        i_item_id,
        sum(ws_ext_sales_price) as total_sales
    from
        web_sales
    join item_ids on ws_item_sk = i_item_id
    join date_dim on ws_sold_date_sk = d_date_sk and d_year = 2000 and d_moy = 3
    join customer_address on ws_bill_addr_sk = ca_address_sk and ca_gmt_offset = -6
)
select
    i_item_id,
    sum(total_sales) total_sales
from
    sales
group by
    i_item_id
order by
    total_sales,
    i_item_id
limit
    100;
```