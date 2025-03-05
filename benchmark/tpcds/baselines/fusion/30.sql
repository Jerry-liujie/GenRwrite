with
    customer_total_return as (
        select
            wr_returning_customer_sk as ctr_customer_sk,
            ca_state as ctr_state,
            sum(wr_return_amt) as ctr_total_return
        from
            web_returns
            join date_dim on wr_returned_date_sk = d_date_sk
            join customer_address on wr_returning_addr_sk = ca_address_sk
        where
            d_year = 2000
        group by
            wr_returning_customer_sk,
            ca_state
    ),
    avg_returns as (
        select
            ctr_state,
            avg(ctr_total_return) * 1.2 as avg_return
        from
            customer_total_return
        group by
            ctr_state
    )
select
    c_customer_id,
    c_salutation,
    c_first_name,
    c_last_name,
    c_preferred_cust_flag,
    c_birth_day,
    c_birth_month,
    c_birth_year,
    c_birth_country,
    c_login,
    c_email_address,
    c_last_review_date_sk,
    ctr_total_return
from
    customer_total_return ctr1
    join customer on ctr1.ctr_customer_sk = c_customer_sk
    join customer_address on c_current_addr_sk = ca_address_sk
    join avg_returns on ctr1.ctr_state = avg_returns.ctr_state
where
    ctr1.ctr_total_return > avg_returns.avg_return
    and ca_state = 'AR'
order by
    c_customer_id,
    c_salutation,
    c_first_name,
    c_last_name,
    c_preferred_cust_flag,
    c_birth_day,
    c_birth_month,
    c_birth_year,
    c_birth_country,
    c_login,
    c_email_address,
    c_last_review_date_sk,
    ctr_total_return
limit
    100;