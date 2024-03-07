```
select c_customer_id as customer_id, coalesce(c_last_name, '') || ', ' || coalesce(c_first_name, '') as customername 
from (
    select * from customer 
    where c_current_addr_sk in (
        select ca_address_sk from customer_address where ca_city = 'Woodland'
    ) 
    and c_current_cdemo_sk in (
        select cd_demo_sk from customer_demographics, store_returns where sr_cdemo_sk = cd_demo_sk
    )
    and c_current_hdemo_sk in (
        select hd_demo_sk from household_demographics, income_band where ib_lower_bound >= 60306 and ib_upper_bound <= 60306 + 50000 and ib_income_band_sk = hd_income_band_sk
    )
) as filtered_customer
order by c_customer_id limit 100;
```