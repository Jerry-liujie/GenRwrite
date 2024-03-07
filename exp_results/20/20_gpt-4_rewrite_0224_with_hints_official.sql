```sql
WITH sales_data AS (
    SELECT cs_item_sk, sum(cs_ext_sales_price) as itemrevenue 
    FROM catalog_sales 
    WHERE cs_sold_date_sk IN (
        SELECT d_date_sk 
        FROM date_dim 
        WHERE d_date BETWEEN cast('2002-06-18' as date) AND (cast('2002-06-18' as date) + interval '30' day)
    ) 
    GROUP BY cs_item_sk
)
SELECT i.i_item_id, i.i_item_desc, i.i_category, i.i_class, i.i_current_price, sd.itemrevenue, 
       (sd.itemrevenue*100/sum(sd.itemrevenue) over (partition by i.i_class)) as revenueratio 
FROM item i
JOIN sales_data sd ON i.i_item_sk = sd.cs_item_sk
WHERE i.i_category IN ('Books', 'Music', 'Sports')
ORDER BY i.i_category, i.i_class, i.i_item_id, i.i_item_desc, revenueratio 
LIMIT 100;
```