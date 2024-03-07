WITH web_v1 as (
    select
        ws_item_sk as item_sk,
        d_date,
        sum(ws_sales_price) over (
            partition by ws_item_sk
            order by d_date
        ) as cume_sales
    from
        web_sales
    join date_dim on ws_sold_date_sk = d_date_sk
    where
        d_month_seq between 1212 and 1223
        and ws_item_sk is not null
    group by ws_item_sk, d_date
),
store_v1 as (
    select
        ss_item_sk as item_sk,
        d_date,
        sum(ss_sales_price) over (
            partition by ss_item_sk
            order by d_date
        ) as cume_sales
    from
        store_sales
    join date_dim on ss_sold_date_sk = d_date_sk
    where
        d_month_seq between 1212 and 1223
        and ss_item_sk is not null
    group by ss_item_sk, d_date
)
select
    item_sk,
    d_date,
    web_sales,
    store_sales,
    max(web_sales) over (
        partition by item_sk
        order by d_date
    ) as web_cumulative,
    max(store_sales) over (
        partition by item_sk
        order by d_date
    ) as store_cumulative
from
    web_v1
full outer join store_v1 on web_v1.item_sk = store_v1.item_sk and web_v1.d_date = store_v1.d_date
where
    web_cumulative > store_cumulative
order by item_sk, d_date
limit 100;