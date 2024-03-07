```
WITH customer_data AS (
    SELECT cs_item_sk, cs_quantity, cs_list_price, cs_coupon_amt, cs_sales_price, cs_net_profit, c_birth_year, cd1.cd_dep_count
    FROM catalog_sales
    JOIN customer_demographics cd1 ON cs_bill_cdemo_sk = cd1.cd_demo_sk
    JOIN customer ON cs_bill_customer_sk = c_customer_sk
    WHERE cd1.cd_gender = 'F' AND cd1.cd_education_status = 'Primary' AND c_birth_month IN (1,3,7,11,10,4)
),
date_data AS (
    SELECT d_date_sk
    FROM date_dim
    WHERE d_year = 2001
),
address_data AS (
    SELECT ca_address_sk, ca_country, ca_state, ca_county
    FROM customer_address
    WHERE ca_state IN ('AL','MO','TN' ,'GA','MT','IN','CA')
),
item_data AS (
    SELECT i_item_id, i_item_sk
    FROM item
)
SELECT i_item_id, ca_country, ca_state, ca_county, 
    AVG( CAST(cs_quantity AS DECIMAL(12,2))) agg1, 
    AVG( CAST(cs_list_price AS DECIMAL(12,2))) agg2, 
    AVG( CAST(cs_coupon_amt AS DECIMAL(12,2))) agg3, 
    AVG( CAST(cs_sales_price AS DECIMAL(12,2))) agg4, 
    AVG( CAST(cs_net_profit AS DECIMAL(12,2))) agg5, 
    AVG( CAST(c_birth_year AS DECIMAL(12,2))) agg6, 
    AVG( CAST(cd_dep_count AS DECIMAL(12,2))) agg7
FROM customer_data
JOIN date_data ON cs_sold_date_sk = d_date_sk
JOIN address_data ON c_current_addr_sk = ca_address_sk
JOIN item_data ON cs_item_sk = i_item_sk
GROUP BY ROLLUP (i_item_id, ca_country, ca_state, ca_county)
ORDER BY ca_country, ca_state, ca_county, i_item_id
LIMIT 100;
```