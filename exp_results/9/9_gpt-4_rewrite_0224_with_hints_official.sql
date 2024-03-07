```
WITH sales_cte AS (
    SELECT 
        ss_quantity,
        ss_ext_tax,
        ss_net_paid_inc_tax
    FROM 
        store_sales
    WHERE 
        ss_quantity BETWEEN 1 AND 100
),
bucket_counts AS (
    SELECT
        COUNT(*) filter (where ss_quantity BETWEEN 1 AND 20) as count1,
        COUNT(*) filter (where ss_quantity BETWEEN 21 AND 40) as count2,
        COUNT(*) filter (where ss_quantity BETWEEN 41 AND 60) as count3,
        COUNT(*) filter (where ss_quantity BETWEEN 61 AND 80) as count4,
        COUNT(*) filter (where ss_quantity BETWEEN 81 AND 100) as count5
    FROM 
        sales_cte
)
SELECT 
    CASE WHEN count1 > 1071 THEN AVG(ss_ext_tax) filter (where ss_quantity BETWEEN 1 AND 20) ELSE AVG(ss_net_paid_inc_tax) filter (where ss_quantity BETWEEN 1 AND 20) END as bucket1,
    CASE WHEN count2 > 39161 THEN AVG(ss_ext_tax) filter (where ss_quantity BETWEEN 21 AND 40) ELSE AVG(ss_net_paid_inc_tax) filter (where ss_quantity BETWEEN 21 AND 40) END as bucket2,
    CASE WHEN count3 > 29434 THEN AVG(ss_ext_tax) filter (where ss_quantity BETWEEN 41 AND 60) ELSE AVG(ss_net_paid_inc_tax) filter (where ss_quantity BETWEEN 41 AND 60) END as bucket3,
    CASE WHEN count4 > 6568 THEN AVG(ss_ext_tax) filter (where ss_quantity BETWEEN 61 AND 80) ELSE AVG(ss_net_paid_inc_tax) filter (where ss_quantity BETWEEN 61 AND 80) END as bucket4,
    CASE WHEN count5 > 21216 THEN AVG(ss_ext_tax) filter (where ss_quantity BETWEEN 81 AND 100) ELSE AVG(ss_net_paid_inc_tax) filter (where ss_quantity BETWEEN 81 AND 100) END as bucket5
FROM 
    sales_cte, bucket_counts
WHERE 
    r_reason_sk = 1;
```