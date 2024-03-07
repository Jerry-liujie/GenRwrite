```
select
    (select avg(ss_list_price) from store_sales where ss_quantity between 0 and 5 and (ss_list_price between 107 and 117 or ss_coupon_amt between 1319 and 2319 or ss_wholesale_cost between 60 and 80)) as B1_LP,
    (select count(ss_list_price) from store_sales where ss_quantity between 0 and 5 and (ss_list_price between 107 and 117 or ss_coupon_amt between 1319 and 2319 or ss_wholesale_cost between 60 and 80)) as B1_CNT,
    (select count(distinct ss_list_price) from store_sales where ss_quantity between 0 and 5 and (ss_list_price between 107 and 117 or ss_coupon_amt between 1319 and 2319 or ss_wholesale_cost between 60 and 80)) as B1_CNTD,
    (select avg(ss_list_price) from store_sales where ss_quantity between 6 and 10 and (ss_list_price between 23 and 33 or ss_coupon_amt between 825 and 1825 or ss_wholesale_cost between 43 and 63)) as B2_LP,
    (select count(ss_list_price) from store_sales where ss_quantity between 6 and 10 and (ss_list_price between 23 and 33 or ss_coupon_amt between 825 and 1825 or ss_wholesale_cost between 43 and 63)) as B2_CNT,
    (select count(distinct ss_list_price) from store_sales where ss_quantity between 6 and 10 and (ss_list_price between 23 and 33 or ss_coupon_amt between 825 and 1825 or ss_wholesale_cost between 43 and 63)) as B2_CNTD,
    (select avg(ss_list_price) from store_sales where ss_quantity between 11 and 15 and (ss_list_price between 74 and 84 or ss_coupon_amt between 4381 and 5381 or ss_wholesale_cost between 57 and 77)) as B3_LP,
    (select count(ss_list_price) from store_sales where ss_quantity between 11 and 15 and (ss_list_price between 74 and 84 or ss_coupon_amt between 4381 and 5381 or ss_wholesale_cost between 57 and 77)) as B3_CNT,
    (select count(distinct ss_list_price) from store_sales where ss_quantity between 11 and 15 and (ss_list_price between 74 and 84 or ss_coupon_amt between 4381 and 5381 or ss_wholesale_cost between 57 and 77)) as B3_CNTD,
    (select avg(ss_list_price) from store_sales where ss_quantity between 16 and 20 and (ss_list_price between 89 and 99 or ss_coupon_amt between 3117 and 4117 or ss_wholesale_cost between 68 and 88)) as B4_LP,
    (select count(ss_list_price) from store_sales where ss_quantity between 16 and 20 and (ss_list_price between 89 and 99 or ss_coupon_amt between 3117 and 4117 or ss_wholesale_cost between 68 and 88)) as B4_CNT,
    (select count(distinct ss_list_price) from store_sales where ss_quantity between 16 and 20 and (ss_list_price between 89 and 99 or ss_coupon_amt between 3117 and 4117 or ss_wholesale_cost between 68 and 88)) as B4_CNTD,
    (select avg(ss_list_price) from store_sales where ss_quantity between 21 and 25 and (ss_list_price between 58 and 68 or ss_coupon_amt between 9402 and 10402 or ss_wholesale_cost between 38 and 58)) as B5_LP,
    (select count(ss_list_price) from store_sales where ss_quantity between 21 and 25 and (ss_list_price between 58 and 68 or ss_coupon_amt between 9402 and 10402 or ss_wholesale_cost between 38 and 58)) as B5_CNT,
    (select count(distinct ss_list_price) from store_sales where ss_quantity between 21 and 25 and (ss_list_price between 58 and 68 or ss_coupon_amt between 9402 and 10402 or ss_wholesale_cost between 38 and 58)) as B5_CNTD,
    (select avg(ss_list_price) from store_sales where ss_quantity between 26 and 30 and (ss_list_price between 64 and 74 or ss_coupon_amt between 5792 and 6792 or ss_wholesale_cost between 73 and 93)) as B6_LP,
    (select count(ss_list_price) from store_sales where ss_quantity between 26 and 30 and (ss_list_price between 64 and 74 or ss_coupon_amt between 5792 and 6792 or ss_wholesale_cost between 73 and 93)) as B6_CNT,
    (select count(distinct ss_list_price) from store_sales where ss_quantity between 26 and 30 and (ss_list_price between 64 and 74 or ss_coupon_amt between 5792 and 6792 or ss_wholesale_cost between 73 and 93)) as B6_CNTD
limit 100;
```