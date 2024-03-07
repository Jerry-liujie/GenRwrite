WITH sales_data AS (
    SELECT 
        s_store_name, 
        s_store_id, 
        ss_sales_price, 
        d_day_name 
    FROM 
        date_dim 
    INNER JOIN 
        store_sales ON d_date_sk = ss_sold_date_sk 
    INNER JOIN 
        store ON s_store_sk = ss_store_sk 
    WHERE 
        s_gmt_offset = -5 AND d_year = 2000
)
SELECT 
    s_store_name, 
    s_store_id, 
    SUM(CASE WHEN (d_day_name='Sunday') THEN ss_sales_price ELSE 0 END) sun_sales, 
    SUM(CASE WHEN (d_day_name='Monday') THEN ss_sales_price ELSE 0 END) mon_sales, 
    SUM(CASE WHEN (d_day_name='Tuesday') THEN ss_sales_price ELSE 0 END) tue_sales, 
    SUM(CASE WHEN (d_day_name='Wednesday') THEN ss_sales_price ELSE 0 END) wed_sales, 
    SUM(CASE WHEN (d_day_name='Thursday') THEN ss_sales_price ELSE 0 END) thu_sales, 
    SUM(CASE WHEN (d_day_name='Friday') THEN ss_sales_price ELSE 0 END) fri_sales, 
    SUM(CASE WHEN (d_day_name='Saturday') THEN ss_sales_price ELSE 0 END) sat_sales 
FROM 
    sales_data 
GROUP BY 
    s_store_name, 
    s_store_id 
ORDER BY 
    s_store_name, 
    s_store_id,
    sun_sales,
    mon_sales,
    tue_sales,
    wed_sales,
    thu_sales,
    fri_sales,
    sat_sales 
LIMIT 100;