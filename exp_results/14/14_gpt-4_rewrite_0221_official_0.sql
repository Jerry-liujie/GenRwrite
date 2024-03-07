```sql
with cross_items as (
    select
        i_item_sk ss_item_sk
    from
        item
    where
        (i_brand_id, i_class_id, i_category_id) in (
            select
                iss.i_brand_id,
                iss.i_class_id,
                iss.i_category_id
            from
                store_sales
                join item iss on ss_item_sk = iss.i_item_sk
                join date_dim d1 on ss_sold_date_sk = d1.d_date_sk
            where
                d1.d_year between 1999 and 1999 + 2
            intersect
            select
                ics.i_brand_id,
                ics.i_class_id,
                ics.i_category_id
            from
                catalog_sales
                join item ics on cs_item_sk = ics.i_item_sk
                join date_dim d2 on cs_sold_date_sk = d2.d_date_sk
            where
                d2.d_year between 1999 and 1999 + 2
            intersect
            select
                iws.i_brand_id,
                iws.i_class_id,
                iws.i_category_id
            from
                web_sales
                join item iws on ws_item_sk = iws.i_item_sk
                join date_dim d3 on ws_sold_date_sk = d3.d_date_sk
            where
                d3.d_year between 1999 and 1999 + 2
        )
)
...
```