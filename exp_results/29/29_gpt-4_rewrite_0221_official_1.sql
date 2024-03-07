```sql
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
            max(ss_quantity) as ss_quantity,
            max(sr_return_quantity) as sr_return_quantity,
            max(cs_quantity) as cs_quantity
        from
            store_sales
            join store_returns on ss_customer_sk = sr_customer_sk and ss_item_sk = sr_item_sk and ss_ticket_number = sr_ticket_number
            join catalog_sales on sr_customer_sk = cs_bill_customer_sk and sr_item_sk = cs_item_sk
        where
            ss_sold_date_sk in (select d_date_sk from date_dim where d_moy = 4 and d_year = 1998)
            and sr_returned_date_sk in (select d_date_sk from date_dim where d_moy between 4 and 7 and d_year = 1998)
            and cs_sold_date_sk in (select d_date_sk from date_dim where d_year in (1998, 1999, 2000))
        group by
            ss_item_sk,
            ss_store_sk,
            ss_customer_sk
    ) sales
    join store on sales.ss_store_sk = s_store_sk
    join item on sales.ss_item_sk = i_item_sk
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