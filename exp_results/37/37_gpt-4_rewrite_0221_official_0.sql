```sql
select
    i_item_id,
    i_item_desc,
    i_current_price
from
    item
join
    inventory on inv_item_sk = i_item_sk
join
    date_dim on d_date_sk = inv_date_sk
join
    catalog_sales on cs_item_sk = i_item_sk
where
    i_current_price between 29 and 59
    and d_date between '2002-03-29' and '2002-05-28'
    and i_manufact_id in (705, 742, 777, 944)
    and inv_quantity_on_hand between 100 and 500
group by
    i_item_id,
    i_item_desc,
    i_current_price
order by
    i_item_id
limit
    100;
```