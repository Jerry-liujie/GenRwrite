```sql
with asceding as (
    select
        ss_item_sk item_sk,
        avg(ss_net_profit) rank_col,
        rank() over (order by avg(ss_net_profit) asc) rnk
    from
        store_sales ss1
    where
        ss_store_sk = 4
    group by
        ss_item_sk
    having
        avg(ss_net_profit) > 0.9 * (
            select
                avg(ss_net_profit)
            from
                store_sales
            where
                ss_store_sk = 4
                and ss_hdemo_sk is null
            group by
                ss_store_sk
        )
),
descending as (
    select
        ss_item_sk item_sk,
        avg(ss_net_profit) rank_col,
        rank() over (order by avg(ss_net_profit) desc) rnk
    from
        store_sales ss1
    where
        ss_store_sk = 4
    group by
        ss_item_sk
    having
        avg(ss_net_profit) > 0.9 * (
            select
                avg(ss_net_profit)
            from
                store_sales
            where
                ss_store_sk = 4
                and ss_hdemo_sk is null
            group by
                ss_store_sk
        )
)
select
    asceding.rnk,
    i1.i_product_name best_performing,
    i2.i_product_name worst_performing
from
    asceding
    join item i1 on i1.i_item_sk = asceding.item_sk
    join descending on asceding.rnk = descending.rnk
    join item i2 on i2.i_item_sk = descending.item_sk
where
    asceding.rnk < 11
    and descending.rnk < 11
order by
    asceding.rnk
limit
    100;
```