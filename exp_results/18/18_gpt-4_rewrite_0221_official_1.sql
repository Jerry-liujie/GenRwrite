```
select
    i_item_id,
    ca_country,
    ca_state,
    ca_county,
    avg(cs_quantity) agg1,
    avg(cs_list_price) agg2,
    avg(cs_coupon_amt) agg3,
    avg(cs_sales_price) agg4,
    avg(cs_net_profit) agg5,
    avg(c_birth_year) agg6,
    avg(cd1.cd_dep_count) agg7
from
    (select * from catalog_sales where cs_sold_date_sk = d_date_sk and cs_item_sk = i_item_sk and cs_bill_cdemo_sk = cd1.cd_demo_sk and cs_bill_customer_sk = c_customer_sk) cs,
    (select * from customer_demographics where cd_gender = 'F' and cd_education_status = 'Primary') cd1,
    customer_demographics cd2,
    (select * from customer where c_current_cdemo_sk = cd2.cd_demo_sk and c_current_addr_sk = ca_address_sk and c_birth_month in (1, 3, 7, 11, 10, 4)) c,
    customer_address,
    date_dim,
    item
where
    d_year = 2001
    and ca_state in (
        'AL',
        'MO',
        'TN',
        'GA',
        'MT',
        'IN',
        'CA'
    )
group by
    rollup (i_item_id, ca_country, ca_state, ca_county)
order by
    ca_country,
    ca_state,
    ca_county,
    i_item_id
limit
    100;
```