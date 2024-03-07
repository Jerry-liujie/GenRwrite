with avg_discount as (
    SELECT
        avg(ws_ext_discount_amt) as avg_discount
    FROM
        web_sales ws
    JOIN
        date_dim dd
    ON
        ws.ws_sold_date_sk = dd.d_date_sk
    WHERE
        dd.d_date between '2000-02-01' and (cast('2000-02-01' as date) + interval '90' day)
)
SELECT
    sum(ws.ws_ext_discount_amt) as "Excess Discount Amount"
FROM
    web_sales ws
JOIN
    item i
ON
    ws.ws_item_sk = i.i_item_sk
JOIN
    date_dim dd
ON
    ws.ws_sold_date_sk = dd.d_date_sk
JOIN
    avg_discount ad
WHERE
    i.i_manufact_id = 714
    and dd.d_date between '2000-02-01' and (cast('2000-02-01' as date) + interval '90' day)
    and ws.ws_ext_discount_amt > 1.3 * ad.avg_discount
ORDER BY
    sum(ws.ws_ext_discount_amt)
LIMIT
    100;