```
WITH web AS (
    SELECT 'web' as channel, ws.ws_item_sk as item,
    (cast(sum(coalesce(wr.wr_return_quantity,0)) as decimal(15,4))/ cast(sum(coalesce(ws.ws_quantity,0)) as decimal(15,4))) as return_ratio,
    (cast(sum(coalesce(wr.wr_return_amt,0)) as decimal(15,4))/ cast(sum(coalesce(ws.ws_net_paid,0)) as decimal(15,4))) as currency_ratio
    FROM web_sales ws
    LEFT OUTER JOIN web_returns wr ON (ws.ws_order_number = wr.wr_order_number and ws.ws_item_sk = wr.wr_item_sk)
    WHERE wr.wr_return_amt > 10000 AND ws.ws_net_profit > 1 AND ws.ws_net_paid > 0 AND ws.ws_quantity > 0 AND ws_sold_date_sk = d_date_sk AND d_year = 1998 AND d_moy = 11
    GROUP BY ws.ws_item_sk
),
catalog AS (
    SELECT 'catalog' as channel, cs.cs_item_sk as item,
    (cast(sum(coalesce(cr.cr_return_quantity,0)) as decimal(15,4))/ cast(sum(coalesce(cs.cs_quantity,0)) as decimal(15,4))) as return_ratio,
    (cast(sum(coalesce(cr.cr_return_amount,0)) as decimal(15,4))/ cast(sum(coalesce(cs.cs_net_paid,0)) as decimal(15,4))) as currency_ratio
    FROM catalog_sales cs
    LEFT OUTER JOIN catalog_returns cr ON (cs.cs_order_number = cr.cr_order_number and cs.cs_item_sk = cr.cr_item_sk)
    WHERE cr.cr_return_amount > 10000 AND cs.cs_net_profit > 1 AND cs.cs_net_paid > 0 AND cs.cs_quantity > 0 AND cs_sold_date_sk = d_date_sk AND d_year = 1998 AND d_moy = 11
    GROUP BY cs.cs_item_sk
),
store AS (
    SELECT 'store' as channel, sts.ss_item_sk as item,
    (cast(sum(coalesce(sr.sr_return_quantity,0)) as decimal(15,4))/cast(sum(coalesce(sts.ss_quantity,0)) as decimal(15,4))) as return_ratio,
    (cast(sum(coalesce(sr.sr_return_amt,0)) as decimal(15,4))/cast(sum(coalesce(sts.ss_net_paid,0)) as decimal(15,4))) as currency_ratio
    FROM store_sales sts
    LEFT OUTER JOIN store_returns sr ON (sts.ss_ticket_number = sr.sr_ticket_number and sts.ss_item_sk = sr.sr_item_sk)
    WHERE sr.sr_return_amt > 10000 AND sts.ss_net_profit > 1 AND sts.ss_net_paid > 0 AND sts.ss_quantity > 0 AND ss_sold_date_sk = d_date_sk AND d_year = 1998 AND d_moy = 11
    GROUP BY sts.ss_item_sk
)
SELECT channel, item, return_ratio, rank() over (order by return_ratio) as return_rank, rank() over (order by currency_ratio) as currency_rank
FROM (SELECT * FROM web UNION SELECT * FROM catalog UNION SELECT * FROM store) AS tmp
WHERE return_rank <= 10 OR currency_rank <= 10
ORDER BY 1,4,5,2
LIMIT 100;
```