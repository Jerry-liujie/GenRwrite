```
WITH sales_1999 AS (
    SELECT ss_customer_sk 
    FROM store_sales
    JOIN date_dim ON ss_sold_date_sk = d_date_sk
    WHERE d_year = 1999 AND d_qoy < 4
    UNION
    SELECT ws_bill_customer_sk 
    FROM web_sales
    JOIN date_dim ON ws_sold_date_sk = d_date_sk
    WHERE d_year = 1999 AND d_qoy < 4
    UNION
    SELECT cs_ship_customer_sk 
    FROM catalog_sales
    JOIN date_dim ON cs_sold_date_sk = d_date_sk
    WHERE d_year = 1999 AND d_qoy < 4
)
SELECT ca_state, cd_gender, cd_marital_status, cd_dep_count, count(*) cnt1, avg(cd_dep_count), stddev_samp(cd_dep_count), sum(cd_dep_count), cd_dep_employed_count, count(*) cnt2, avg(cd_dep_employed_count), stddev_samp(cd_dep_employed_count), sum(cd_dep_employed_count), cd_dep_college_count, count(*) cnt3, avg(cd_dep_college_count), stddev_samp(cd_dep_college_count), sum(cd_dep_college_count)
FROM customer c
JOIN customer_address ca ON c.c_current_addr_sk = ca.ca_address_sk
JOIN customer_demographics ON cd_demo_sk = c.c_current_cdemo_sk
WHERE c.c_customer_sk IN (SELECT * FROM sales_1999)
GROUP BY ca_state, cd_gender, cd_marital_status, cd_dep_count, cd_dep_employed_count, cd_dep_college_count
ORDER BY ca_state, cd_gender, cd_marital_status, cd_dep_count, cd_dep_employed_count, cd_dep_college_count
LIMIT 100;
```