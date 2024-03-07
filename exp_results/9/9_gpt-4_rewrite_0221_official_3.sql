```
with 
    bucket1 as (
        select count(*) as count, avg(ss_ext_tax) as avg_ext_tax, avg(ss_net_paid_inc_tax) as avg_net_paid 
        from store_sales where ss_quantity between 1 and 20
    ),
    bucket2 as (
        select count(*) as count, avg(ss_ext_tax) as avg_ext_tax, avg(ss_net_paid_inc_tax) as avg_net_paid 
        from store_sales where ss_quantity between 21 and 40
    ),
    bucket3 as (
        select count(*) as count, avg(ss_ext_tax) as avg_ext_tax, avg(ss_net_paid_inc_tax) as avg_net_paid 
        from store_sales where ss_quantity between 41 and 60
    ),
    bucket4 as (
        select count(*) as count, avg(ss_ext_tax) as avg_ext_tax, avg(ss_net_paid_inc_tax) as avg_net_paid 
        from store_sales where ss_quantity between 61 and 80
    ),
    bucket5 as (
        select count(*) as count, avg(ss_ext_tax) as avg_ext_tax, avg(ss_net_paid_inc_tax) as avg_net_paid 
        from store_sales where ss_quantity between 81 and 100
    )
select
    case when bucket1.count > 1071 then bucket1.avg_ext_tax else bucket1.avg_net_paid end,
    case when bucket2.count > 39161 then bucket2.avg_ext_tax else bucket2.avg_net_paid end,
    case when bucket3.count > 29434 then bucket3.avg_ext_tax else bucket3.avg_net_paid end,
    case when bucket4.count > 6568 then bucket4.avg_ext_tax else bucket4.avg_net_paid end,
    case when bucket5.count > 21216 then bucket5.avg_ext_tax else bucket5.avg_net_paid end
from
    reason, bucket1, bucket2, bucket3, bucket4, bucket5
where
    r_reason_sk = 1;
```