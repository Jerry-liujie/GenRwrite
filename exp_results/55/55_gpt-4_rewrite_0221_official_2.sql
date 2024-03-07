select
    i_brand_id brand_id,
    i_brand brand,
    sum(ss_ext_sales_price) ext_price
from
    store_sales
join
    item on ss_item_sk = i_item_sk
join
    date_dim on d_date_sk = ss_sold_date_sk
where
    i_manager_id = 52
    and d_moy = 11
    and d_year = 2000
group by
    i_brand,
    i_brand_id
order by
    ext_price desc,
    i_brand_id
limit
    100;