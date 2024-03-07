```
with store_sales_total as (
    select c_customer_id as customer_id, c_first_name as customer_first_name, c_last_name as customer_last_name, d_year as year, max(ss_net_paid) as year_total
    from customer, store_sales, date_dim
    where c_customer_sk = ss_customer_sk and ss_sold_date_sk = d_date_sk and d_year in (1999, 2000)
    group by c_customer_id, c_first_name, c_last_name, d_year
),
web_sales_total as (
    select c_customer_id as customer_id, c_first_name as customer_first_name, c_last_name as customer_last_name, d_year as year, max(ws_net_paid) as year_total
    from customer, web_sales, date_dim
    where c_customer_sk = ws_bill_customer_sk and ws_sold_date_sk = d_date_sk and d_year in (1999, 2000)
    group by c_customer_id, c_first_name, c_last_name, d_year
)
select s2.customer_id, s2.customer_first_name, s2.customer_last_name
from store_sales_total s1
join store_sales_total s2 on s1.customer_id = s2.customer_id and s1.year = 1999 and s2.year = 2000 and s1.year_total > 0 and s2.year_total > s1.year_total
join web_sales_total w1 on s1.customer_id = w1.customer_id and w1.year = 1999 and w1.year_total > 0
join web_sales_total w2 on s1.customer_id = w2.customer_id and w2.year = 2000 and w2.year_total > w1.year_total
where w2.year_total / w1.year_total > s2.year_total / s1.year_total
order by 1,3,2 limit 100;
```