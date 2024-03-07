with my_customers as (
    select
        distinct c_customer_sk,
        c_current_addr_sk
    from
        customer
    where
        c_customer_sk in (
            select
                cs_bill_customer_sk
            from
                catalog_sales
            where
                cs_sold_date_sk in (
                    select
                        d_date_sk
                    from
                        date_dim
                    where
                        d_moy = 1
                        and d_year = 1999
                )
                and cs_item_sk in (
                    select
                        i_item_sk
                    from
                        item
                    where
                        i_category = 'Music'
                        and i_class = 'country'
                )
            union
            all
            select
                ws_bill_customer_sk
            from
                web_sales
            where
                ws_sold_date_sk in (
                    select
                        d_date_sk
                    from
                        date_dim
                    where
                        d_moy = 1
                        and d_year = 1999
                )
                and ws_item_sk in (
                    select
                        i_item_sk
                    from
                        item
                    where
                        i_category = 'Music'
                        and i_class = 'country'
                )
        )
),
my_revenue as (
    select
        c_customer_sk,
        sum(ss_ext_sales_price) as revenue
    from
        store_sales
    where
        ss_sold_date_sk in (
            select
                d_date_sk
            from
                date_dim
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
        )
        and ss_customer_sk in (
            select
                c_customer_sk
            from
                my_customers
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