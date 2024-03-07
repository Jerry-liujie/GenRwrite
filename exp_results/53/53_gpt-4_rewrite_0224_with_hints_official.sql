```
SELECT i_manufact_id, sum_sales, avg_quarterly_sales 
FROM (
    SELECT i_manufact_id, sum(ss_sales_price) as sum_sales, 
    AVG(sum(ss_sales_price)) OVER (PARTITION BY i_manufact_id) as avg_quarterly_sales 
    FROM item
    JOIN store_sales ON ss_item_sk = i_item_sk
    JOIN date_dim ON ss_sold_date_sk = d_date_sk
    JOIN store ON ss_store_sk = s_store_sk
    WHERE d_month_seq BETWEEN 1186 AND 1197
    AND (
        (i_category IN ('Books','Children','Electronics') AND i_class IN ('personal','portable','reference','self-help') AND i_brand IN ('scholaramalgamalg #14','scholaramalgamalg #7', 'exportiunivamalg #9','scholaramalgamalg #9')) 
        OR (i_category IN ('Women','Music','Men') AND i_class IN ('accessories','classical','fragrances','pants') AND i_brand IN ('amalgimporto #1','edu packscholar #1','exportiimporto #1', 'importoamalg #1'))
    )
    GROUP BY i_manufact_id, d_qoy 
) AS tmp1 
WHERE (avg_quarterly_sales > 0 AND ABS(sum_sales - avg_quarterly_sales)/avg_quarterly_sales > 0.1) 
ORDER BY avg_quarterly_sales, sum_sales, i_manufact_id 
LIMIT 100;
```