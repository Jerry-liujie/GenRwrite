```
with ws_wh as (
    select ws1.ws_order_number,ws1.ws_warehouse_sk wh1,ws2.ws_warehouse_sk wh2 
    from web_sales ws1
    join web_sales ws2 on ws1.ws_order_number = ws2.ws_order_number and ws1.ws_warehouse_sk <> ws2.ws_warehouse_sk
), ws_wr as (
    select wr_order_number 
    from web_returns
    join ws_wh on wr_order_number = ws_wh.ws_order_number
)
select count(distinct ws1.ws_order_number) as "order count", sum(ws1.ws_ext_ship_cost) as "total shipping cost", sum(ws1.ws_net_profit) as "total net profit" 
from web_sales ws1 
join date_dim on ws1.ws_ship_date_sk = date_dim.d_date_sk and date_dim.d_date between '2001-4-01' and (cast('2001-4-01' as date) + interval '60' day)
join customer_address on ws1.ws_ship_addr_sk = customer_address.ca_address_sk and customer_address.ca_state = 'VA'
join web_site on ws1.ws_web_site_sk = web_site.web_site_sk and web_site.web_company_name = 'pri'
where exists (select 1 from ws_wh where ws1.ws_order_number = ws_wh.ws_order_number)
and exists (select 1 from ws_wr where ws1.ws_order_number = ws_wr.wr_order_number)
order by count(distinct ws1.ws_order_number) 
limit 100;
```