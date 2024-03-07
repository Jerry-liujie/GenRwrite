```sql
select
    c_last_name,
    c_first_name,
    c_salutation,
    c_preferred_cust_flag,
    dj.ss_ticket_number,
    dj.cnt
from
    (
        select
            ss_ticket_number,
            ss_customer_sk,
            count(*) as cnt
        from
            store_sales
        join date_dim on store_sales.ss_sold_date_sk = date_dim.d_date_sk
        join store on store_sales.ss_store_sk = store.s_store_sk
        join household_demographics on store_sales.ss_hdemo_sk = household_demographics.hd_demo_sk
        where
            date_dim.d_dom between 1 and 2
            and household_demographics.hd_buy_potential in ('1001-5000', '5001-10000')
            and household_demographics.hd_vehicle_count > 0
            and household_demographics.hd_dep_count / household_demographics.hd_vehicle_count > 1
            and date_dim.d_year between 2000 and 2002
            and store.s_county = 'Williamson County'
        group by
            ss_ticket_number,
            ss_customer_sk
    ) dj
join customer on dj.ss_customer_sk = c_customer_sk
where
    dj.cnt between 1 and 5
order by
    dj.cnt desc,
    c_last_name asc;
```