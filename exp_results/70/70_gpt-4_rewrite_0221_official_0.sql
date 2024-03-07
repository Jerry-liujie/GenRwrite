with state_rank as (
    select
        s_state,
        sum(ss_net_profit) as state_profit,
        rank() over (
            partition by s_state
            order by
                sum(ss_net_profit) desc
        ) as ranking
    from
        store_sales
        join date_dim on date_dim.d_date_sk = store_sales.ss_sold_date_sk
        join store on store.s_store_sk = store_sales.ss_store_sk
    where
        d_month_seq between 1220 and 1220 + 11
    group by
        s_state
),
filtered_states as (
    select s_state from state_rank where ranking <= 5
),
sales_data as (
    select
        sum(ss_net_profit) as total_sum,
        s_state,
        s_county
    from
        store_sales
        join date_dim d1 on d1.d_date_sk = store_sales.ss_sold_date_sk
        join store on store.s_store_sk = store_sales.ss_store_sk
    where
        d1.d_month_seq between 1220 and 1220 + 11
        and s_state in (select s_state from filtered_states)
    group by
        rollup(s_state, s_county)
)
select
    total_sum,
    s_state,
    s_county,
    grouping(s_state) + grouping(s_county) as lochierarchy,
    rank() over (
        partition by lochierarchy,
        case
            when grouping(s_county) = 0 then s_state
        end
        order by
            total_sum desc
    ) as rank_within_parent
from sales_data
order by
    lochierarchy desc,
    case
        when lochierarchy = 0 then s_state
    end,
    rank_within_parent
limit 100;