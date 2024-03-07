```
WITH sales_data AS (
    SELECT cs_bill_customer_sk, cs_sales_price, cs_sold_date_sk
    FROM catalog_sales
    WHERE cs_sales_price > 500
)
SELECT ca_zip, SUM(cs_sales_price)
FROM sales_data
JOIN customer ON sales_data.cs_bill_customer_sk = customer.c_customer_sk
JOIN customer_address ON customer.c_current_addr_sk = customer_address.ca_address_sk
JOIN date_dim ON sales_data.cs_sold_date_sk = date_dim.d_date_sk
WHERE (SUBSTR(customer_address.ca_zip,1,5) IN ('85669', '86197','88274','83405','86475', '85392', '85460', '80348', '81792')
       OR customer_address.ca_state IN ('CA','WA','GA'))
      AND date_dim.d_qoy = 2
      AND date_dim.d_year = 2001
GROUP BY customer_address.ca_zip
ORDER BY customer_address.ca_zip
LIMIT 100;
```