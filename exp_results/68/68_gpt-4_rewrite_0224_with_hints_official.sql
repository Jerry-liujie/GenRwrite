```sql
SELECT 
    c.c_last_name,
    c.c_first_name,
    current_addr.ca_city,
    dn.bought_city,
    dn.ss_ticket_number,
    dn.extended_price,
    dn.extended_tax,
    dn.list_price
FROM 
    (
        SELECT 
            ss.ss_ticket_number,
            ss.ss_customer_sk,
            ca.ca_city AS bought_city,
            SUM(ss.ss_ext_sales_price) AS extended_price,
            SUM(ss.ss_ext_list_price) AS list_price,
            SUM(ss.ss_ext_tax) AS extended_tax
        FROM 
            store_sales AS ss
            JOIN date_dim AS dd ON ss.ss_sold_date_sk = dd.d_date_sk
            JOIN store AS s ON ss.ss_store_sk = s.s_store_sk
            JOIN household_demographics AS hd ON ss.ss_hdemo_sk = hd.hd_demo_sk
            JOIN customer_address AS ca ON ss.ss_addr_sk = ca.ca_address_sk
        WHERE 
            dd.d_dom BETWEEN 1 AND 2
            AND (hd.hd_dep_count = 3 OR hd.hd_vehicle_count= 4)
            AND dd.d_year IN (1998, 1999, 2000)
            AND s.s_city IN ('Fairview','Midway')
        GROUP BY 
            ss.ss_ticket_number,
            ss.ss_customer_sk,
            ss.ss_addr_sk,
            ca.ca_city
    ) AS dn
    JOIN customer AS c ON dn.ss_customer_sk = c.c_customer_sk
    JOIN customer_address AS current_addr ON c.c_current_addr_sk = current_addr.ca_address_sk
WHERE 
    current_addr.ca_city <> dn.bought_city
ORDER BY 
    c.c_last_name,
    dn.ss_ticket_number 
LIMIT 100;
```