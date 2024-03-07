```
SELECT c.c_last_name, c.c_first_name, SUBSTR(s.s_city, 1, 30), ms.ss_ticket_number, ms.amt, ms.profit
FROM (
    SELECT ss.ss_ticket_number, ss.ss_customer_sk, s.s_city, SUM(ss.ss_coupon_amt) AS amt, SUM(ss.ss_net_profit) AS profit
    FROM store_sales ss
    JOIN date_dim d ON ss.ss_sold_date_sk = d.d_date_sk
    JOIN store s ON ss.ss_store_sk = s.s_store_sk
    JOIN household_demographics hd ON ss.ss_hdemo_sk = hd.hd_demo_sk
    WHERE (hd.hd_dep_count = 7 OR hd.hd_vehicle_count > -1)
    AND d.d_dow = 1
    AND d.d_year BETWEEN 2000 AND 2002
    AND s.s_number_employees BETWEEN 200 AND 295
    GROUP BY ss.ss_ticket_number, ss.ss_customer_sk, s.s_city
) ms
JOIN customer c ON ms.ss_customer_sk = c.c_customer_sk
ORDER BY c.c_last_name, c.c_first_name, SUBSTR(s.s_city, 1, 30), ms.profit
LIMIT 100;
```