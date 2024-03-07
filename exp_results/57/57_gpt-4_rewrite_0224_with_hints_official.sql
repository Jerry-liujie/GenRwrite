```
with v1 as( 
    select 
        i.i_category, 
        i.i_brand, 
        cc.cc_name, 
        d.d_year, 
        d.d_moy, 
        sum(cs.cs_sales_price) sum_sales, 
        avg(sum(cs.cs_sales_price)) over (partition by i.i_category, i.i_brand, cc.cc_name, d.d_year) avg_monthly_sales, 
        rank() over (partition by i.i_category, i.i_brand, cc.cc_name order by d.d_year, d.d_moy) rn 
    from 
        item i
        join catalog_sales cs on cs.cs_item_sk = i.i_item_sk
        join date_dim d on cs.cs_sold_date_sk = d.d_date_sk
        join call_center cc on cc.cc_call_center_sk= cs.cs_call_center_sk 
    where 
        d.d_year in (2001, 2000, 2002) and d.d_moy in (12, 1)
    group by 
        i.i_category, i.i_brand, cc.cc_name , d.d_year, d.d_moy
), 
v2 as( 
    select 
        v1.i_category, 
        v1.i_brand, 
        v1.cc_name ,
        v1.d_year ,
        v1.avg_monthly_sales ,
        v1.sum_sales, 
        v1_lag.sum_sales psum, 
        v1_lead.sum_sales nsum 
    from 
        v1
        join v1 v1_lag on v1.i_category = v1_lag.i_category and v1.i_brand = v1_lag.i_brand and v1.cc_name = v1_lag.cc_name and v1.rn = v1_lag.rn + 1
        join v1 v1_lead on v1.i_category = v1_lead.i_category and v1.i_brand = v1_lead.i_brand and v1.cc_name = v1_lead.cc_name and v1.rn = v1_lead.rn - 1
) 
select * 
from v2 
where 
    d_year = 2001 
    and avg_monthly_sales > 0 
    and abs(sum_sales - avg_monthly_sales) / avg_monthly_sales > 0.1 
order by 
    sum_sales - avg_monthly_sales, 
    avg_monthly_sales 
limit 100;
```