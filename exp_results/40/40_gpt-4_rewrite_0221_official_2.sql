```
select
    w_state,
    i_item_id,
    sum(
        case
            when (
                d_date < '2001-05-02'
            ) then cs_sales_price - coalesce(cr_refunded_cash, 0)
            else 0
        end
    ) as sales_before,
    sum(
        case
            when (
                d_date >= '2001-05-02'
            ) then cs_sales_price - coalesce(cr_refunded_cash, 0)
            else 0
        end
    ) as sales_after
from
    (
        select 
            cs_sales_price,
            cr_refunded_cash,
            cs_order_number,
            cs_item_sk,
            cs_warehouse_sk,
            cs_sold_date_sk
        from
            catalog_sales
            left outer join catalog_returns on (
                cs_order_number = cr_order_number
                and cs_item_sk = cr_item_sk
            )
        where
            cs_sold_date_sk between date '2001-05-02' - interval '30' day
            and date '2001-05-02' + interval '30' day
    ) sales_returns,
    warehouse,
    (
        select 
            i_item_id,
            i_item_sk,
            i_current_price
        from
            item
        where
            i_current_price between 0.99
            and 1.49
    ) item_filtered,
    date_dim
where
    i_item_sk = cs_item_sk
    and cs_warehouse_sk = w_warehouse_sk
    and cs_sold_date_sk = d_date_sk
group by
    w_state,
    i_item_id
order by
    w_state,
    i_item_id
limit
    100;
```