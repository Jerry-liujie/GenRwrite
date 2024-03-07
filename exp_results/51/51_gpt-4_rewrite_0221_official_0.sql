```sql
WITH web_v1 as (
    select
        ws_item_sk as item_sk,
        d_date,
        sum(ws_sales_price) over (
            partition by ws_item_sk
            order by d_date rows unbounded preceding
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
            order by d_date rows unbounded preceding
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
    coalesce(web.item_sk, store.item_sk) as item_sk,
    coalesce(web.d_date, store.d_date) as d_date,
    web.cume_sales as web_sales,
    store.cume_sales as store_sales
from
    web_v1 as web
full outer join store_v1 as store on web.item_sk = store.item_sk and web.d_date = store.d_date
where
    web.cume_sales > store.cume_sales
order by item_sk, d_date
limit 100;
```