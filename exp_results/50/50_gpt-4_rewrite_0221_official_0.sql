```sql
select
    s_store_name,
    s_company_id,
    s_street_number,
    s_street_name,
    s_street_type,
    s_suite_number,
    s_city,
    s_county,
    s_state,
    s_zip,
    sum(if(sr_returned_date_sk - ss_sold_date_sk <= 30, 1, 0)) as "30 days",
    sum(if((sr_returned_date_sk - ss_sold_date_sk > 30) and (sr_returned_date_sk - ss_sold_date_sk <= 60), 1, 0)) as "31-60 days",
    sum(if((sr_returned_date_sk - ss_sold_date_sk > 60) and (sr_returned_date_sk - ss_sold_date_sk <= 90), 1, 0)) as "61-90 days",
    sum(if((sr_returned_date_sk - ss_sold_date_sk > 90) and (sr_returned_date_sk - ss_sold_date_sk <= 120), 1, 0)) as "91-120 days",
    sum(if(sr_returned_date_sk - ss_sold_date_sk > 120, 1, 0)) as ">120 days"
from
    store_sales
    join store_returns on ss_ticket_number = sr_ticket_number and ss_item_sk = sr_item_sk and ss_customer_sk = sr_customer_sk
    join store on ss_store_sk = s_store_sk
    join date_dim d1 on ss_sold_date_sk = d1.d_date_sk
    join date_dim d2 on sr_returned_date_sk = d2.d_date_sk and d2.d_year = 2001 and d2.d_moy = 8
group by
    s_store_name,
    s_company_id,
    s_street_number,
    s_street_name,
    s_street_type,
    s_suite_number,
    s_city,
    s_county,
    s_state,
    s_zip
order by
    s_store_name,
    s_company_id,
    s_street_number,
    s_street_name,
    s_street_type,
    s_suite_number,
    s_city,
    s_county,
    s_state,
    s_zip
limit
    100;
```