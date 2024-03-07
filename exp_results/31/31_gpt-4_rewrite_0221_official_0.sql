```sql
with ss as (
    select
        ca_county,
        d_qoy,
        d_year,
        sum(ss_ext_sales_price) as store_sales
    from
        store_sales
    join date_dim on ss_sold_date_sk = d_date_sk
    join customer_address on ss_addr_sk = ca_address_sk
    where d_year = 1999 and d_qoy in (1,2,3)
    group by
        ca_county,
        d_qoy,
        d_year
),
ws as (
    select
        ca_county,
        d_qoy,
        d_year,
        sum(ws_ext_sales_price) as web_sales
    from
        web_sales
    join date_dim on ws_sold_date_sk = d_date_sk
    join customer_address on ws_bill_addr_sk = ca_address_sk
    where d_year = 1999 and d_qoy in (1,2,3)
    group by
        ca_county,
        d_qoy,
        d_year
)
select
    ss1.ca_county,
    ss1.d_year,
    ws2.web_sales / ws1.web_sales web_q1_q2_increase,
    ss2.store_sales / ss1.store_sales store_q1_q2_increase,
    ws3.web_sales / ws2.web_sales web_q2_q3_increase,
    ss3.store_sales / ss2.store_sales store_q2_q3_increase
from
    ss ss1
join ss ss2 on ss1.ca_county = ss2.ca_county
join ss ss3 on ss2.ca_county = ss3.ca_county
join ws ws1 on ss1.ca_county = ws1.ca_county
join ws ws2 on ws1.ca_county = ws2.ca_county
join ws ws3 on ws2.ca_county = ws3.ca_county
where
    ss1.d_qoy = 1
    and ss2.d_qoy = 2
    and ss3.d_qoy = 3
    and ws1.d_qoy = 1
    and ws2.d_qoy = 2
    and ws3.d_qoy = 3
    and ws2.web_sales / ws1.web_sales > ss2.store_sales / ss1.store_sales
    and ws3.web_sales / ws2.web_sales > ss3.store_sales / ss2.store_sales
order by
    ss3.store_sales / ss2.store_sales;
```