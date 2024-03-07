```sql
select
    substr(r_reason_desc, 1, 20),
    avg(ws_quantity),
    avg(wr_refunded_cash),
    avg(wr_fee)
from
    web_sales
    join web_returns on ws_web_page_sk = wp_web_page_sk and ws_item_sk = wr_item_sk and ws_order_number = wr_order_number
    join web_page on ws_web_page_sk = wp_web_page_sk
    join customer_demographics cd1 on cd1.cd_demo_sk = wr_refunded_cdemo_sk
    join customer_demographics cd2 on cd2.cd_demo_sk = wr_returning_cdemo_sk
    join customer_address on ca_address_sk = wr_refunded_addr_sk
    join date_dim on ws_sold_date_sk = d_date_sk
    join reason on r_reason_sk = wr_reason_sk
where
    d_year = 1998
    and cd1.cd_marital_status = cd2.cd_marital_status
    and cd1.cd_education_status = cd2.cd_education_status
    and ws_sales_price between 100.00 and 150.00
    and ca_country = 'United States'
    and ws_net_profit between 100 and 200
group by
    r_reason_desc
order by
    substr(r_reason_desc, 1, 20),
    avg(ws_quantity),
    avg(wr_refunded_cash),
    avg(wr_fee)
limit
    100;
```