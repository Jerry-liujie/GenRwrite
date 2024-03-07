WITH avg_profit AS (
    SELECT ss_item_sk, AVG(ss_net_profit) as avg_profit
    FROM store_sales
    WHERE ss_store_sk = 4
    GROUP BY ss_item_sk
    HAVING AVG(ss_net_profit) > 0.9 * (
        SELECT AVG(ss_net_profit)
        FROM store_sales
        WHERE ss_store_sk = 4 AND ss_hdemo_sk IS NULL
        GROUP BY ss_store_sk
    )
),
ranked_profit_asc AS (
    SELECT ss_item_sk, RANK() OVER (ORDER BY avg_profit ASC) as rank
    FROM avg_profit
),
ranked_profit_desc AS (
    SELECT ss_item_sk, RANK() OVER (ORDER BY avg_profit DESC) as rank
    FROM avg_profit
),
top_10_asc AS (
    SELECT ss_item_sk, rank
    FROM ranked_profit_asc
    WHERE rank < 11
),
top_10_desc AS (
    SELECT ss_item_sk, rank
    FROM ranked_profit_desc
    WHERE rank < 11
)
SELECT asc_rank.rank, i1.i_product_name as best_performing, i2.i_product_name as worst_performing
FROM top_10_asc asc_rank
JOIN top_10_desc desc_rank ON asc_rank.rank = desc_rank.rank
JOIN item i1 ON i1.i_item_sk = asc_rank.ss_item_sk
JOIN item i2 ON i2.i_item_sk = desc_rank.ss_item_sk
ORDER BY asc_rank.rank
LIMIT 100;