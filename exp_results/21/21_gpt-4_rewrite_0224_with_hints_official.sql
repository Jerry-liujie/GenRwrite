```
WITH filtered_data AS (
  SELECT 
    w.w_warehouse_name,
    i.i_item_id,
    d.d_date,
    inv.inv_quantity_on_hand
  FROM 
    inventory inv
    JOIN item i ON i.i_item_sk = inv.inv_item_sk
    JOIN warehouse w ON inv.inv_warehouse_sk = w.w_warehouse_sk
    JOIN date_dim d ON inv.inv_date_sk = d.d_date_sk
  WHERE 
    i.i_current_price BETWEEN 0.99 AND 1.49
    AND d.d_date BETWEEN (DATE '1999-06-22' - INTERVAL '30' DAY) AND (DATE '1999-06-22' + INTERVAL '30' DAY)
)
SELECT 
  w_warehouse_name,
  i_item_id,
  SUM(CASE WHEN d_date < DATE '1999-06-22' THEN inv_quantity_on_hand ELSE 0 END) AS inv_before,
  SUM(CASE WHEN d_date >= DATE '1999-06-22' THEN inv_quantity_on_hand ELSE 0 END) AS inv_after
FROM 
  filtered_data
GROUP BY 
  w_warehouse_name, 
  i_item_id
HAVING 
  (CASE WHEN inv_before > 0 THEN inv_after / inv_before ELSE NULL END) BETWEEN 2.0/3.0 AND 3.0/2.0
ORDER BY 
  w_warehouse_name, 
  i_item_id 
LIMIT 100;
```