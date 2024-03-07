```sql
with cross_items as (
    select i_item_sk ss_item_sk 
    from item
    join (
        select iss.i_brand_id brand_id, iss.i_class_id class_id, iss.i_category_id category_id 
        from store_sales 
        join item iss on ss_item_sk = iss.i_item_sk
        join date_dim d1 on ss_sold_date_sk = d1.d_date_sk and d1.d_year between 1999 and 2001
        intersect 
        select ics.i_brand_id, ics.i_class_id, ics.i_category_id 
        from catalog_sales 
        join item ics on cs_item_sk = ics.i_item_sk
        join date_dim d2 on cs_sold_date_sk = d2.d_date_sk and d2.d_year between 1999 and 2001
        intersect 
        select iws.i_brand_id, iws.i_class_id, iws.i_category_id 
        from web_sales 
        join item iws on ws_item_sk = iws.i_item_sk
        join date_dim d3 on ws_sold_date_sk = d3.d_date_sk and d3.d_year between 1999 and 2001
    ) as tmp on i_brand_id = brand_id and i_class_id = class_id and i_category_id = category_id 
),
avg_sales as (
    select avg(quantity*list_price) average_sales 
    from (
        select ss_quantity quantity, ss_list_price list_price 
        from store_sales 
        join date_dim on ss_sold_date_sk = d_date_sk and d_year between 1999 and 2001
        union all 
        select cs_quantity quantity, cs_list_price list_price 
        from catalog_sales 
        join date_dim on cs_sold_date_sk = d_date_sk and d_year between 1999 and 2001
        union all 
        select ws_quantity quantity, ws_list_price list_price 
        from web_sales 
        join date_dim on ws_sold_date_sk = d_date_sk and d_year between 1999 and 2001
    ) x
)
select channel, i_brand_id, i_class_id, i_category_id, sum(sales), sum(number_sales) 
from (
    select 'store' channel, i_brand_id, i_class_id, i_category_id, sum(ss_quantity*ss_list_price) sales, count(*) number_sales 
    from store_sales 
    join item on ss_item_sk = i_item_sk and ss_item_sk in (select ss_item_sk from cross_items)
    join date_dim on ss_sold_date_sk = d_date_sk and d_year = 2001 and d_moy = 11 
    group by i_brand_id, i_class_id, i_category_id 
    having sum(ss_quantity*ss_list_price) > (select average_sales from avg_sales)
    union all 
    select 'catalog' channel, i_brand_id, i_class_id, i_category_id, sum(cs_quantity*cs_list_price) sales, count(*) number_sales 
    from catalog_sales 
    join item on cs_item_sk = i_item_sk and cs_item_sk in (select ss_item_sk from cross_items)
    join date_dim on cs_sold_date_sk = d_date_sk and d_year = 2001 and d_moy = 11 
    group by i_brand_id, i_class_id, i_category_id 
    having sum(cs_quantity*cs_list_price) > (select average_sales from avg_sales)
    union all 
    select 'web' channel, i_brand_id, i_class_id, i_category_id, sum(ws_quantity*ws_list_price) sales, count(*) number_sales 
    from web_sales 
    join item on ws_item_sk = i_item_sk and ws_item_sk in (select ss_item_sk from cross_items)
    join date_dim on ws_sold_date_sk = d_date_sk and d_year = 2001 and d_moy = 11 
    group by i_brand_id, i_class_id, i_category_id 
    having sum(ws_quantity*ws_list_price) > (select average_sales from avg_sales)
) y 
group by rollup (channel, i_brand_id, i_class_id, i_category_id) 
order by channel, i_brand_id, i_class_id, i_category_id 
limit 100;
```