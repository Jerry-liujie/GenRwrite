```
WITH sales_data AS (
    SELECT ss_item_sk, ss_ext_sales_price
    FROM store_sales
    JOIN date_dim ON ss_sold_date_sk = d_date_sk
    WHERE d_date BETWEEN cast('1999-02-05' as date) AND (cast('1999-02-05' as date) + interval '30' day)
),
filtered_items AS (
    SELECT i_item_id, i_item_desc, i_category, i_class, i_current_price, i_item_sk
    FROM item
    WHERE i_category in ('Men', 'Sports', 'Jewelry')
)
SELECT 
    fi.i_item_id, 
    fi.i_item_desc, 
    fi.i_category, 
    fi.i_class, 
    fi.i_current_price, 
    sum(sd.ss_ext_sales_price) as itemrevenue,
    sum(sd.ss_ext_sales_price)*100/sum(sum(sd.ss_ext_sales_price)) over (partition by fi.i_class) as revenueratio
FROM filtered_items fi
JOIN sales_data sd ON fi.i_item_sk = sd.ss_item_sk
GROUP BY fi.i_item_id, fi.i_item_desc, fi.i_category, fi.i_class, fi.i_current_price
ORDER BY fi.i_category, fi.i_class, fi.i_item_id, fi.i_item_desc, revenueratio;
```