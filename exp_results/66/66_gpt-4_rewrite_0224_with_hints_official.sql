```sql
SELECT 
    x.w_warehouse_name,
    x.w_warehouse_sq_ft,
    x.w_city,
    x.w_county,
    x.w_state,
    x.w_country,
    x.ship_carriers,
    x.year,
    SUM(x.jan_sales) AS jan_sales,
    SUM(x.feb_sales) AS feb_sales,
    SUM(x.mar_sales) AS mar_sales,
    SUM(x.apr_sales) AS apr_sales,
    SUM(x.may_sales) AS may_sales,
    SUM(x.jun_sales) AS jun_sales,
    SUM(x.jul_sales) AS jul_sales,
    SUM(x.aug_sales) AS aug_sales,
    SUM(x.sep_sales) AS sep_sales,
    SUM(x.oct_sales) AS oct_sales,
    SUM(x.nov_sales) AS nov_sales,
    SUM(x.dec_sales) AS dec_sales,
    SUM(x.jan_net) AS jan_net,
    SUM(x.feb_net) AS feb_net,
    SUM(x.mar_net) AS mar_net,
    SUM(x.apr_net) AS apr_net,
    SUM(x.may_net) AS may_net,
    SUM(x.jun_net) AS jun_net,
    SUM(x.jul_net) AS jul_net,
    SUM(x.aug_net) AS aug_net,
    SUM(x.sep_net) AS sep_net,
    SUM(x.oct_net) AS oct_net,
    SUM(x.nov_net) AS nov_net,
    SUM(x.dec_net) AS dec_net
FROM 
(
    SELECT 
        ws.w_warehouse_name,
        ws.w_warehouse_sq_ft,
        ws.w_city,
        ws.w_county,
        ws.w_state,
        ws.w_country,
        'ORIENTAL, BOXBUNDLES' AS ship_carriers,
        ws.d_year AS year,
        SUM(IF(ws.d_moy = 1, ws.ws_ext_sales_price * ws.ws_quantity, 0)) AS jan_sales,
        SUM(IF(ws.d_moy = 2, ws.ws_ext_sales_price * ws.ws_quantity, 0)) AS feb_sales,
        SUM(IF(ws.d_moy = 3, ws.ws_ext_sales_price * ws.ws_quantity, 0)) AS mar_sales,
        SUM(IF(ws.d_moy = 4, ws.ws_ext_sales_price * ws.ws_quantity, 0)) AS apr_sales,
        SUM(IF(ws.d_moy = 5, ws.ws_ext_sales_price * ws.ws_quantity, 0)) AS may_sales,
        SUM(IF(ws.d_moy = 6, ws.ws_ext_sales_price * ws.ws_quantity, 0)) AS jun_sales,
        SUM(IF(ws.d_moy = 7, ws.ws_ext_sales_price * ws.ws_quantity, 0)) AS jul_sales,
        SUM(IF(ws.d_moy = 8, ws.ws_ext_sales_price * ws.ws_quantity, 0)) AS aug_sales,
        SUM(IF(ws.d_moy = 9, ws.ws_ext_sales_price * ws.ws_quantity, 0)) AS sep_sales,
        SUM(IF(ws.d_moy = 10, ws.ws_ext_sales_price * ws.ws_quantity, 0)) AS oct_sales,
        SUM(IF(ws.d_moy = 11, ws.ws_ext_sales_price * ws.ws_quantity, 0)) AS nov_sales,
        SUM(IF(ws.d_moy = 12, ws.ws_ext_sales_price * ws.ws_quantity, 0)) AS dec_sales,
        SUM(IF(ws.d_moy = 1, ws.ws_net_paid_inc_ship * ws.ws_quantity, 0)) AS jan_net,
        SUM(IF(ws.d_moy = 2, ws.ws_net_paid_inc_ship * ws.ws_quantity, 0)) AS feb_net,
        SUM(IF(ws.d_moy = 3, ws.ws_net_paid_inc_ship * ws.ws_quantity, 0)) AS mar_net,
        SUM(IF(ws.d_moy = 4, ws.ws_net_paid_inc_ship * ws.ws_quantity, 0)) AS apr_net,
        SUM(IF(ws.d_moy = 5, ws.ws_net_paid_inc_ship * ws.ws_quantity, 0)) AS may_net,
        SUM(IF(ws.d_moy = 6, ws.ws_net_paid_inc_ship * ws.ws_quantity, 0)) AS jun_net,
        SUM(IF(ws.d_moy = 7, ws.ws_net_paid_inc_ship * ws.ws_quantity, 0)) AS jul_net,
        SUM(IF(ws.d_moy = 8, ws.ws_net_paid_inc_ship * ws.ws_quantity, 0)) AS aug_net,
        SUM(IF(ws.d_moy = 9, ws.ws_net_paid_inc_ship * ws.ws_quantity, 0)) AS sep_net,
        SUM(IF(ws.d_moy = 10, ws.ws_net_paid_inc_ship * ws.ws_quantity, 0)) AS oct_net,
        SUM(IF(ws.d_moy = 11, ws.ws_net_paid_inc_ship * ws.ws_quantity, 0)) AS nov_net,
        SUM(IF(ws.d_moy = 12, ws.ws_net_paid_inc_ship * ws.ws_quantity, 0)) AS dec_net
    FROM 
        web_sales ws
    JOIN 
        warehouse w ON ws.ws_warehouse_sk = w.w_warehouse_sk
    JOIN 
        date_dim d ON ws.ws_sold_date_sk = d.d_date_sk
    JOIN 
        time_dim t ON ws.ws_sold_time_sk = t.t_time_sk
    JOIN 
        ship_mode sm ON ws.ws_ship_mode_sk = sm.sm_ship_mode_sk
    WHERE 
        d.d_year = 2001
        AND t.t_time BETWEEN 42970 AND 42970 + 28800
        AND sm.sm_carrier IN ('ORIENTAL', 'BOXBUNDLES')
    GROUP BY 
        ws.w_warehouse_name,
        ws.w_warehouse_sq_ft,
        ws.w_city,
        ws.w_county,
        ws.w_state,
        ws.w_country,
        ws.d_year
) x
GROUP BY 
    x.w_warehouse_name,
    x.w_warehouse_sq_ft,
    x.w_city,
    x.w_county,
    x.w_state,
    x.w_country,
    x.ship_carriers,
    x.year
ORDER BY 
    x.w_warehouse_name
LIMIT 100;
```