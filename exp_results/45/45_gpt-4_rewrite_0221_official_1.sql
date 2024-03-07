```
with item_ids as (
    select i_item_id
    from item
    where i_item_sk in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29)
)
select
    ca_zip,
    ca_city,
    sum(ws_sales_price)
from
    web_sales
    join customer on ws_bill_customer_sk = c_customer_sk
    join customer_address on c_current_addr_sk = ca_address_sk
    join date_dim on ws_sold_date_sk = d_date_sk
    join item on ws_item_sk = i_item_sk
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
        or i_item_id in (select i_item_id from item_ids)
    )
    and d_qoy = 1
    and d_year = 2000
group by
    ca_zip,
    ca_city
order by
    ca_zip,
    ca_city
limit
    100;
```