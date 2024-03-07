```
WITH store_sales_subquery AS (
    SELECT c.c_customer_sk 
    FROM store_sales 
    JOIN date_dim ON ss_sold_date_sk = d_date_sk 
    WHERE d_year = 2001 AND d_moy BETWEEN 3 AND 6
),
web_sales_subquery AS (
    SELECT c.c_customer_sk 
    FROM web_sales 
    JOIN date_dim ON ws_sold_date_sk = d_date_sk 
    WHERE d_year = 2001 AND d_moy BETWEEN 3 AND 6
),
catalog_sales_subquery AS (
    SELECT c.c_customer_sk 
    FROM catalog_sales 
    JOIN date_dim ON cs_sold_date_sk = d_date_sk 
    WHERE d_year = 2001 AND d_moy BETWEEN 3 AND 6
)
SELECT cd_gender, cd_marital_status, cd_education_status, count(*) cnt1, 
cd_purchase_estimate, count(*) cnt2, cd_credit_rating, count(*) cnt3, 
cd_dep_count, count(*) cnt4, cd_dep_employed_count, count(*) cnt5, 
cd_dep_college_count, count(*) cnt6 
FROM customer c
JOIN customer_address ca ON c.c_current_addr_sk = ca.ca_address_sk 
JOIN customer_demographics ON cd_demo_sk = c.c_current_cdemo_sk
WHERE ca_county IN ('Fairfield County','Campbell County','Washtenaw County','Escambia County','Cleburne County') 
AND c.c_customer_sk IN (store_sales_subquery UNION web_sales_subquery UNION catalog_sales_subquery)
GROUP BY cd_gender, cd_marital_status, cd_education_status, cd_purchase_estimate, 
cd_credit_rating, cd_dep_count, cd_dep_employed_count, cd_dep_college_count 
ORDER BY cd_gender, cd_marital_status, cd_education_status, cd_purchase_estimate, 
cd_credit_rating, cd_dep_count, cd_dep_employed_count, cd_dep_college_count 
LIMIT 100;
```