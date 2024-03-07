```sql
select
    ca_state,
    cd_gender,
    cd_marital_status,
    cd_dep_count,
    count(*) cnt1,
    avg(cd_dep_count),
    stddev_samp(cd_dep_count),
    sum(cd_dep_count),
    cd_dep_employed_count,
    count(*) cnt2,
    avg(cd_dep_employed_count),
    stddev_samp(cd_dep_employed_count),
    sum(cd_dep_employed_count),
    cd_dep_college_count,
    count(*) cnt3,
    avg(cd_dep_college_count),
    stddev_samp(cd_dep_college_count),
    sum(cd_dep_college_count)
from
    customer c
    join customer_address ca on c.c_current_addr_sk = ca.ca_address_sk
    join customer_demographics cd on cd.cd_demo_sk = c.c_current_cdemo_sk
where
    exists (
        select 1
        from
            store_sales ss
            join date_dim d on ss.ss_sold_date_sk = d.d_date_sk
        where
            c.c_customer_sk = ss.ss_customer_sk
            and d.d_year = 1999
            and d.d_qoy < 4
    )
    and (
        exists (
            select 1
            from
                web_sales ws
                join date_dim d on ws.ws_sold_date_sk = d.d_date_sk
            where
                c.c_customer_sk = ws.ws_bill_customer_sk
                and d.d_year = 1999
                and d.d_qoy < 4
        )
        or exists (
            select 1
            from
                catalog_sales cs
                join date_dim d on cs.cs_sold_date_sk = d.d_date_sk
            where
                c.c_customer_sk = cs.cs_ship_customer_sk
                and d.d_year = 1999
                and d.d_qoy < 4
        )
    )
group by
    ca_state,
    cd_gender,
    cd_marital_status,
    cd_dep_count,
    cd_dep_employed_count,
    cd_dep_college_count
order by
    ca_state,
    cd_gender,
    cd_marital_status,
    cd_dep_count,
    cd_dep_employed_count,
    cd_dep_college_count
limit
    100;
```