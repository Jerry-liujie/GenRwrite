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
),
cross_sales as (
    select
        i_product_name product_name,
        i_item_sk item_sk,
        s_store_name store_name,
        s_zip store_zip,
        ad1.ca_street_number b_street_number,
        ad1.ca_street_name b_street_name,
        ad1.ca_city b_city,
        ad1.ca_zip b_zip,
        ad2.ca_street_number c_street_number,
        ad2.ca_street_name c_street_name,
        ad2.ca_city c_city,
        ad2.ca_zip c_zip,
        d1.d_year as syear,
        count(*) cnt,
        sum(ss_wholesale_cost) s1,
        sum(ss_list_price) s2,
        sum(ss_coupon_amt) s3
    FROM
        store_sales
    join store_returns
        on ss_item_sk = sr_item_sk
        and ss_ticket_number = sr_ticket_number
    join cs_ui
        on ss_item_sk = cs_ui.cs_item_sk
    join store
        on ss_store_sk = s_store_sk
    join customer
        on ss_customer_sk = c_customer_sk
    join customer_demographics cd1
        on ss_cdemo_sk = cd1.cd_demo_sk
    join household_demographics hd1
        on ss_hdemo_sk = hd1.hd_demo_sk
    join customer_address ad1
        on ss_addr_sk = ad1.ca_address_sk
    join item
        on ss_item_sk = i_item_sk
    where
        c_current_cdemo_sk = cd1.cd_demo_sk
        AND c_current_hdemo_sk = hd1.hd_demo_sk
        AND c_current_addr_sk = ad1.ca_address_sk
        and i_color in ('orange', 'lace', 'lawn', 'misty', 'blush', 'pink')
        and i_current_price between 48 and 63
    group by
        i_product_name,
        i_item_sk,
        s_store_name,
        s_zip,
        ad1.ca_street_number,
        ad1.ca_street_name,
        ad1.ca_city,
        ad1.ca_zip,
        ad2.ca_street_number,
        ad2.ca_street_name,
        ad2.ca_city,
        ad2.ca_zip,
        d1.d_year
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
    and cs2.syear = 2000
    and cs2.cnt <= cs1.cnt
order by
    cs1.product_name,
    cs1.store_name,
    cs2.cnt,
    cs1.s1,
    cs2.s1;
```