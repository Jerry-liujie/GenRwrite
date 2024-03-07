```sql
WITH sales AS (
    SELECT i_item_id,
           SUM(CASE
                   WHEN ss_item_sk IS NOT NULL THEN ss_ext_sales_price
                   WHEN cs_item_sk IS NOT NULL THEN cs_ext_sales_price
                   WHEN ws_item_sk IS NOT NULL THEN ws_ext_sales_price
                   ELSE 0
               END) total_sales
    FROM item
             LEFT JOIN store_sales ON ss_item_sk = i_item_sk
             LEFT JOIN catalog_sales ON cs_item_sk = i_item_sk
             LEFT JOIN web_sales ON ws_item_sk = i_item_sk
             LEFT JOIN date_dim ON ss_sold_date_sk = d_date_sk OR cs_sold_date_sk = d_date_sk OR ws_sold_date_sk = d_date_sk
             LEFT JOIN customer_address ON ss_addr_sk = ca_address_sk OR cs_bill_addr_sk = ca_address_sk OR ws_bill_addr_sk = ca_address_sk
    WHERE i_category = 'Jewelry'
      AND d_year = 2000
      AND d_moy = 10
      AND ca_gmt_offset = -5
    GROUP BY i_item_id
)
SELECT i_item_id, total_sales
FROM sales
ORDER BY i_item_id, total_sales
LIMIT 100;
```