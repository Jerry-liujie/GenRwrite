with A1 as (
    SELECT
        substr(ca_zip, 1, 5) ca_zip,
        count(*) cnt
    FROM
        customer_address,
        customer
    WHERE
        ca_address_sk = c_current_addr_sk
        and c_preferred_cust_flag = 'Y'
    group by
        ca_zip
    having
        count(*) > 10
),
A2 as (
    SELECT
        substr(ca_zip, 1, 5) ca_zip
    FROM
        customer_address
    WHERE
        substr(ca_zip, 1, 5) IN (
            '47602',
            '16704',
            '35863',
            ...
            '15475'
        )
),
V1 as (
    select
        ca_zip
    from
        A2
    intersect
    select
        ca_zip
    from
        A1
)
select
    s_store_name,
    sum(ss_net_profit)
from
    store_sales
    join date_dim on ss_sold_date_sk = d_date_sk
    join store on ss_store_sk = s_store_sk
    join V1 on substr(s_zip, 1, 2) = substr(V1.ca_zip, 1, 2)
where
    d_qoy = 2
    and d_year = 1998
group by
    s_store_name
order by
    s_store_name
limit
    100;