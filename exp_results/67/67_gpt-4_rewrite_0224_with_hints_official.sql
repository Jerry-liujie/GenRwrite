```
WITH sales_data AS (
    SELECT 
        i_category, 
        i_class, 
        i_brand, 
        i_product_name, 
        d_year, 
        d_qoy, 
        d_moy, 
        s_store_id, 
        sum(coalesce(ss_sales_price * ss_quantity, 0)) sumsales 
    FROM 
        store_sales 
        JOIN date_dim ON ss_sold_date_sk = d_date_sk 
        JOIN store ON ss_store_sk = s_store_sk 
        JOIN item ON ss_item_sk = i_item_sk 
    WHERE 
        d_month_seq between 1217 and 1217 + 11 
    GROUP BY 
        rollup( i_category, i_class, i_brand, i_product_name, d_year, d_qoy, d_moy, s_store_id )
),
ranked_sales AS (
    SELECT 
        *, 
        rank() over ( partition by i_category order by sumsales desc ) rk 
    FROM 
        sales_data
)
SELECT * 
FROM 
    ranked_sales 
WHERE 
    rk <= 100 
ORDER BY 
    i_category, i_class, i_brand, i_product_name, d_year, d_qoy, d_moy, s_store_id, sumsales, rk 
LIMIT 100;
```