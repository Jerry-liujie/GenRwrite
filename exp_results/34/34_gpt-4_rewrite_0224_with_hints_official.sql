```sql
SELECT c.c_last_name, c.c_first_name, c.c_salutation, c.c_preferred_cust_flag, dn.ss_ticket_number, dn.cnt 
FROM (
    SELECT ss.ss_ticket_number, ss.ss_customer_sk, COUNT(*) cnt 
    FROM store_sales ss
    JOIN date_dim d ON ss.ss_sold_date_sk = d.d_date_sk
    JOIN store s ON ss.ss_store_sk = s.s_store_sk
    JOIN household_demographics hd ON ss.ss_hdemo_sk = hd.hd_demo_sk
    WHERE (d.d_dom BETWEEN 1 AND 3 OR d.d_dom BETWEEN 25 AND 28) 
    AND hd.hd_buy_potential IN ('1001-5000', '0-500') 
    AND hd.hd_vehicle_count > 0 
    AND (CASE WHEN hd.hd_vehicle_count > 0 THEN hd.hd_dep_count/ hd.hd_vehicle_count ELSE NULL END) > 1.2 
    AND d.d_year IN (2000, 2001, 2002) 
    AND s.s_county = 'Williamson County'
    GROUP BY ss.ss_ticket_number, ss.ss_customer_sk
) dn
JOIN customer c ON dn.ss_customer_sk = c.c_customer_sk 
WHERE dn.cnt BETWEEN 15 AND 20 
ORDER BY c.c_last_name, c.c_first_name, c.c_salutation, c.c_preferred_cust_flag DESC, dn.ss_ticket_number;
```