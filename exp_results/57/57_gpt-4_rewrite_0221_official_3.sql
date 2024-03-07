```sql
with v1 as(
    select
        i_category,
        i_brand,
        cc_name,
        d_year,
        d_moy,
        sum(cs_sales_price) sum_sales,
        avg(sum(cs_sales_price)) over (
            partition by i_category,
            i_brand,
            cc_name,
            d_year
        ) avg_monthly_sales,
        rank() over (
            partition by i_category,
            i_brand,
            cc_name
            order by
                d_year,
                d_moy
        ) rn
    from
        item
    join catalog_sales on cs_item_sk = i_item_sk
    join date_dim on cs_sold_date_sk = d_date_sk
    join call_center on cc_call_center_sk = cs_call_center_sk
    where
        (
            d_year = 2001
            or (
                d_year = 2001 -1
                and d_moy = 12
            )
            or (
                d_year = 2001 + 1
                and d_moy = 1
            )
        )
    group by
        i_category,
        i_brand,
        cc_name,
        d_year,
        d_moy
)
select
    *
from
    v1
where
    d_year = 2001
    and avg_monthly_sales > 0
    and abs(sum_sales - avg_monthly_sales) / avg_monthly_sales > 0.1
order by
    sum_sales - avg_monthly_sales,
    avg_monthly_sales
limit
    100;
```