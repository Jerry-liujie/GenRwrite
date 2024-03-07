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
        join date_dim on ss_sold_date_sk = d_date_sk
        join item on ss_item_sk = i_item_sk
        join promotion on ss_promo_sk = p_promo_sk
    where
        d_date between cast('2002-08-14' as date)
        and (cast('2002-08-14' as date) + interval '30' day)
        and i_current_price > 50
        and p_channel_tv = 'N'
    group by
        s_store_id
)
union all
select
    'catalog channel' as channel,
    'catalog_page' || cp_catalog_page_id as id,
    sum(cs_ext_sales_price) as sales,
    sum(coalesce(cr_return_amount, 0)) as returns,
    sum(cs_net_profit - coalesce(cr_net_loss, 0)) as profit
from
    catalog_sales
    left outer join catalog_returns on (
        cs_item_sk = cr_item_sk
        and cs_order_number = cr_order_number
    )
    join date_dim on cs_sold_date_sk = d_date_sk
    join item on cs_item_sk = i_item_sk
    join promotion on cs_promo_sk = p_promo_sk
where
    d_date between cast('2002-08-14' as date)
    and (cast('2002-08-14' as date) + interval '30' day)
    and i_current_price > 50
    and p_channel_tv = 'N'
group by
    cp_catalog_page_id
union all
select
    'web channel' as channel,
    'web_site' || web_site_id as id,
    sum(ws_ext_sales_price) as sales,
    sum(coalesce(wr_return_amt, 0)) as returns,
    sum(ws_net_profit - coalesce(wr_net_loss, 0)) as profit
from
    web_sales
    left outer join web_returns on (
        ws_item_sk = wr_item_sk
        and ws_order_number = wr_order_number
    )
    join date_dim on ws_sold_date_sk = d_date_sk
    join item on ws_item_sk = i_item_sk
    join promotion on ws_promo_sk = p_promo_sk
where
    d_date between cast('2002-08-14' as date)
    and (cast('2002-08-14' as date) + interval '30' day)
    and i_current_price > 50
    and p_channel_tv = 'N'
group by
    web_site_id
order by
    channel,
    id
limit
    100;
```