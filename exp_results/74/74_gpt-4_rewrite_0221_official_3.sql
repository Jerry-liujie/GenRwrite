```sql
with store_sales_total as (
    select
        c_customer_id as customer_id,
        c_first_name as customer_first_name,
        c_last_name as customer_last_name,
        d_year as year,
        max(ss_net_paid) as year_total
    from
        customer
    join store_sales on c_customer_sk = ss_customer_sk
    join date_dim on ss_sold_date_sk = d_date_sk
    where
        d_year in (1999, 2000)
    group by
        c_customer_id,
        c_first_name,
        c_last_name,
        d_year
),
web_sales_total as (
    select
        c_customer_id as customer_id,
        c_first_name as customer_first_name,
        c_last_name as customer_last_name,
        d_year as year,
        max(ws_net_paid) as year_total
    from
        customer
    join web_sales on c_customer_sk = ws_bill_customer_sk
    join date_dim on ws_sold_date_sk = d_date_sk
    where
        d_year in (1999, 2000)
    group by
        c_customer_id,
        c_first_name,
        c_last_name,
        d_year
)
select
    sst.customer_id,
    sst.customer_first_name,
    sst.customer_last_name
from
    store_sales_total sst
join web_sales_total wst on sst.customer_id = wst.customer_id
where
    sst.year = 1999
    and wst.year = 2000
    and sst.year_total > 0
    and wst.year_total > 0
    and (wst.year_total / sst.year_total) > 1
order by
    sst.customer_id,
    sst.customer_last_name,
    sst.customer_first_name
limit
    100;
```