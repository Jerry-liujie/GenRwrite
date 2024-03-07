```
select
    promotions,
    total,
    cast(promotions as decimal(15, 4)) / cast(total as decimal(15, 4)) * 100
from
    (
        select
            sum(case when p_channel_dmail = 'Y' or p_channel_email = 'Y' or p_channel_tv = 'Y' then ss_ext_sales_price else 0 end) as promotions,
            sum(ss_ext_sales_price) as total
        from
            store_sales
            join store on ss_store_sk = s_store_sk
            join date_dim on ss_sold_date_sk = d_date_sk
            join customer on ss_customer_sk = c_customer_sk
            join customer_address on ca_address_sk = c_current_addr_sk
            join item on ss_item_sk = i_item_sk
            left join promotion on ss_promo_sk = p_promo_sk
        where
            ca_gmt_offset = -7
            and i_category = 'Home'
            and s_gmt_offset = -7
            and d_year = 2000
            and d_moy = 12
    ) sales
order by
    promotions,
    total
limit
    100;
```