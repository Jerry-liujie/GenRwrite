```sql
with ssr as (
    select
        s_store_id as store_id,
        sum(ss_ext_sales_price) as sales,
        sum(coalesce(sr_return_amt, 0)) as returns,
        sum(ss_net_profit - coalesce(sr_net_loss, 0)) as profit
    from
        store_sales
        left outer join store_returns on (
            ss_item_sk = sr_item_sk
            and ss_ticket_number = sr_ticket_number
        ),
        date_dim,
        store,
        item,
        promotion
    where
        ss_sold_date_sk = d_date_sk
        and d_date between cast('2002-08-14' as date)
        and (cast('2002-08-14' as date) + interval '30' day)
        and ss_store_sk = s_store_sk
        and ss_item_sk = i_item_sk
        and i_current_price > 50
        and ss_promo_sk = p_promo_sk
        and p_channel_tv = 'N'
    group by
        s_store_id
)
select
    'store channel' as channel,
    'store' || store_id as id,
    sum(sales) as sales,
    sum(returns) as returns,
    sum(profit) as profit
from
    ssr
group by
    channel, id
union all
select
    'catalog channel' as channel,
    'catalog_page' || catalog_page_id as id,
    sum(sales) as sales,
    sum(returns) as returns,
    sum(profit) as profit
from
    csr
group by
    channel, id
union all
select
    'web channel' as channel,
    'web_site' || web_site_id as id,
    sum(sales) as sales,
    sum(returns) as returns,
    sum(profit) as profit
from
    wsr
group by
    channel, id
order by
    channel,
    id
limit
    100;
```