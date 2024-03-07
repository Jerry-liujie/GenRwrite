```
WITH state_ranking AS (
    SELECT s_state, 
           RANK() OVER (PARTITION BY s_state ORDER BY SUM(ss_net_profit) DESC) as ranking
    FROM store_sales
    JOIN store ON s_store_sk = ss_store_sk
    JOIN date_dim ON d_date_sk = ss_sold_date_sk
    WHERE d_month_seq BETWEEN 1220 AND 1231
    GROUP BY s_state
),
filtered_states AS (
    SELECT s_state
    FROM state_ranking
    WHERE ranking <= 5
),
sales_data AS (
    SELECT ss_net_profit, s_state, s_county
    FROM store_sales
    JOIN date_dim d1 ON d1.d_date_sk = ss_sold_date_sk
    JOIN store ON s_store_sk = ss_store_sk
    JOIN filtered_states ON s_state = filtered_states.s_state
    WHERE d1.d_month_seq BETWEEN 1220 AND 1231
)
SELECT SUM(ss_net_profit) as total_sum, s_state, s_county, 
       grouping(s_state) + grouping(s_county) as lochierarchy, 
       rank() over (partition by grouping(s_state) + grouping(s_county), 
                    case when grouping(s_county) = 0 then s_state end 
                    order by sum(ss_net_profit) desc ) as rank_within_parent 
FROM sales_data
GROUP BY rollup(s_state, s_county) 
ORDER BY lochierarchy desc, 
         case when lochierarchy = 0 then s_state end, 
         rank_within_parent 
LIMIT 100;
```