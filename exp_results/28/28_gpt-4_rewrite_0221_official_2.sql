```
select
    B1.B1_LP, B1.B1_CNT, B1.B1_CNTD, 
    B2.B2_LP, B2.B2_CNT, B2.B2_CNTD, 
    B3.B3_LP, B3.B3_CNT, B3.B3_CNTD, 
    B4.B4_LP, B4.B4_CNT, B4.B4_CNTD, 
    B5.B5_LP, B5.B5_CNT, B5.B5_CNTD, 
    B6.B6_LP, B6.B6_CNT, B6.B6_CNTD
from
    (
        select
            avg(ss_list_price) B1_LP,
            count(ss_list_price) B1_CNT,
            count(distinct ss_list_price) B1_CNTD
        from
            store_sales
        where
            ss_quantity between 0
            and 5
            and (
                ss_list_price between 107
                and 117
                or ss_coupon_amt between 1319
                and 2319
                or ss_wholesale_cost between 60
                and 80
            )
    ) B1
join
    (
        select
            avg(ss_list_price) B2_LP,
            count(ss_list_price) B2_CNT,
            count(distinct ss_list_price) B2_CNTD
        from
            store_sales
        where
            ss_quantity between 6
            and 10
            and (
                ss_list_price between 23
                and 33
                or ss_coupon_amt between 825
                and 1825
                or ss_wholesale_cost between 43
                and 63
            )
    ) B2
on 1=1
join
    (
        select
            avg(ss_list_price) B3_LP,
            count(ss_list_price) B3_CNT,
            count(distinct ss_list_price) B3_CNTD
        from
            store_sales
        where
            ss_quantity between 11
            and 15
            and (
                ss_list_price between 74
                and 84
                or ss_coupon_amt between 4381
                and 5381
                or ss_wholesale_cost between 57
                and 77
            )
    ) B3
on 1=1
join
    (
        select
            avg(ss_list_price) B4_LP,
            count(ss_list_price) B4_CNT,
            count(distinct ss_list_price) B4_CNTD
        from
            store_sales
        where
            ss_quantity between 16
            and 20
            and (
                ss_list_price between 89
                and 99
                or ss_coupon_amt between 3117
                and 4117
                or ss_wholesale_cost between 68
                and 88
            )
    ) B4
on 1=1
join
    (
        select
            avg(ss_list_price) B5_LP,
            count(ss_list_price) B5_CNT,
            count(distinct ss_list_price) B5_CNTD
        from
            store_sales
        where
            ss_quantity between 21
            and 25
            and (
                ss_list_price between 58
                and 68
                or ss_coupon_amt between 9402
                and 10402
                or ss_wholesale_cost between 38
                and 58
            )
    ) B5
on 1=1
join
    (
        select
            avg(ss_list_price) B6_LP,
            count(ss_list_price) B6_CNT,
            count(distinct ss_list_price) B6_CNTD
        from
            store_sales
        where
            ss_quantity between 26
            and 30
            and (
                ss_list_price between 64
                and 74
                or ss_coupon_amt between 5792
                and 6792
                or ss_wholesale_cost between 73
                and 93
            )
    ) B6
on 1=1
limit
    100;
```