```sql
select
    i_product_name,
    i_brand,
    i_class,
    i_category,
    avg(inv_quantity_on_hand) qoh
from
    (
        select 
            inv_item_sk,
            avg(inv_quantity_on_hand) as inv_quantity_on_hand
        from
            inventory
        where
            inv_date_sk between 1200 and 1200 + 11
        group by
            inv_item_sk
    ) inv,
    item i
where
    inv.inv_item_sk = i.i_item_sk
group by
    rollup(
        i.i_product_name,
        i.i_brand,
        i.i_class,
        i.i_category
    )
order by
    qoh,
    i.i_product_name,
    i.i_brand,
    i.i_class,
    i.i_category
limit
    100;
```