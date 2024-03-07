WITH am_sales AS (
    SELECT COUNT(*) amc 
    FROM web_sales
    JOIN time_dim ON ws_sold_time_sk = time_dim.t_time_sk
    JOIN household_demographics ON ws_ship_hdemo_sk = household_demographics.hd_demo_sk
    JOIN web_page ON ws_web_page_sk = web_page.wp_web_page_sk
    WHERE time_dim.t_hour = 12 
    AND household_demographics.hd_dep_count = 6 
    AND web_page.wp_char_count BETWEEN 5000 AND 5200
),
pm_sales AS (
    SELECT COUNT(*) pmc 
    FROM web_sales
    JOIN time_dim ON ws_sold_time_sk = time_dim.t_time_sk
    JOIN household_demographics ON ws_ship_hdemo_sk = household_demographics.hd_demo_sk
    JOIN web_page ON ws_web_page_sk = web_page.wp_web_page_sk
    WHERE time_dim.t_hour = 14 
    AND household_demographics.hd_dep_count = 6 
    AND web_page.wp_char_count BETWEEN 5000 AND 5200
)
SELECT CAST(am_sales.amc AS DECIMAL(15,4)) / CAST(pm_sales.pmc AS DECIMAL(15,4)) am_pm_ratio
FROM am_sales, pm_sales
ORDER BY am_pm_ratio
LIMIT 100;