```sql
with my_customers as (
    select
        distinct c_customer_sk,
        c_current_addr_sk
    from
        catalog_sales
        join item on cs_item_sk = i_item_sk
        join date_dim on cs_sold_date_sk = d_date_sk
        join customer on c_customer_sk = cs_bill_customer_sk
    where
        i_category = 'Music'
        and i_class = 'country'
        and d_moy = 1
        and d_year = 1999
    union
    select
        distinct c_customer_sk,
        c_current_addr_sk
    from
        web_sales
        join item on ws_item_sk = i_item_sk
        join date_dim on ws_sold_date_sk = d_date_sk
        join customer on c_customer_sk = ws_bill_customer_sk
    where
        i_category = 'Music'
        and i_class = 'country'
        and d_moy = 1
        and d_year = 1999
),
my_revenue as (
    select
        c_customer_sk,
        sum(ss_ext_sales_price) as revenue
    from
        my_customers
        join store_sales on c_customer_sk = ss_customer_sk
        join customer_address on c_current_addr_sk = ca_address_sk
        join store on ca_county = s_county and ca_state = s_state
        join date_dim on ss_sold_date_sk = d_date_sk
    where
        d_month_seq between (
            select
                distinct d_month_seq + 1
            from
                date_dim
            where
                d_year = 1999
                and d_moy = 1
        )
        and (
            select
                distinct d_month_seq + 3
            from
                date_dim
            where
                d_year = 1999
                and d_moy = 1
        )
    group by
        c_customer_sk
),
segments as (
    select
        cast((revenue / 50) as int) as segment
    from
        my_revenue
)
select
    segment,
    count(*) as num_customers,
    segment * 50 as segment_base
from
    segments
group by
    segment
order by
    segment,
    num_customers
limit
    100;
```