```
SELECT i_item_id, AVG(ss_quantity) agg1, AVG(ss_list_price) agg2, AVG(ss_coupon_amt) agg3, AVG(ss_sales_price) agg4
FROM (
    SELECT ss_item_sk, ss_quantity, ss_list_price, ss_coupon_amt, ss_sales_price
    FROM store_sales
    WHERE ss_sold_date_sk IN (
        SELECT d_date_sk
        FROM date_dim
        WHERE d_year = 2001
    )
    AND ss_cdemo_sk IN (
        SELECT cd_demo_sk
        FROM customer_demographics
        WHERE cd_gender = 'F' AND cd_marital_status = 'W' AND cd_education_status = 'College'
    )
    AND ss_promo_sk IN (
        SELECT p_promo_sk
        FROM promotion
        WHERE p_channel_email = 'N' OR p_channel_event = 'N'
    )
) AS filtered_sales
JOIN item ON ss_item_sk = i_item_sk
GROUP BY i_item_id
ORDER BY i_item_id
LIMIT 100;
```