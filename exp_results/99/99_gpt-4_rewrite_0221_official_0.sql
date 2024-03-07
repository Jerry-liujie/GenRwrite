```
select
    substr(w_warehouse_name, 1, 20),
    sm_type,
    cc_name,
    sum(is_30_days) as "30 days",
    sum(is_31_60_days) as "31-60 days",
    sum(is_61_90_days) as "61-90 days",
    sum(is_91_120_days) as "91-120 days",
    sum(is_over_120_days) as ">120 days"
from
(
    select
        cs_warehouse_sk,
        cs_ship_mode_sk,
        cs_call_center_sk,
        case
            when (cs_ship_date_sk - cs_sold_date_sk <= 30) then 1
            else 0
        end as is_30_days,
        case
            when (cs_ship_date_sk - cs_sold_date_sk > 30)
            and (cs_ship_date_sk - cs_sold_date_sk <= 60) then 1
            else 0
        end as is_31_60_days,
        case
            when (cs_ship_date_sk - cs_sold_date_sk > 60)
            and (cs_ship_date_sk - cs_sold_date_sk <= 90) then 1
            else 0
        end as is_61_90_days,
        case
            when (cs_ship_date_sk - cs_sold_date_sk > 90)
            and (cs_ship_date_sk - cs_sold_date_sk <= 120) then 1
            else 0
        end as is_91_120_days,
        case
            when (cs_ship_date_sk - cs_sold_date_sk > 120) then 1
            else 0
        end as is_over_120_days
    from
        catalog_sales
    where
        cs_ship_date_sk between 1194 and 1194 + 11
) cs
join warehouse w on cs.cs_warehouse_sk = w.w_warehouse_sk
join ship_mode sm on cs.cs_ship_mode_sk = sm.sm_ship_mode_sk
join call_center cc on cs.cs_call_center_sk = cc.cc_call_center_sk
group by
    substr(w.w_warehouse_name, 1, 20),
    sm.sm_type,
    cc.cc_name
order by
    substr(w.w_warehouse_name, 1, 20),
    sm.sm_type,
    cc.cc_name
limit
    100;
```