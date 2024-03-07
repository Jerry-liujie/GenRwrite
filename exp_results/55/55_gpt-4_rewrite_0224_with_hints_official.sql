```
SELECT i_brand_id as brand_id, i_brand as brand, sum_agg as ext_price
FROM 
    (SELECT i_brand_id, i_brand, sum(ss_ext_sales_price) as sum_agg
    FROM store_sales
    JOIN item ON ss_item_sk = i_item_sk
    WHERE i_manager_id=52
    GROUP BY i_brand_id, i_brand) sales_agg
JOIN date_dim ON d_date_sk = ss_sold_date_sk
WHERE d_moy=11 and d_year=2000
ORDER BY ext_price DESC, brand_id
LIMIT 100;
```