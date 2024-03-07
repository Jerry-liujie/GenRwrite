```sql
select
    i_item_id,
    i_item_desc,
    i_category,
    i_class,
    i_current_price,
    itemrevenue,
    itemrevenue * 100 / sum(itemrevenue) over (partition by i_class) as revenueratio
from
    (
        select
            i_item_id,
            i_item_desc,
            i_category,
            i_class,
            i_current_price,
            sum(ws_ext_sales_price) as itemrevenue
        from
            web_sales
            join item on ws_item_sk = i_item_sk
            join date_dim on ws_sold_date_sk = d_date_sk
        where
            i_category in ('Men', 'Books', 'Electronics')
            and d_date between cast('2001-06-15' as date) and (cast('2001-06-15' as date) + interval '30' day)
        group by
            i_item_id,
            i_item_desc,
            i_category,
            i_class,
            i_current_price
    ) as subquery
order by
    i_category,
    i_class,
    i_item_id,
    i_item_desc,
    revenueratio
limit
    100;
```