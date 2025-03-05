WITH customer_total_return AS (
    SELECT
        sr_customer_sk AS ctr_customer_sk,
        sr_store_sk AS ctr_store_sk,
        SUM(sr_fee) AS ctr_total_return,
        AVG(SUM(sr_fee)) OVER (PARTITION BY sr_store_sk) * 1.2 AS avg_ctr_total_return
    FROM
        store_returns
    JOIN
        date_dim ON sr_returned_date_sk = d_date_sk
    WHERE
        d_year = 2000
    GROUP BY
        sr_customer_sk,
        sr_store_sk
)
SELECT
    c_customer_id
FROM
    customer_total_return ctr
JOIN
    store s ON ctr.ctr_store_sk = s.s_store_sk
JOIN
    customer c ON ctr.ctr_customer_sk = c.c_customer_sk
WHERE
    ctr.ctr_total_return > ctr.avg_ctr_total_return
    AND s.s_state = 'TN'
ORDER BY
    c_customer_id
LIMIT 100;
