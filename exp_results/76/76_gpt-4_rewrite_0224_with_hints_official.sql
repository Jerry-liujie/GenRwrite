```sql
SELECT 
    sales.channel, 
    sales.col_name, 
    date_dim.d_year, 
    date_dim.d_qoy, 
    item.i_category, 
    COUNT(*) sales_cnt, 
    SUM(sales.ext_sales_price) sales_amt 
FROM 
    (
        SELECT 'store' as channel, 'ss_customer_sk' col_name, ss_sold_date_sk, ss_item_sk, ss_ext_sales_price ext_sales_price 
        FROM store_sales 
        WHERE ss_customer_sk is null
        UNION ALL 
        SELECT 'web' as channel, 'ws_promo_sk' col_name, ws_sold_date_sk, ws_item_sk, ws_ext_sales_price ext_sales_price 
        FROM web_sales 
        WHERE ws_promo_sk is null
        UNION ALL 
        SELECT 'catalog' as channel, 'cs_bill_customer_sk' col_name, cs_sold_date_sk, cs_item_sk, cs_ext_sales_price ext_sales_price 
        FROM catalog_sales 
        WHERE cs_bill_customer_sk is null
    ) sales 
JOIN date_dim ON sales.ss_sold_date_sk = date_dim.d_date_sk 
JOIN item ON sales.ss_item_sk = item.i_item_sk 
GROUP BY sales.channel, sales.col_name, date_dim.d_year, date_dim.d_qoy, item.i_category 
ORDER BY sales.channel, sales.col_name, date_dim.d_year, date_dim.d_qoy, item.i_category 
LIMIT 100;
```