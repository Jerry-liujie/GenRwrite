```
select
    i_item_id,
    i_item_desc,
    s_store_id,
    s_store_name,
    max(ss_quantity) as store_sales_quantity,
    max(sr_return_quantity) as store_returns_quantity,
    max(cs_quantity) as catalog_sales_quantity
from
    (select ss_item_sk, ss_store_sk, ss_customer_sk, ss_quantity, ss_ticket_number from store_sales join date_dim on d_date_sk = ss_sold_date_sk where d_moy = 4 and d_year = 1998) as ss
    join
    (select sr_item_sk, sr_customer_sk, sr_return_quantity, sr_ticket_number from store_returns join date_dim on d_date_sk = sr_returned_date_sk where d_moy between 4 and 7 and d_year = 1998) as sr
    on ss.ss_customer_sk = sr.sr_customer_sk and ss.ss_item_sk = sr.sr_item_sk and ss.ss_ticket_number = sr.sr_ticket_number
    join
    (select cs_item_sk, cs_bill_customer_sk, cs_quantity from catalog_sales join date_dim on d_date_sk = cs_sold_date_sk where d_year in (1998, 1999, 2000)) as cs
    on sr.sr_customer_sk = cs.cs_bill_customer_sk and sr.sr_item_sk = cs.cs_item_sk
    join store on s_store_sk = ss.ss_store_sk
    join item on i_item_sk = ss.ss_item_sk
group by
    i_item_id,
    i_item_desc,
    s_store_id,
    s_store_name
order by
    i_item_id,
    i_item_desc,
    s_store_id,
    s_store_name
limit
    100;
```