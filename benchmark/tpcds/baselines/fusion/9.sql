SELECT 
    CASE WHEN v1 > 1071 THEN t1 ELSE e1 END AS bucket1,
    CASE WHEN v2 > 39161 THEN t2 ELSE e2 END AS bucket2,
    CASE WHEN v3 > 29434 THEN t3 ELSE e3 END AS bucket3,
    CASE WHEN v4 > 6568 THEN t4 ELSE e4 END AS bucket4,
    CASE WHEN v5 > 21216 THEN t5 ELSE e5 END AS bucket5
FROM (
    SELECT 
        COUNT(*) FILTER(WHERE b1) AS v1,
        AVG(ss_ext_tax) FILTER(WHERE b1) AS t1,
        AVG(ss_net_paid_inc_tax) FILTER(WHERE b1) AS e1,
        
        COUNT(*) FILTER(WHERE b2) AS v2,
        AVG(ss_ext_tax) FILTER(WHERE b2) AS t2,
        AVG(ss_net_paid_inc_tax) FILTER(WHERE b2) AS e2,
        
        COUNT(*) FILTER(WHERE b3) AS v3,
        AVG(ss_ext_tax) FILTER(WHERE b3) AS t3,
        AVG(ss_net_paid_inc_tax) FILTER(WHERE b3) AS e3,
        
        COUNT(*) FILTER(WHERE b4) AS v4,
        AVG(ss_ext_tax) FILTER(WHERE b4) AS t4,
        AVG(ss_net_paid_inc_tax) FILTER(WHERE b4) AS e4,
        
        COUNT(*) FILTER(WHERE b5) AS v5,
        AVG(ss_ext_tax) FILTER(WHERE b5) AS t5,
        AVG(ss_net_paid_inc_tax) FILTER(WHERE b5) AS e5
    FROM (
        SELECT *,
            ss_quantity BETWEEN 1 AND 20 AS b1,
            ss_quantity BETWEEN 21 AND 40 AS b2,
            ss_quantity BETWEEN 41 AND 60 AS b3,
            ss_quantity BETWEEN 61 AND 80 AS b4,
            ss_quantity BETWEEN 81 AND 100 AS b5
        FROM store_sales
        WHERE ss_quantity BETWEEN 1 AND 20
            OR ss_quantity BETWEEN 21 AND 40
            OR ss_quantity BETWEEN 41 AND 60
            OR ss_quantity BETWEEN 61 AND 80
            OR ss_quantity BETWEEN 81 AND 100
    ) AS sales_data
) AS aggregated_data, reason
WHERE reason.r_reason_sk = 1;
