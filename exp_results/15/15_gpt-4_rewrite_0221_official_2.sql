```sql
select
    ca_zip,
    sum(cs_sales_price)
from
    catalog_sales
join customer on cs_bill_customer_sk = c_customer_sk
join customer_address on c_current_addr_sk = ca_address_sk
join date_dim on cs_sold_date_sk = d_date_sk
where
    (
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
        or cs_sales_price > 500
    )
    and d_qoy = 2
    and d_year = 2001
group by
    ca_zip
order by
    ca_zip
limit
    100;
```