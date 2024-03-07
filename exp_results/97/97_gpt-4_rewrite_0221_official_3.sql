```sql
with ssci as (
    select
        ss_customer_sk customer_sk,
        ss_item_sk item_sk
    from
        store_sales
    join date_dim on ss_sold_date_sk = d_date_sk
    where
        d_month_seq between 1199 and 1199 + 11
    group by
        ss_customer_sk,
        ss_item_sk
),
csci as(
    select
        cs_bill_customer_sk customer_sk,
        cs_item_sk item_sk
    from
        catalog_sales
    join date_dim on cs_sold_date_sk = d_date_sk
    where
        d_month_seq between 1199 and 1199 + 11
    group by
        cs_bill_customer_sk,
        cs_item_sk
)
select
    count(distinct ssci.customer_sk) - count(distinct csci.customer_sk) as store_only,
    count(distinct csci.customer_sk) - count(distinct ssci.customer_sk) as catalog_only,
    count(distinct ssci.customer_sk) + count(distinct csci.customer_sk) - count(distinct ssci.customer_sk, ssci.item_sk, csci.customer_sk, csci.item_sk) as store_and_catalog
from
    ssci
full outer join
    csci on ssci.customer_sk = csci.customer_sk and ssci.item_sk = csci.item_sk
limit 100;
```