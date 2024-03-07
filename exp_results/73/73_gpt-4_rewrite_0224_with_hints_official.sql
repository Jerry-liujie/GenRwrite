```sql
SELECT c.c_last_name, c.c_first_name, c.c_salutation, c.c_preferred_cust_flag, dj.ss_ticket_number, dj.cnt
FROM (
    SELECT ss.ss_ticket_number, ss.ss_customer_sk, COUNT(*) AS cnt
    FROM store_sales AS ss
    JOIN date_dim AS d ON ss.ss_sold_date_sk = d.d_date_sk
    JOIN store AS s ON ss.ss_store_sk = s.s_store_sk
    JOIN household_demographics AS hd ON ss.ss_hdemo_sk = hd.hd_demo_sk
    WHERE d.d_dom BETWEEN 1 AND 2
    AND hd.hd_buy_potential IN ('1001-5000', '5001-10000')
    AND hd.hd_vehicle_count > 0
    AND (hd.hd_dep_count / hd.hd_vehicle_count) > 1
    AND d.d_year BETWEEN 2000 AND 2002
    AND s.s_county = 'Williamson County'
    GROUP BY ss.ss_ticket_number, ss.ss_customer_sk
    HAVING cnt BETWEEN 1 AND 5
) AS dj
JOIN customer AS c ON dj.ss_customer_sk = c.c_customer_sk
ORDER BY dj.cnt DESC, c.c_last_name ASC;
```