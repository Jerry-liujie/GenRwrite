```sql
select
    c_last_name,
    c_first_name,
    substr(s_city, 1, 30),
    ss_ticket_number,
    amt,
    profit
from
    (
        select
            ss_ticket_number,
            ss_customer_sk,
            s_city,
            sum(ss_coupon_amt) as amt,
            sum(ss_net_profit) as profit
        from
            store_sales
        join date_dim on store_sales.ss_sold_date_sk = date_dim.d_date_sk
        join store on store_sales.ss_store_sk = store.s_store_sk
        join household_demographics on store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
        where
            (household_demographics.hd_dep_count = 7 or household_demographics.hd_vehicle_count > -1)
            and date_dim.d_dow = 1
            and date_dim.d_year in (2000, 2001, 2002)
            and store.s_number_employees between 200 and 295
        group by
            ss_ticket_number,
            ss_customer_sk,
            s_city
    ) ms
join customer on ms.ss_customer_sk = customer.c_customer_sk
order by
    c_last_name,
    c_first_name,
    substr(s_city, 1, 30),
    profit
limit
    100;
```