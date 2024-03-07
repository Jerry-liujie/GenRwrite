```sql
select
    i_item_id,
    i_item_desc,
    i_category,
    i_class,
    i_current_price,
    sum(ws_ext_sales_price) as itemrevenue,
    sum(ws_ext_sales_price) * 100 / sum(sum(ws_ext_sales_price)) over (partition by i_class) as revenueratio
from
    (select 
        ws_item_sk,
        ws_ext_sales_price
    from
        web_sales
    where
        ws_sold_date_sk in 
        (select 
            d_date_sk
        from
            date_dim
        where
            d_date between cast('2001-06-15' as date) and (cast('2001-06-15' as date) + interval '30' day))
    ) ws
join
    item i
on
    ws.ws_item_sk = i.i_item_sk
where
    i.i_category in ('Men', 'Books', 'Electronics')
group by
    i.i_item_id,
    i.i_item_desc,
    i.i_category,
    i.i_class,
    i.i_current_price
order by
    i.i_category,
    i.i_class,
    i.i_item_id,
    i.i_item_desc,
    revenueratio
limit
    100;
```