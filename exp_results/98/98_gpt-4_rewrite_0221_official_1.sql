```sql
select
    i_item_id,
    i_item_desc,
    i_category,
    i_class,
    i_current_price,
    sum(ss_ext_sales_price) as itemrevenue,
    sum(ss_ext_sales_price) * 100 / sum(sum(ss_ext_sales_price)) over (partition by i_class) as revenueratio
from
    (select * from store_sales where ss_sold_date_sk between cast('1999-02-05' as date) and (cast('1999-02-05' as date) + interval '30' day)) as store_sales,
    (select * from item where i_category in ('Men', 'Sports', 'Jewelry')) as item,
    date_dim
where
    ss_item_sk = i_item_sk
    and ss_sold_date_sk = d_date_sk
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
    revenueratio;
```