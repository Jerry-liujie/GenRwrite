```
WITH b1 AS (
    SELECT avg(ss_list_price) b1_lp, count(ss_list_price) b1_cnt, count(distinct ss_list_price) b1_cntd 
    FROM store_sales 
    WHERE ss_quantity BETWEEN 0 AND 5 
    AND ( ss_list_price BETWEEN 107 AND 117 OR ss_coupon_amt BETWEEN 1319 AND 2319 OR ss_wholesale_cost BETWEEN 60 AND 80 )
), 
b2 AS (
    SELECT avg(ss_list_price) b2_lp, count(ss_list_price) b2_cnt, count(distinct ss_list_price) b2_cntd 
    FROM store_sales 
    WHERE ss_quantity BETWEEN 6 AND 10 
    AND ( ss_list_price BETWEEN 23 AND 33 OR ss_coupon_amt BETWEEN 825 AND 1825 OR ss_wholesale_cost BETWEEN 43 AND 63 )
),
b3 AS (
    SELECT avg(ss_list_price) b3_lp, count(ss_list_price) b3_cnt, count(distinct ss_list_price) b3_cntd 
    FROM store_sales 
    WHERE ss_quantity BETWEEN 11 AND 15 
    AND ( ss_list_price BETWEEN 74 AND 84 OR ss_coupon_amt BETWEEN 4381 AND 5381 OR ss_wholesale_cost BETWEEN 57 AND 77 )
),
b4 AS (
    SELECT avg(ss_list_price) b4_lp, count(ss_list_price) b4_cnt, count(distinct ss_list_price) b4_cntd 
    FROM store_sales 
    WHERE ss_quantity BETWEEN 16 AND 20 
    AND ( ss_list_price BETWEEN 89 AND 99 OR ss_coupon_amt BETWEEN 3117 AND 4117 OR ss_wholesale_cost BETWEEN 68 AND 88 )
),
b5 AS (
    SELECT avg(ss_list_price) b5_lp, count(ss_list_price) b5_cnt, count(distinct ss_list_price) b5_cntd 
    FROM store_sales 
    WHERE ss_quantity BETWEEN 21 AND 25 
    AND ( ss_list_price BETWEEN 58 AND 68 OR ss_coupon_amt BETWEEN 9402 AND 10402 OR ss_wholesale_cost BETWEEN 38 AND 58 )
),
b6 AS (
    SELECT avg(ss_list_price) b6_lp, count(ss_list_price) b6_cnt, count(distinct ss_list_price) b6_cntd 
    FROM store_sales 
    WHERE ss_quantity BETWEEN 26 AND 30 
    AND ( ss_list_price BETWEEN 64 AND 74 OR ss_coupon_amt BETWEEN 5792 AND 6792 OR ss_wholesale_cost BETWEEN 73 AND 93 )
)
SELECT * FROM b1, b2, b3, b4, b5, b6 LIMIT 100;
```