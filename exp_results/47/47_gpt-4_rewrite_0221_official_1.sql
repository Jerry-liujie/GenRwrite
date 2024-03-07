```sql
with v1 as(
    select
        i_category,
        i_brand,
        s_store_name,
        s_company_name,
        d_year,
        d_moy,
        sum(ss_sales_price) sum_sales,
        avg(sum(ss_sales_price)) over (
            partition by i_category,
            i_brand,
            s_store_name,
            s_company_name,
            d_year
        ) avg_monthly_sales
    from
        item
    join store_sales on ss_item_sk = i_item_sk
    join date_dim on ss_sold_date_sk = d_date_sk
    join store on ss_store_sk = s_store_sk
    where
        d_year in (1999, 2000, 2001) and
        (d_year != 1999 or d_moy = 12) and
        (d_year != 2001 or d_moy = 1)
    group by
        i_category,
        i_brand,
        s_store_name,
        s_company_name,
        d_year,
        d_moy
),
v2 as(
    select
        v1.*,
        lag(sum_sales) over (partition by i_category, i_brand, s_store_name, s_company_name order by d_year, d_moy) as psum,
        lead(sum_sales) over (partition by i_category, i_brand, s_store_name, s_company_name order by d_year, d_moy) as nsum
    from
        v1
)
select
    *
from
    v2
where
    d_year = 2000
    and avg_monthly_sales > 0
    and abs(sum_sales - avg_monthly_sales) / avg_monthly_sales > 0.1
order by
    sum_sales - avg_monthly_sales,
    nsum
limit
    100;
```