```sql
with sales as (
    select i_manufact_id,
           sum(case 
               when ss_sold_date_sk = d_date_sk and ss_addr_sk = ca_address_sk then ss_ext_sales_price
               when cs_sold_date_sk = d_date_sk and cs_bill_addr_sk = ca_address_sk then cs_ext_sales_price
               when ws_sold_date_sk = d_date_sk and ws_bill_addr_sk = ca_address_sk then ws_ext_sales_price
               else 0 
               end) as total_sales
    from item
    left join store_sales on ss_item_sk = i_item_sk
    left join catalog_sales on cs_item_sk = i_item_sk
    left join web_sales on ws_item_sk = i_item_sk
    left join date_dim on d_date_sk in (ss_sold_date_sk, cs_sold_date_sk, ws_sold_date_sk)
    left join customer_address on ca_address_sk in (ss_addr_sk, cs_bill_addr_sk, ws_bill_addr_sk)
    where i_category in ('Books') and d_year = 2001 and d_moy = 3 and ca_gmt_offset = -5
    group by i_manufact_id
)
select i_manufact_id, sum(total_sales) as total_sales
from sales
group by i_manufact_id
order by total_sales
limit 100;
```