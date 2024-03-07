```sql
select
    avg(ss_quantity),
    avg(ss_ext_sales_price),
    avg(ss_ext_wholesale_cost),
    sum(ss_ext_wholesale_cost)
from
    store_sales
join
    store on s_store_sk = ss_store_sk
join
    date_dim on ss_sold_date_sk = d_date_sk
join
    customer_demographics on cd_demo_sk = ss_cdemo_sk
join
    household_demographics on ss_hdemo_sk = hd_demo_sk
join
    customer_address on ss_addr_sk = ca_address_sk
where
    d_year = 2001
    and cd_marital_status in ('M', 'D', 'W')
    and cd_education_status in ('College', 'Primary', '2 yr Degree')
    and ss_sales_price between 50.00 and 200.00
    and hd_dep_count in (1, 3)
    and ca_country = 'United States'
    and ca_state in ('IL', 'TN', 'TX', 'WY', 'OH', 'ID', 'MS', 'SC', 'IA')
    and ss_net_profit between 50 and 300;
```