```
WITH sales_data AS (
    SELECT cs_item_sk, cs_promo_sk, cs_order_number, cs_quantity
    FROM catalog_sales
    JOIN date_dim d1 ON cs_sold_date_sk = d1.d_date_sk
    WHERE d1.d_year = 1998
),
inventory_data AS (
    SELECT inv_item_sk, inv_warehouse_sk, inv_quantity_on_hand
    FROM inventory
    JOIN date_dim d2 ON inv_date_sk = d2.d_date_sk
    JOIN sales_data ON inv_item_sk = sales_data.cs_item_sk
    WHERE d2.d_week_seq = d1.d_week_seq AND inv_quantity_on_hand < sales_data.cs_quantity
),
customer_data AS (
    SELECT cs_item_sk, cs_order_number
    FROM sales_data
    JOIN customer_demographics ON cs_bill_cdemo_sk = cd_demo_sk
    JOIN household_demographics ON cs_bill_hdemo_sk = hd_demo_sk
    WHERE hd_buy_potential = '1001-5000' AND cd_marital_status = 'S'
),
final_data AS (
    SELECT i_item_desc, w_warehouse_name, d1.d_week_seq, cs_promo_sk
    FROM sales_data
    JOIN inventory_data ON sales_data.cs_item_sk = inventory_data.inv_item_sk
    JOIN warehouse ON w_warehouse_sk = inventory_data.inv_warehouse_sk
    JOIN item ON i_item_sk = sales_data.cs_item_sk
    JOIN date_dim d3 ON cs_ship_date_sk = d3.d_date_sk
    LEFT OUTER JOIN promotion ON cs_promo_sk = p_promo_sk
    LEFT OUTER JOIN catalog_returns ON cr_item_sk = sales_data.cs_item_sk AND cr_order_number = sales_data.cs_order_number
    WHERE d3.d_date > d1.d_date + 5
)
SELECT i_item_desc, w_warehouse_name, d_week_seq,
    sum(case when p_promo_sk is null then 1 else 0 end) no_promo,
    sum(case when p_promo_sk is not null then 1 else 0 end) promo,
    count(*) total_cnt
FROM final_data
GROUP BY i_item_desc, w_warehouse_name, d_week_seq
ORDER BY total_cnt DESC, i_item_desc, w_warehouse_name, d_week_seq 
LIMIT 100;
```