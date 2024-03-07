```
SELECT 
    i_item_id, 
    AVG(sub.cs_quantity) agg1, 
    AVG(sub.cs_list_price) agg2, 
    AVG(sub.cs_coupon_amt) agg3, 
    AVG(sub.cs_sales_price) agg4 
FROM 
    (SELECT 
        cs_item_sk, 
        cs_quantity, 
        cs_list_price, 
        cs_coupon_amt, 
        cs_sales_price 
    FROM 
        catalog_sales 
    WHERE 
        cs_sold_date_sk IN (SELECT d_date_sk FROM date_dim WHERE d_year = 2002) 
        AND cs_bill_cdemo_sk IN (SELECT cd_demo_sk FROM customer_demographics WHERE cd_gender = 'M' AND cd_marital_status = 'W' AND cd_education_status = 'Unknown') 
        AND cs_promo_sk IN (SELECT p_promo_sk FROM promotion WHERE p_channel_email = 'N' OR p_channel_event = 'N')
    ) sub 
JOIN 
    item ON sub.cs_item_sk = i_item_sk 
GROUP BY 
    i_item_id 
ORDER BY 
    i_item_id 
LIMIT 100;
```