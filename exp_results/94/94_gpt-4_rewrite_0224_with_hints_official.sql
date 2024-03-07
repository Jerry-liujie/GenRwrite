```
WITH ws2_subquery AS (
    SELECT ws_order_number 
    FROM web_sales ws2 
    WHERE ws1.ws_order_number = ws2.ws_order_number 
    AND ws1.ws_warehouse_sk <> ws2.ws_warehouse_sk
),
wr1_subquery AS (
    SELECT wr_order_number 
    FROM web_returns wr1 
    WHERE ws1.ws_order_number = wr1.wr_order_number
)
SELECT count(distinct ws1.ws_order_number) as "order count", 
       sum(ws1.ws_ext_ship_cost) as "total shipping cost", 
       sum(ws1.ws_net_profit) as "total net profit" 
FROM web_sales ws1 
JOIN date_dim ON ws1.ws_ship_date_sk = date_dim.d_date_sk 
JOIN customer_address ON ws1.ws_ship_addr_sk = customer_address.ca_address_sk 
JOIN web_site ON ws1.ws_web_site_sk = web_site.web_site_sk 
WHERE date_dim.d_date between '2002-5-01' and (cast('2002-5-01' as date) + interval '60' day) 
AND customer_address.ca_state = 'OK' 
AND web_site.web_company_name = 'pri' 
AND EXISTS (SELECT 1 FROM ws2_subquery) 
AND NOT EXISTS (SELECT 1 FROM wr1_subquery) 
ORDER BY count(distinct ws1.ws_order_number) 
LIMIT 100;
```