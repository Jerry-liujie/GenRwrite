with customer_total_return as (
    select
        sr_customer_sk as ctr_customer_sk,
        sr_store_sk as ctr_store_sk,
        sum(SR_FEE) as ctr_total_return
    from
        store_returns
    join date_dim on sr_returned_date_sk = d_date_sk
    where
        d_year = 2000
    group by
        sr_customer_sk,
        sr_store_sk
),
avg_return as (
    select
        ctr_store_sk,
        avg(ctr_total_return) * 1.2 as avg_return
    from
        customer_total_return
    group by
        ctr_store_sk
)
select
    c_customer_id
from
    customer_total_return ctr1
join avg_return ar on ctr1.ctr_store_sk = ar.ctr_store_sk
join store on s_store_sk = ctr1.ctr_store_sk
join customer on ctr1.ctr_customer_sk = c_customer_sk
where
    ctr1.ctr_total_return > ar.avg_return
    and s_state = 'TN'
order by
    c_customer_id
limit
    100;