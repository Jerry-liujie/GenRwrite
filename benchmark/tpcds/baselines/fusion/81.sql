with
    customer_total_return as (
        select
            cr_returning_customer_sk as ctr_customer_sk,
            ca_state as ctr_state,
            sum(cr_return_amt_inc_tax) as ctr_total_return
        from
            catalog_returns
            join date_dim on cr_returned_date_sk = d_date_sk
            join customer_address on cr_returning_addr_sk = ca_address_sk
        where
            d_year = 2001
        group by
            cr_returning_customer_sk,
            ca_state
    ),
    avg_return as (
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
    ca_street_number,
    ca_street_name,
    ca_street_type,
    ca_suite_number,
    ca_city,
    ca_county,
    ca_state,
    ca_zip,
    ca_country,
    ca_gmt_offset,
    ca_location_type,
    ctr_total_return
from
    customer_total_return ctr1
    join customer on ctr1.ctr_customer_sk = c_customer_sk
    join customer_address on ca_address_sk = c_current_addr_sk
    join avg_return on ctr1.ctr_state = avg_return.ctr_state
where
    ctr1.ctr_total_return > avg_return
    and ca_state = 'TN'
order by
    c_customer_id,
    c_salutation,
    c_first_name,
    c_last_name,
    ca_street_number,
    ca_street_name,
    ca_street_type,
    ca_suite_number,
    ca_city,
    ca_county,
    ca_state,
    ca_zip,
    ca_country,
    ca_gmt_offset,
    ca_location_type,
    ctr_total_return
limit
    100;