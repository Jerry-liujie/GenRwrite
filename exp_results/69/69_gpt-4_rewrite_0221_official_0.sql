```sql
select
    cd_gender,
    cd_marital_status,
    cd_education_status,
    count(*) cnt1,
    cd_purchase_estimate,
    count(*) cnt2,
    cd_credit_rating,
    count(*) cnt3
from
    customer c
join
    customer_address ca on c.c_current_addr_sk = ca.ca_address_sk
join
    customer_demographics cd on cd_demo_sk = c.c_current_cdemo_sk
where
    ca_state in ('IL', 'TX', 'ME')
    and exists (
        select 1
        from
            store_sales ss
        join
            date_dim d on ss.ss_sold_date_sk = d.d_date_sk
        where
            c.c_customer_sk = ss.ss_customer_sk
            and d.d_year = 2002
            and d.d_moy between 1 and 3
            and not exists (
                select 1
                from
                    web_sales ws
                join
                    date_dim d2 on ws.ws_sold_date_sk = d2.d_date_sk
                where
                    c.c_customer_sk = ws.ws_bill_customer_sk
                    and d2.d_year = 2002
                    and d2.d_moy between 1 and 3
            )
            and not exists (
                select 1
                from
                    catalog_sales cs
                join
                    date_dim d3 on cs.cs_sold_date_sk = d3.d_date_sk
                where
                    c.c_customer_sk = cs.cs_ship_customer_sk
                    and d3.d_year = 2002
                    and d3.d_moy between 1 and 3
            )
    )
group by
    cd_gender,
    cd_marital_status,
    cd_education_status,
    cd_purchase_estimate,
    cd_credit_rating
order by
    cd_gender,
    cd_marital_status,
    cd_education_status,
    cd_purchase_estimate,
    cd_credit_rating
limit
    100;
```