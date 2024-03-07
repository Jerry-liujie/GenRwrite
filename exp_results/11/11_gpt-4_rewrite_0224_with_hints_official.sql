```
with store_sales_total as (
  select 
    c_customer_id as customer_id,
    c_first_name as customer_first_name,
    c_last_name as customer_last_name,
    c_email_address as customer_email_address,
    d_year as dyear,
    sum(ss_ext_list_price-ss_ext_discount_amt) as year_total
  from 
    customer,
    store_sales,
    date_dim
  where 
    c_customer_sk = ss_customer_sk 
    and ss_sold_date_sk = d_date_sk 
  group by 
    c_customer_id,
    c_first_name,
    c_last_name,
    c_email_address,
    d_year
),
web_sales_total as (
  select 
    c_customer_id as customer_id,
    c_first_name as customer_first_name,
    c_last_name as customer_last_name,
    c_email_address as customer_email_address,
    d_year as dyear,
    sum(ws_ext_list_price-ws_ext_discount_amt) as year_total
  from 
    customer,
    web_sales,
    date_dim
  where 
    c_customer_sk = ws_bill_customer_sk 
    and ws_sold_date_sk = d_date_sk 
  group by 
    c_customer_id,
    c_first_name,
    c_last_name,
    c_email_address,
    d_year
)
select 
  s.customer_id,
  s.customer_first_name,
  s.customer_last_name,
  s.customer_email_address
from 
  store_sales_total s
join 
  web_sales_total w 
on 
  s.customer_id = w.customer_id 
  and s.dyear = w.dyear
where 
  s.dyear = 1998 
  and w.year_total > s.year_total 
  and s.year_total > 0 
  and w.year_total > 0
order by 
  s.customer_id,
  s.customer_first_name,
  s.customer_last_name,
  s.customer_email_address
limit 100;
```