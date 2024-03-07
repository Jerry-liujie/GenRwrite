```sql
SELECT c.c_last_name, c.c_first_name, current_addr.ca_city, dn.bought_city, dn.ss_ticket_number, dn.amt, dn.profit
FROM (
    SELECT ss.ss_ticket_number, ss.ss_customer_sk, ca.ca_city AS bought_city, SUM(ss.ss_coupon_amt) AS amt, SUM(ss.ss_net_profit) AS profit
    FROM store_sales AS ss
    JOIN date_dim AS dd ON ss.ss_sold_date_sk = dd.d_date_sk
    JOIN store AS s ON ss.ss_store_sk = s.s_store_sk
    JOIN household_demographics AS hd ON ss.ss_hdemo_sk = hd.hd_demo_sk
    JOIN customer_address AS ca ON ss.ss_addr_sk = ca.ca_address_sk
    WHERE (hd.hd_dep_count = 8 OR hd.hd_vehicle_count= 0)
        AND dd.d_dow IN (6,0)
        AND dd.d_year IN (2000, 2001, 2002)
        AND s.s_city IN ('Midway','Fairview')
    GROUP BY ss.ss_ticket_number, ss.ss_customer_sk, ca.ca_city
) AS dn
JOIN customer AS c ON dn.ss_customer_sk = c.c_customer_sk
JOIN customer_address AS current_addr ON c.c_current_addr_sk = current_addr.ca_address_sk
WHERE current_addr.ca_city <> dn.bought_city
ORDER BY c.c_last_name, c.c_first_name, current_addr.ca_city, dn.bought_city, dn.ss_ticket_number
LIMIT 100;
```