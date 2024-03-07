```sql
select
    substr(w_warehouse_name, 1, 20),
    sm_type,
    cc_name,
    count(case when (cs_ship_date_sk - cs_sold_date_sk <= 30) then 1 end) as "30 days",
    count(case when (cs_ship_date_sk - cs_sold_date_sk > 30) and (cs_ship_date_sk - cs_sold_date_sk <= 60) then 1 end) as "31-60 days",
    count(case when (cs_ship_date_sk - cs_sold_date_sk > 60) and (cs_ship_date_sk - cs_sold_date_sk <= 90) then 1 end) as "61-90 days",
    count(case when (cs_ship_date_sk - cs_sold_date_sk > 90) and (cs_ship_date_sk - cs_sold_date_sk <= 120) then 1 end) as "91-120 days",
    count(case when (cs_ship_date_sk - cs_sold_date_sk > 120) then 1 end) as ">120 days"
from
    catalog_sales
    join warehouse on cs_warehouse_sk = w_warehouse_sk
    join ship_mode on cs_ship_mode_sk = sm_ship_mode_sk
    join call_center on cs_call_center_sk = cc_call_center_sk
    join date_dim on cs_ship_date_sk = d_date_sk and d_month_seq between 1194 and 1194 + 11
group by
    substr(w_warehouse_name, 1, 20),
    sm_type,
    cc_name
order by
    substr(w_warehouse_name, 1, 20),
    sm_type,
    cc_name
limit
    100;
```