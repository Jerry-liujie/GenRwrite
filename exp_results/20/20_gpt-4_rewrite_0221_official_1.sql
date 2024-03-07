```sql
select
    i_item_id,
    i_item_desc,
    i_category,
    i_class,
    i_current_price,
    sum(cs_ext_sales_price) as itemrevenue,
    sum(cs_ext_sales_price) * 100 / sum(sum(cs_ext_sales_price)) over (partition by i_class) as revenueratio
from
    (select cs_item_sk, cs_ext_sales_price
    from catalog_sales
    where cs_sold_date_sk in 
        (select d_date_sk 
        from date_dim 
        where d_date between cast('2002-06-18' as date) and (cast('2002-06-18' as date) + interval '30' day))
    ) cs,
    (select i_item_sk, i_item_id, i_item_desc, i_category, i_class, i_current_price
    from item
    where i_category in ('Books', 'Music', 'Sports')
    ) i
where
    cs.cs_item_sk = i.i_item_sk
group by
    i_item_id,
    i_item_desc,
    i_category,
    i_class,
    i_current_price
order by
    i_category,
    i_class,
    i_item_id,
    i_item_desc,
    revenueratio
limit
    100;
```