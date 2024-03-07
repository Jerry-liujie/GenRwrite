```sql
with cs_ui as (
    select
        cs_item_sk,
        sum(cs_ext_list_price) as sale,
        sum(
            cr_refunded_cash + cr_reversed_charge + cr_store_credit
        ) as refund
    from
        catalog_sales
    join catalog_returns
    on cs_item_sk = cr_item_sk
        and cs_order_number = cr_order_number
    group by
        cs_item_sk
    having
        sum(cs_ext_list_price) > 2 * sum(
            cr_refunded_cash + cr_reversed_charge + cr_store_credit
        )
)
select
    cs1.product_name,
    cs1.store_name,
    cs1.store_zip,
    cs1.b_street_number,
    cs1.b_street_name,
    cs1.b_city,
    cs1.b_zip,
    cs1.c_street_number,
    cs1.c_street_name,
    cs1.c_city,
    cs1.c_zip,
    cs1.syear,
    cs1.cnt,
    cs1.s1 as s11,
    cs1.s2 as s21,
    cs1.s3 as s31,
    cs2.s1 as s12,
    cs2.s2 as s22,
    cs2.s3 as s32,
    cs2.syear,
    cs2.cnt
from
    cross_sales cs1
join cross_sales cs2
on cs1.item_sk = cs2.item_sk
    and cs1.store_name = cs2.store_name
    and cs1.store_zip = cs2.store_zip
where
    cs1.syear = 1999
    and cs2.syear = 1999 + 1
    and cs2.cnt <= cs1.cnt
order by
    cs1.product_name,
    cs1.store_name,
    cs2.cnt,
    cs1.s1,
    cs2.s1;
```