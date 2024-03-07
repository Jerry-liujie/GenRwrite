WITH sales_returns AS (
    SELECT 
        ss_item_sk, 
        ss_ticket_number, 
        ss_customer_sk, 
        COALESCE((ss_quantity - sr_return_quantity) * ss_sales_price, ss_quantity * ss_sales_price) AS act_sales
    FROM 
        store_sales 
    LEFT OUTER JOIN 
        store_returns 
    ON 
        sr_item_sk = ss_item_sk 
        AND sr_ticket_number = ss_ticket_number 
        AND sr_reason_sk = r_reason_sk 
        AND r_reason_desc = 'reason 58'
)
SELECT 
    ss_customer_sk, 
    SUM(act_sales) AS sumsales 
FROM 
    sales_returns 
GROUP BY 
    ss_customer_sk 
ORDER BY 
    sumsales, ss_customer_sk 
LIMIT 100;