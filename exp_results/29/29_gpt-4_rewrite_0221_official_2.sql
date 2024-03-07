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
    (
    select
        ss_item_sk,
        ss_store_sk,
        ss_customer_sk,
        ss_quantity,
        sr_return_quantity,
        cs_quantity
    from
        store_sales
    join store_returns on ss_customer_sk = sr_customer_sk and ss_item_sk = sr_item_sk and ss_ticket_number = sr_ticket_number
    join catalog_sales on sr_customer_sk = cs_bill_customer_sk and sr_item_sk = cs_item_sk
    join date_dim d1 on d1.d_date_sk = ss_sold_date_sk and d1.d_moy = 4 and d1.d_year = 1998
    join date_dim d2 on sr_returned_date_sk = d2.d_date_sk and d2.d_moy between 4 and 4 + 3 and d2.d_year = 1998
    join date_dim d3 on cs_sold_date_sk = d3.d_date_sk and d3.d_year in (1998, 1998 + 1, 1998 + 2)
    ) as subquery
join store on s_store_sk = ss_store_sk
join item on i_item_sk = ss_item_sk
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