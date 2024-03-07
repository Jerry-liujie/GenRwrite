WITH avg_discount AS (
    SELECT avg(ws_ext_discount_amt) as avg_discount
    FROM web_sales ws
    JOIN date_dim d ON ws.ws_sold_date_sk = d.d_date_sk
    WHERE d.d_date BETWEEN '2000-02-01' AND (cast('2000-02-01' as date) + interval '90' day)
)
SELECT sum(ws.ws_ext_discount_amt) as "excess discount amount"
FROM web_sales ws
JOIN item i ON ws.ws_item_sk = i.i_item_sk
JOIN date_dim d ON ws.ws_sold_date_sk = d.d_date_sk
JOIN avg_discount ad ON ws.ws_ext_discount_amt > 1.3 * ad.avg_discount
WHERE i.i_manufact_id = 714
AND d.d_date BETWEEN '2000-02-01' AND (cast('2000-02-01' as date) + interval '90' day)
ORDER BY sum(ws.ws_ext_discount_amt)
LIMIT 100;