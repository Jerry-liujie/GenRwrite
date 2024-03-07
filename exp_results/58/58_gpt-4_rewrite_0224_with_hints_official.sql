```sql
with week_seq as (select d_week_seq from date_dim where d_date = '2001-06-16'),
     ss_items as (select i_item_id as item_id, sum(ss_ext_sales_price) as ss_item_rev 
                  from store_sales 
                  join item on ss_item_sk = i_item_sk 
                  join date_dim on ss_sold_date_sk = d_date_sk 
                  where d_week_seq = (select * from week_seq) 
                  group by i_item_id),
     cs_items as (select i_item_id as item_id, sum(cs_ext_sales_price) as cs_item_rev 
                  from catalog_sales 
                  join item on cs_item_sk = i_item_sk 
                  join date_dim on cs_sold_date_sk = d_date_sk 
                  where d_week_seq = (select * from week_seq) 
                  group by i_item_id),
     ws_items as (select i_item_id as item_id, sum(ws_ext_sales_price) as ws_item_rev 
                  from web_sales 
                  join item on ws_item_sk = i_item_sk 
                  join date_dim on ws_sold_date_sk = d_date_sk 
                  where d_week_seq = (select * from week_seq) 
                  group by i_item_id)
select ss_items.item_id, ss_item_rev, ss_item_rev/average * 100 as ss_dev, 
       cs_item_rev, cs_item_rev/average * 100 as cs_dev, 
       ws_item_rev, ws_item_rev/average * 100 as ws_dev, 
       average 
from ss_items 
join cs_items on ss_items.item_id = cs_items.item_id 
join ws_items on ss_items.item_id = ws_items.item_id 
cross join (select (ss_item_rev + cs_item_rev + ws_item_rev) / 3 as average 
            from ss_items, cs_items, ws_items 
            where ss_items.item_id = cs_items.item_id and ss_items.item_id = ws_items.item_id) as avg 
where ss_item_rev between 0.9 * cs_item_rev and 1.1 * cs_item_rev 
and ss_item_rev between 0.9 * ws_item_rev and 1.1 * ws_item_rev 
and cs_item_rev between 0.9 * ss_item_rev and 1.1 * ss_item_rev 
and cs_item_rev between 0.9 * ws_item_rev and 1.1 * ws_item_rev 
and ws_item_rev between 0.9 * ss_item_rev and 1.1 * ss_item_rev 
and ws_item_rev between 0.9 * cs_item_rev and 1.1 * cs_item_rev 
order by item_id, ss_item_rev 
limit 100;
```