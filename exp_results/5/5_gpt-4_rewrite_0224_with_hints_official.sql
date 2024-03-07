```
with ssr as (
    select s_store_id, sum(ss_ext_sales_price) as sales, sum(ss_net_profit) as profit, sum(sr_return_amt) as returns, sum(sr_net_loss) as profit_loss 
    from store_sales 
    left join store_returns on ss_store_sk = sr_store_sk and ss_sold_date_sk = sr_returned_date_sk
    where ss_sold_date_sk between cast('2000-08-19' as date) and (cast('2000-08-19' as date) + interval '14' day)
    group by s_store_id
), 
csr as (
    select cp_catalog_page_id, sum(cs_ext_sales_price) as sales, sum(cs_net_profit) as profit, sum(cr_return_amount) as returns, sum(cr_net_loss) as profit_loss 
    from catalog_sales 
    left join catalog_returns on cs_catalog_page_sk = cr_catalog_page_sk and cs_sold_date_sk = cr_returned_date_sk
    where cs_sold_date_sk between cast('2000-08-19' as date) and (cast('2000-08-19' as date) + interval '14' day)
    group by cp_catalog_page_id
), 
wsr as (
    select web_site_id, sum(ws_ext_sales_price) as sales, sum(ws_net_profit) as profit, sum(wr_return_amt) as returns, sum(wr_net_loss) as profit_loss 
    from web_sales 
    left join web_returns on ws_web_site_sk = wr_web_site_sk and ws_sold_date_sk = wr_returned_date_sk
    where ws_sold_date_sk between cast('2000-08-19' as date) and (cast('2000-08-19' as date) + interval '14' day)
    group by web_site_id
) 
select channel , id , sum(sales) as sales , sum(returns) as returns , sum(profit) as profit 
from (
    select 'store channel' as channel , 'store' || s_store_id as id , sales , returns , (profit - profit_loss) as profit from ssr 
    union all 
    select 'catalog channel' as channel , 'catalog_page' || cp_catalog_page_id as id , sales , returns , (profit - profit_loss) as profit from csr 
    union all 
    select 'web channel' as channel , 'web_site' || web_site_id as id , sales , returns , (profit - profit_loss) as profit from wsr 
) x 
group by rollup (channel, id) 
order by channel ,id 
limit 100;
```