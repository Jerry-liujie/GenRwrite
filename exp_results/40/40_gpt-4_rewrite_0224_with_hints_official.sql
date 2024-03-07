```
SELECT w_state, i_item_id, 
       SUM( CASE WHEN (d_date < '2001-05-02') THEN cs_sales_price - COALESCE(cr_refunded_cash, 0) ELSE 0 END ) AS sales_before, 
       SUM( CASE WHEN (d_date >= '2001-05-02') THEN cs_sales_price - COALESCE(cr_refunded_cash, 0) ELSE 0 END ) AS sales_after 
FROM catalog_sales 
LEFT JOIN catalog_returns ON cs_order_number = cr_order_number AND cs_item_sk = cr_item_sk 
JOIN warehouse ON cs_warehouse_sk = w_warehouse_sk 
JOIN item ON i_item_sk = cs_item_sk AND i_current_price BETWEEN 0.99 AND 1.49 
JOIN date_dim ON cs_sold_date_sk = d_date_sk AND d_date BETWEEN '2001-04-02' AND '2001-06-01' 
GROUP BY w_state, i_item_id 
ORDER BY w_state, i_item_id 
LIMIT 100;
```