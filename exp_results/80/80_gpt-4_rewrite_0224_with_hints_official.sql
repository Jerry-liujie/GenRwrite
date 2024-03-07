```
SELECT 
    CASE 
        WHEN ss_store_id IS NOT NULL THEN 'store channel'
        WHEN cp_catalog_page_id IS NOT NULL THEN 'catalog channel'
        WHEN web_site_id IS NOT NULL THEN 'web channel'
    END AS channel,
    COALESCE('store' || ss_store_id, 'catalog_page' || cp_catalog_page_id, 'web_site' || web_site_id) AS id,
    SUM(sales) AS sales,
    SUM(returns) AS returns,
    SUM(profit) AS profit
FROM 
(
    SELECT 
        ss_store_id, 
        cp_catalog_page_id, 
        web_site_id, 
        sum(ss_ext_sales_price) as sales, 
        sum(coalesce(sr_return_amt, 0)) as returns, 
        sum(ss_net_profit - coalesce(sr_net_loss, 0)) as profit 
    FROM 
        store_sales 
        LEFT OUTER JOIN store_returns ON (ss_item_sk = sr_item_sk and ss_ticket_number = sr_ticket_number)
        LEFT OUTER JOIN catalog_sales ON ss_item_sk = cs_item_sk
        LEFT OUTER JOIN catalog_returns ON (cs_item_sk = cr_item_sk and cs_order_number = cr_order_number)
        LEFT OUTER JOIN web_sales ON ss_item_sk = ws_item_sk
        LEFT OUTER JOIN web_returns ON (ws_item_sk = wr_item_sk and ws_order_number = wr_order_number)
        , date_dim, store, item, promotion 
    WHERE 
        ss_sold_date_sk = d_date_sk 
        AND d_date between cast('2002-08-14' as date) and (cast('2002-08-14' as date) + interval '30' day) 
        AND ss_store_sk = s_store_sk 
        AND ss_item_sk = i_item_sk 
        AND i_current_price > 50 
        AND ss_promo_sk = p_promo_sk 
        AND p_channel_tv = 'N' 
    GROUP BY 
        ss_store_id, cp_catalog_page_id, web_site_id
) x 
GROUP BY 
    ROLLUP (channel, id) 
ORDER BY 
    channel, id 
LIMIT 100;
```