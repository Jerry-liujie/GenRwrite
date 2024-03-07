```sql
select
    i_item_id,
    i_item_desc,
    i_current_price
from
    item
join
    (select 
        inv_item_sk
    from
        inventory
    join
        date_dim on d_date_sk = inv_date_sk
    where
        d_date between cast('2002-03-29' as date)
        and (cast('2002-03-29' as date) + interval '60' day)
        and inv_quantity_on_hand between 100
        and 500) as inv on inv_item_sk = i_item_sk
join
    catalog_sales on cs_item_sk = i_item_sk
where
    i_current_price between 29
    and 29 + 30
    and i_manufact_id in (705, 742, 777, 944)
group by
    i_item_id,
    i_item_desc,
    i_current_price
order by
    i_item_id
limit
    100;
```