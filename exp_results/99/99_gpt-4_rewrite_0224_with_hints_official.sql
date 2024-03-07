```sql
SELECT 
    warehouse_name, 
    sm_type, 
    cc_name, 
    SUM("30 days"), 
    SUM("31-60 days"), 
    SUM("61-90 days"), 
    SUM("91-120 days"), 
    SUM(">120 days")
FROM 
(
    SELECT 
        SUBSTR(w_warehouse_name,1,20) as warehouse_name, 
        sm_type, 
        cc_name, 
        CASE WHEN (cs_ship_date_sk - cs_sold_date_sk <= 30 ) THEN 1 ELSE 0 END as "30 days", 
        CASE WHEN (cs_ship_date_sk - cs_sold_date_sk > 30) AND (cs_ship_date_sk - cs_sold_date_sk <= 60) THEN 1 ELSE 0 END as "31-60 days", 
        CASE WHEN (cs_ship_date_sk - cs_sold_date_sk > 60) AND (cs_ship_date_sk - cs_sold_date_sk <= 90) THEN 1 ELSE 0 END as "61-90 days", 
        CASE WHEN (cs_ship_date_sk - cs_sold_date_sk > 90) AND (cs_ship_date_sk - cs_sold_date_sk <= 120) THEN 1 ELSE 0 END as "91-120 days", 
        CASE WHEN (cs_ship_date_sk - cs_sold_date_sk > 120) THEN 1 ELSE 0 END as ">120 days"
    FROM 
        catalog_sales 
        JOIN warehouse ON cs_warehouse_sk = w_warehouse_sk 
        JOIN ship_mode ON cs_ship_mode_sk = sm_ship_mode_sk 
        JOIN call_center ON cs_call_center_sk = cc_call_center_sk 
        JOIN date_dim ON cs_ship_date_sk = d_date_sk 
    WHERE 
        d_month_seq BETWEEN 1194 AND 1194 + 11
) subquery
GROUP BY 
    warehouse_name, 
    sm_type, 
    cc_name
ORDER BY 
    warehouse_name, 
    sm_type, 
    cc_name 
LIMIT 100;
```