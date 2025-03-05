WITH revenue_analysis AS (
    SELECT
        ss.ss_store_sk,
        ss.ss_item_sk,
        SUM(ss.ss_sales_price) AS revenue,
        AVG(SUM(ss.ss_sales_price)) OVER (PARTITION BY ss.ss_store_sk) AS store_average
    FROM
        store_sales ss
    JOIN date_dim d ON ss.ss_sold_date_sk = d.d_date_sk
    WHERE
        d.d_month_seq BETWEEN 1176 AND 1176 + 11
    GROUP BY
        ss.ss_store_sk,
        ss.ss_item_sk
)
SELECT
    s.s_store_name,
    i.i_item_desc,
    ra.revenue,
    i.i_current_price,
    i.i_wholesale_cost,
    i.i_brand
FROM
    revenue_analysis ra
JOIN store s ON ra.ss_store_sk = s.s_store_sk
JOIN item i ON ra.ss_item_sk = i.i_item_sk
WHERE
    ra.revenue <= 0.1 * ra.store_average
ORDER BY
    s.s_store_name,
    i.i_item_desc
LIMIT 100;
