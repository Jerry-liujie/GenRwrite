```sql
with store_sales_total as (
    select
        c_customer_id,
        sum(ss_ext_list_price - ss_ext_discount_amt) year_total
    from
        customer
    join store_sales on c_customer_sk = ss_customer_sk
    join date_dim on ss_sold_date_sk = d_date_sk
    where
        d_year in (1998, 1999)
    group by
        c_customer_id,
        d_year
),
web_sales_total as (
    select
        c_customer_id,
        sum(ws_ext_list_price - ws_ext_discount_amt) year_total
    from
        customer
    join web_sales on c_customer_sk = ws_bill_customer_sk
    join date_dim on ws_sold_date_sk = d_date_sk
    where
        d_year in (1998, 1999)
    group by
        c_customer_id,
        d_year
)
select
    c_customer_id,
    c_first_name,
    c_last_name,
    c_email_address
from
    customer
join store_sales_total sst1 on customer.c_customer_id = sst1.c_customer_id
join store_sales_total sst2 on customer.c_customer_id = sst2.c_customer_id
join web_sales_total wst1 on customer.c_customer_id = wst1.c_customer_id
join web_sales_total wst2 on customer.c_customer_id = wst2.c_customer_id
where
    sst1.d_year = 1998
    and sst2.d_year = 1999
    and wst1.d_year = 1998
    and wst2.d_year = 1999
    and sst1.year_total > 0
    and wst1.year_total > 0
    and (wst2.year_total / wst1.year_total) > (sst2.year_total / sst1.year_total)
order by
    c_customer_id,
    c_first_name,
    c_last_name,
    c_email_address
limit
    100;
```