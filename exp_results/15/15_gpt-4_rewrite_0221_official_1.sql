```sql
select
    ca_zip,
    sum(cs_sales_price)
from
    (
        select
            cs_bill_customer_sk,
            cs_sales_price,
            cs_sold_date_sk
        from
            catalog_sales
        where
            cs_sales_price > 500
    ) cs
join
    (
        select
            c_customer_sk,
            c_current_addr_sk
        from
            customer
    ) c
on
    cs.cs_bill_customer_sk = c.c_customer_sk
join
    (
        select
            ca_address_sk,
            ca_zip
        from
            customer_address
        where
            substr(ca_zip, 1, 5) in (
                '85669',
                '86197',
                '88274',
                '83405',
                '86475',
                '85392',
                '85460',
                '80348',
                '81792'
            )
            or ca_state in ('CA', 'WA', 'GA')
    ) ca
on
    c.c_current_addr_sk = ca.ca_address_sk
join
    (
        select
            d_date_sk
        from
            date_dim
        where
            d_qoy = 2
            and d_year = 2001
    ) d
on
    cs.cs_sold_date_sk = d.d_date_sk
group by
    ca_zip
order by
    ca_zip
limit
    100;
```