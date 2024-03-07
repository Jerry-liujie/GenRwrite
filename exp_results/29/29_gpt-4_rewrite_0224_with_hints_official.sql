```
SELECT i_item_id, i_item_desc, s_store_id, s_store_name, max_store_sales_quantity, max_store_returns_quantity, max_catalog_sales_quantity 
FROM (
    SELECT ss_item_sk, ss_store_sk, max(ss_quantity) as max_store_sales_quantity
    FROM store_sales
    WHERE ss_sold_date_sk IN (
        SELECT d_date_sk 
        FROM date_dim 
        WHERE d_moy = 4 AND d_year = 1998
    )
    GROUP BY ss_item_sk, ss_store_sk
) store_sales
JOIN (
    SELECT sr_item_sk, max(sr_return_quantity) as max_store_returns_quantity
    FROM store_returns
    WHERE sr_returned_date_sk IN (
        SELECT d_date_sk 
        FROM date_dim 
        WHERE d_moy BETWEEN 4 AND 7 AND d_year = 1998
    )
    GROUP BY sr_item_sk
) store_returns ON store_sales.ss_item_sk = store_returns.sr_item_sk AND store_sales.ss_customer_sk = store_returns.sr_customer_sk
JOIN (
    SELECT cs_item_sk, max(cs_quantity) as max_catalog_sales_quantity
    FROM catalog_sales
    WHERE cs_sold_date_sk IN (
        SELECT d_date_sk 
        FROM date_dim 
        WHERE d_year BETWEEN 1998 AND 2000
    )
    GROUP BY cs_item_sk
) catalog_sales ON store_sales.ss_item_sk = catalog_sales.cs_item_sk AND store_sales.ss_customer_sk = catalog_sales.cs_bill_customer_sk
JOIN store ON store_sales.ss_store_sk = store.s_store_sk
JOIN item ON store_sales.ss_item_sk = item.i_item_sk
ORDER BY i_item_id, i_item_desc, s_store_id, s_store_name 
LIMIT 100;
```