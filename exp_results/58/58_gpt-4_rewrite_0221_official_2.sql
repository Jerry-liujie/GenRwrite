```sql
with weekly_sales as (
    select
        i_item_id as item_id,
        sum(case when ss_sold_date_sk = d_date_sk then ss_ext_sales_price else 0 end) as ss_item_rev,
        sum(case when cs_sold_date_sk = d_date_sk then cs_ext_sales_price else 0 end) as cs_item_rev,
        sum(case when ws_sold_date_sk = d_date_sk then ws_ext_sales_price else 0 end) as ws_item_rev
    from
        item
        left join store_sales on ss_item_sk = i_item_sk
        left join catalog_sales on cs_item_sk = i_item_sk
        left join web_sales on ws_item_sk = i_item_sk
        join date_dim on d_date_sk in (ss_sold_date_sk, cs_sold_date_sk, ws_sold_date_sk)
    where
        d_week_seq = (
            select
                d_week_seq
            from
                date_dim
            where
                d_date = '2001-06-16'
        )
    group by
        i_item_id
)
select
    item_id,
    ss_item_rev,
    ss_item_rev /((ss_item_rev + cs_item_rev + ws_item_rev) / 3) * 100 ss_dev,
    cs_item_rev,
    cs_item_rev /((ss_item_rev + cs_item_rev + ws_item_rev) / 3) * 100 cs_dev,
    ws_item_rev,
    ws_item_rev /((ss_item_rev + cs_item_rev + ws_item_rev) / 3) * 100 ws_dev,
(ss_item_rev + cs_item_rev + ws_item_rev) / 3 average
from
    weekly_sales
where
    ss_item_rev between 0.9 * cs_item_rev and 1.1 * cs_item_rev
    and ss_item_rev between 0.9 * ws_item_rev and 1.1 * ws_item_rev
    and cs_item_rev between 0.9 * ss_item_rev and 1.1 * ss_item_rev
    and cs_item_rev between 0.9 * ws_item_rev and 1.1 * ws_item_rev
    and ws_item_rev between 0.9 * ss_item_rev and 1.1 * ss_item_rev
    and ws_item_rev between 0.9 * cs_item_rev and 1.1 * cs_item_rev
order by
    item_id,
    ss_item_rev
limit
    100;
```