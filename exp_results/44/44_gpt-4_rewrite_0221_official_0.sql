```sql
with asceding as (
    select
        ss_item_sk as item_sk,
        avg(ss_net_profit) as rank_col
    from
        store_sales ss1
    where
        ss_store_sk = 4
    group by
        ss_item_sk
    having
        avg(ss_net_profit) > 0.9 *(
            select
                avg(ss_net_profit) rank_col
            from
                store_sales
            where
                ss_store_sk = 4
                and ss_hdemo_sk is null
            group by
                ss_store_sk
        )
    order by
        rank_col asc
    limit 10
),
descending as (
    select
        ss_item_sk as item_sk,
        avg(ss_net_profit) as rank_col
    from
        store_sales ss1
    where
        ss_store_sk = 4
    group by
        ss_item_sk
    having
        avg(ss_net_profit) > 0.9 *(
            select
                avg(ss_net_profit) rank_col
            from
                store_sales
            where
                ss_store_sk = 4
                and ss_hdemo_sk is null
            group by
                ss_store_sk
        )
    order by
        rank_col desc
    limit 10
)
select
    row_number() over (order by a.rank_col) as rnk,
    i1.i_product_name as best_performing,
    i2.i_product_name as worst_performing
from
    asceding a
join
    descending d on row_number() over (order by a.rank_col) = row_number() over (order by d.rank_col)
join
    item i1 on a.item_sk = i1.i_item_sk
join
    item i2 on d.item_sk = i2.i_item_sk
order by
    rnk
limit
    100;
```