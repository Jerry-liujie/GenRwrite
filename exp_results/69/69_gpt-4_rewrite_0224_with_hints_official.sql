```
WITH store_sales_customers AS (
    SELECT c.c_customer_sk
    FROM customer c
    JOIN customer_address ca ON c.c_current_addr_sk = ca.ca_address_sk
    JOIN customer_demographics cd ON cd.cd_demo_sk = c.c_current_cdemo_sk
    JOIN store_sales ss ON c.c_customer_sk = ss.ss_customer_sk
    JOIN date_dim d ON ss.ss_sold_date_sk = d_date_sk
    WHERE ca.ca_state in ('IL','TX','ME') 
    AND d.d_year = 2002 
    AND d.d_moy between 1 and 1+2
),
web_sales_customers AS (
    SELECT ws.ws_bill_customer_sk
    FROM web_sales ws
    JOIN date_dim d ON ws.ws_sold_date_sk = d_date_sk
    WHERE d.d_year = 2002 
    AND d.d_moy between 1 and 1+2
),
catalog_sales_customers AS (
    SELECT cs.cs_ship_customer_sk
    FROM catalog_sales cs
    JOIN date_dim d ON cs.cs_sold_date_sk = d_date_sk
    WHERE d.d_year = 2002 
    AND d.d_moy between 1 and 1+2
)
SELECT cd_gender, cd_marital_status, cd_education_status, count(*) cnt1, cd_purchase_estimate, count(*) cnt2, cd_credit_rating, count(*) cnt3
FROM customer_demographics
WHERE c_customer_sk IN (SELECT c_customer_sk FROM store_sales_customers)
AND c_customer_sk NOT IN (SELECT ws_bill_customer_sk FROM web_sales_customers)
AND c_customer_sk NOT IN (SELECT cs_ship_customer_sk FROM catalog_sales_customers)
GROUP BY cd_gender, cd_marital_status, cd_education_status, cd_purchase_estimate, cd_credit_rating
ORDER BY cd_gender, cd_marital_status, cd_education_status, cd_purchase_estimate, cd_credit_rating
LIMIT 100;
```