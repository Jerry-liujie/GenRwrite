select
    i_item_id,
    ca_country,
    ca_state,
    ca_county,
    avg(cast(cs_quantity as decimal(12, 2))) agg1,
    avg(cast(cs_list_price as decimal(12, 2))) agg2,
    avg(cast(cs_coupon_amt as decimal(12, 2))) agg3,
    avg(cast(cs_sales_price as decimal(12, 2))) agg4,
    avg(cast(cs_net_profit as decimal(12, 2))) agg5,
    avg(cast(c_birth_year as decimal(12, 2))) agg6,
    avg(cast(cd1.cd_dep_count as decimal(12, 2))) agg7
from
    (select * from catalog_sales where cs_sold_date_sk in (select d_date_sk from date_dim where d_year = 2001)) cs,
    (select * from customer_demographics where cd_gender = 'F' and cd_education_status = 'Primary') cd1,
    customer_demographics cd2,
    (select * from customer where c_current_cdemo_sk in (select cd_demo_sk from customer_demographics) and c_current_addr_sk in (select ca_address_sk from customer_address where ca_state in ('AL', 'MO', 'TN', 'GA', 'MT', 'IN', 'CA')) and c_birth_month in (1, 3, 7, 11, 10, 4)) c,
    customer_address ca,
    item i
where
    cs.cs_item_sk = i.i_item_sk
    and cs.cs_bill_cdemo_sk = cd1.cd_demo_sk
    and cs.cs_bill_customer_sk = c.c_customer_sk
group by
    rollup (i_item_id, ca_country, ca_state, ca_county)
order by
    ca_country,
    ca_state,
    ca_county,
    i_item_id
limit
    100;