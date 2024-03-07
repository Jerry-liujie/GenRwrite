```sql
select
    B1_LP, B1_CNT, B1_CNTD, B2_LP, B2_CNT, B2_CNTD, B3_LP, B3_CNT, B3_CNTD, B4_LP, B4_CNT, B4_CNTD, B5_LP, B5_CNT, B5_CNTD, B6_LP, B6_CNT, B6_CNTD
from
    (
        select
            avg(case when ss_quantity between 0 and 5 then ss_list_price end) as B1_LP,
            count(case when ss_quantity between 0 and 5 then ss_list_price end) as B1_CNT,
            count(distinct case when ss_quantity between 0 and 5 then ss_list_price end) as B1_CNTD,
            avg(case when ss_quantity between 6 and 10 then ss_list_price end) as B2_LP,
            count(case when ss_quantity between 6 and 10 then ss_list_price end) as B2_CNT,
            count(distinct case when ss_quantity between 6 and 10 then ss_list_price end) as B2_CNTD,
            avg(case when ss_quantity between 11 and 15 then ss_list_price end) as B3_LP,
            count(case when ss_quantity between 11 and 15 then ss_list_price end) as B3_CNT,
            count(distinct case when ss_quantity between 11 and 15 then ss_list_price end) as B3_CNTD,
            avg(case when ss_quantity between 16 and 20 then ss_list_price end) as B4_LP,
            count(case when ss_quantity between 16 and 20 then ss_list_price end) as B4_CNT,
            count(distinct case when ss_quantity between 16 and 20 then ss_list_price end) as B4_CNTD,
            avg(case when ss_quantity between 21 and 25 then ss_list_price end) as B5_LP,
            count(case when ss_quantity between 21 and 25 then ss_list_price end) as B5_CNT,
            count(distinct case when ss_quantity between 21 and 25 then ss_list_price end) as B5_CNTD,
            avg(case when ss_quantity between 26 and 30 then ss_list_price end) as B6_LP,
            count(case when ss_quantity between 26 and 30 then ss_list_price end) as B6_CNT,
            count(distinct case when ss_quantity between 26 and 30 then ss_list_price end) as B6_CNTD
        from
            store_sales
        where
            (
                ss_list_price between 23 and 117
                or ss_coupon_amt between 825 and 10319
                or ss_wholesale_cost between 38 and 88
            )
    ) as subquery
limit
    100;
```