```
with inv as (
    select 
        w_warehouse_name,
        w_warehouse_sk,
        i_item_sk,
        d_moy,
        stddev_samp(inv_quantity_on_hand) as stdev,
        avg(inv_quantity_on_hand) as mean,
        case mean when 0 then null else stdev/mean end as cov
    from 
        inventory 
        join item on inv_item_sk = i_item_sk 
        join warehouse on inv_warehouse_sk = w_warehouse_sk 
        join date_dim on inv_date_sk = d_date_sk 
    where 
        d_year = 2000 
    group by 
        w_warehouse_name,
        w_warehouse_sk,
        i_item_sk,
        d_moy
    having 
        mean != 0 and stdev/mean > 1
)
select 
    inv1.w_warehouse_sk,
    inv1.i_item_sk,
    inv1.d_moy,
    inv1.mean, 
    inv1.cov,
    inv2.w_warehouse_sk,
    inv2.i_item_sk,
    inv2.d_moy,
    inv2.mean, 
    inv2.cov 
from 
    inv inv1
    join inv inv2 on inv1.i_item_sk = inv2.i_item_sk and inv1.w_warehouse_sk = inv2.w_warehouse_sk and inv1.d_moy = 1 and inv2.d_moy = 2
where 
    inv1.cov > 1.5 
order by 
    inv1.w_warehouse_sk,
    inv1.i_item_sk,
    inv1.d_moy,
    inv1.mean,
    inv1.cov,
    inv2.d_moy,
    inv2.mean, 
    inv2.cov;
```