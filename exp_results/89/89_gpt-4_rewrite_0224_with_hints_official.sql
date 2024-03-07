```
WITH sales_data AS (
  SELECT 
    i_category, 
    i_class, 
    i_brand, 
    s_store_name, 
    s_company_name, 
    d_moy, 
    sum(ss_sales_price) sum_sales
  FROM 
    item
    JOIN store_sales ON ss_item_sk = i_item_sk
    JOIN date_dim ON ss_sold_date_sk = d_date_sk
    JOIN store ON ss_store_sk = s_store_sk
  WHERE 
    d_year = 2001
    AND (
      (i_category in ('Books','Children','Electronics') AND i_class in ('history','school-uniforms','audio')) 
      OR (i_category in ('Men','Sports','Shoes') AND i_class in ('pants','tennis','womens'))
    )
  GROUP BY 
    i_category, 
    i_class, 
    i_brand, 
    s_store_name, 
    s_company_name, 
    d_moy
)
SELECT 
  *, 
  avg(sum_sales) OVER (PARTITION BY i_category, i_brand, s_store_name, s_company_name) avg_monthly_sales
FROM 
  sales_data
WHERE 
  (avg_monthly_sales <> 0 AND abs(sum_sales - avg_monthly_sales) / avg_monthly_sales > 0.1)
ORDER BY 
  sum_sales - avg_monthly_sales, 
  s_store_name 
LIMIT 100;
```