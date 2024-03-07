```
with inv as (
    select
        w_warehouse_sk,
        i_item_sk,
        d_moy,
        stddev_samp(inv_quantity_on_hand) as stdev,
        avg(inv_quantity_on_hand) as mean
    from
        inventory
    join item on inv_item_sk = i_item_sk
    join warehouse on inv_warehouse_sk = w_warehouse_sk
    join date_dim on inv_date_sk = d_date_sk and d_year = 2000
    group by
        w_warehouse_sk,
        i_item_sk,
        d_moy
    having
        avg(inv_quantity_on_hand) != 0 and stddev_samp(inv_quantity_on_hand) / avg(inv_quantity_on_hand) > 1
)
select
    inv1.w_warehouse_sk,
    inv1.i_item_sk,
    inv1.d_moy,
    inv1.mean,
    stddev_samp(inv1.inv_quantity_on_hand) / avg(inv1.inv_quantity_on_hand) as cov1,
    inv2.w_warehouse_sk,
    inv2.i_item_sk,
    inv2.d_moy,
    inv2.mean,
    stddev_samp(inv2.inv_quantity_on_hand) / avg(inv2.inv_quantity_on_hand) as cov2
from
    inv as inv1
join inv as inv2 on inv1.i_item_sk = inv2.i_item_sk and inv1.w_warehouse_sk = inv2.w_warehouse_sk and inv1.d_moy = 1 and inv2.d_moy = 2
where
    stddev_samp(inv1.inv_quantity_on_hand) / avg(inv1.inv_quantity_on_hand) > 1.5
order by
    inv1.w_warehouse_sk,
    inv1.i_item_sk,
    inv1.d_moy,
    inv1.mean,
    stddev_samp(inv1.inv_quantity_on_hand) / avg(inv1.inv_quantity_on_hand),
    inv2.d_moy,
    inv2.mean,
    stddev_samp(inv2.inv_quantity_on_hand) / avg(inv2.inv_quantity_on_hand);
```