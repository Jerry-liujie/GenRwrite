```
with sales_data as (
    select
        cs_warehouse_sk,
        cs_item_sk,
        cs_order_number,
        cs_sales_price,
        d_date
    from
        catalog_sales
        join date_dim on cs_sold_date_sk = d_date_sk
    where
        d_date between (cast ('2001-05-02' as date) - interval '30' day)
        and (cast ('2001-05-02' as date) + interval '30' day)
),
returns_data as (
    select
        cr_order_number,
        cr_item_sk,
        cr_refunded_cash
    from
        catalog_returns
),
item_data as (
    select
        i_item_sk,
        i_item_id,
        i_current_price
    from
        item
    where
        i_current_price between 0.99 and 1.49
)
select
    w_state,
    i_item_id,
    sum(
        case
            when (
                cast(d_date as date) < cast ('2001-05-02' as date)
            ) then cs_sales_price - coalesce(cr_refunded_cash, 0)
            else 0
        end
    ) as sales_before,
    sum(
        case
            when (
                cast(d_date as date) >= cast ('2001-05-02' as date)
            ) then cs_sales_price - coalesce(cr_refunded_cash, 0)
            else 0
        end
    ) as sales_after
from
    sales_data
    left outer join returns_data on (
        sales_data.cs_order_number = returns_data.cr_order_number
        and sales_data.cs_item_sk = returns_data.cr_item_sk
    )
    join item_data on sales_data.cs_item_sk = item_data.i_item_sk
    join warehouse on sales_data.cs_warehouse_sk = warehouse.w_warehouse_sk
group by
    w_state,
    i_item_id
order by
    w_state,
    i_item_id
limit
    100;
```