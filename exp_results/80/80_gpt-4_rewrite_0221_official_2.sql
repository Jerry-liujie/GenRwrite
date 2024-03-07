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
        )
    where
        ss_sold_date_sk in (
            select d_date_sk from date_dim where d_date between cast('2002-08-14' as date)
            and (cast('2002-08-14' as date) + interval '30' day)
        )
        and ss_item_sk in (
            select i_item_sk from item where i_current_price > 50
        )
        and ss_promo_sk in (
            select p_promo_sk from promotion where p_channel_tv = 'N'
        )
    group by
        s_store_id
),
csr as (
    -- similar changes as ssr
),
wsr as (
    -- similar changes as ssr
)
select
    channel,
    id,
    sum(sales) as sales,
    sum(returns) as returns,
    sum(profit) as profit
from
    (
        select
            'store channel' as channel,
            'store' || store_id as id,
            sales,
            returns,
            profit
        from
            ssr
        union
        all
        select
            'catalog channel' as channel,
            'catalog_page' || catalog_page_id as id,
            sales,
            returns,
            profit
        from
            csr
        union
        all
        select
            'web channel' as channel,
            'web_site' || web_site_id as id,
            sales,
            returns,
            profit
        from
            wsr
    ) x
group by
    rollup (channel, id)
order by
    channel,
    id
limit
    100;
```