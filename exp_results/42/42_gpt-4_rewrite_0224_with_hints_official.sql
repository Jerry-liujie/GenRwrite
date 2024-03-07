```
SELECT dt.d_year, item.i_category_id, item.i_category, SUM(ss.ss_ext_sales_price)
FROM date_dim dt
JOIN store_sales ss ON dt.d_date_sk = ss.ss_sold_date_sk
JOIN item ON ss.ss_item_sk = item.i_item_sk AND item.i_manager_id = 1
WHERE dt.d_moy = 11 AND dt.d_year = 1998
GROUP BY dt.d_year, item.i_category_id, item.i_category
ORDER BY SUM(ss.ss_ext_sales_price) DESC, dt.d_year, item.i_category_id, item.i_category
LIMIT 100;
```