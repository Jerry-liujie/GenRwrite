```
with sales as (
    select i_item_id, 
    sum(case 
        when ss.ss_item_sk is not null then ss.ss_ext_sales_price
        when cs.cs_item_sk is not null then cs.cs_ext_sales_price
        when ws.ws_item_sk is not null then ws.ws_ext_sales_price
        else 0 end) as total_sales
    from item
    left join store_sales ss on ss.ss_item_sk = item.i_item_sk
    left join catalog_sales cs on cs.cs_item_sk = item.i_item_sk
    left join web_sales ws on ws.ws_item_sk = item.i_item_sk
    left join date_dim dd on ss.ss_sold_date_sk = dd.d_date_sk or cs.cs_sold_date_sk = dd.d_date_sk or ws.ws_sold_date_sk = dd.d_date_sk
    left join customer_address ca on ss.ss_addr_sk = ca.ca_address_sk or cs.cs_bill_addr_sk = ca.ca_address_sk or ws.ws_bill_addr_sk = ca.ca_address_sk
    where item.i_color in ('powder','orchid','pink') and dd.d_year = 2000 and dd.d_moy = 3 and ca.ca_gmt_offset = -6
    group by i_item_id
)
select i_item_id, total_sales from sales order by total_sales, i_item_id limit 100;
```