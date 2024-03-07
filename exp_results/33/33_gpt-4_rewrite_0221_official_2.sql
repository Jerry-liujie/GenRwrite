```sql
with total_sales as (
    select
        i_manufact_id,
        sum(case when ss.ss_ext_sales_price is not null then ss.ss_ext_sales_price
                 when cs.cs_ext_sales_price is not null then cs.cs_ext_sales_price
                 when ws.ws_ext_sales_price is not null then ws.ws_ext_sales_price
                 else 0 end) as total_sales
    from
        item
        left join store_sales ss on ss.ss_item_sk = item.i_item_sk
        left join catalog_sales cs on cs.cs_item_sk = item.i_item_sk
        left join web_sales ws on ws.ws_item_sk = item.i_item_sk
        left join date_dim d on d.d_date_sk in (ss.ss_sold_date_sk, cs.cs_sold_date_sk, ws.ws_sold_date_sk)
        left join customer_address ca on ca.ca_address_sk in (ss.ss_addr_sk, cs.cs_bill_addr_sk, ws.ws_bill_addr_sk)
    where
        item.i_category = 'Books'
        and d.d_year = 2001
        and d.d_moy = 3
        and ca.ca_gmt_offset = -5
    group by
        item.i_manufact_id
)
select
    i_manufact_id,
    total_sales
from
    total_sales
order by
    total_sales
limit
    100;
```