```
select
    i_item_id,
    i_item_desc,
    i_current_price
from
    item i
join
    inventory inv on inv.inv_item_sk = i.i_item_sk
join
    date_dim d on d.d_date_sk = inv.inv_date_sk
join
    store_sales ss on ss.ss_item_sk = i.i_item_sk
where
    i.i_current_price between 58 and 88
    and d.d_date between cast('2001-01-13' as date) and (cast('2001-01-13' as date) + interval '60' day)
    and i.i_manufact_id in (259, 559, 580, 485)
    and inv.inv_quantity_on_hand between 100 and 500
group by
    i.i_item_id,
    i.i_item_desc,
    i.i_current_price
order by
    i.i_item_id
limit
    100;
```