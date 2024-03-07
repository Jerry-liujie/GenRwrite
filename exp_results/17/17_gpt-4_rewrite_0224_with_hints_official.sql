```sql
SELECT 
    i_item_id, 
    i_item_desc, 
    s_state, 
    count(ss.ss_quantity) as store_sales_quantitycount, 
    avg(ss.ss_quantity) as store_sales_quantityave, 
    stddev_samp(ss.ss_quantity) as store_sales_quantitystdev, 
    stddev_samp(ss.ss_quantity) / avg(ss.ss_quantity) as store_sales_quantitycov, 
    count(sr.sr_return_quantity) as store_returns_quantitycount, 
    avg(sr.sr_return_quantity) as store_returns_quantityave, 
    stddev_samp(sr.sr_return_quantity) as store_returns_quantitystdev, 
    stddev_samp(sr.sr_return_quantity) / avg(sr.sr_return_quantity) as store_returns_quantitycov, 
    count(cs.cs_quantity) as catalog_sales_quantitycount, 
    avg(cs.cs_quantity) as catalog_sales_quantityave, 
    stddev_samp(cs.cs_quantity) as catalog_sales_quantitystdev, 
    stddev_samp(cs.cs_quantity) / avg(cs.cs_quantity) as catalog_sales_quantitycov 
FROM 
    store_sales ss 
JOIN 
    store_returns sr ON ss.ss_customer_sk = sr.sr_customer_sk AND ss.ss_item_sk = sr.sr_item_sk AND ss.ss_ticket_number = sr.sr_ticket_number 
JOIN 
    catalog_sales cs ON sr.sr_customer_sk = cs.cs_bill_customer_sk AND sr.sr_item_sk = cs.cs_item_sk 
JOIN 
    date_dim d1 ON d1.d_date_sk = ss.ss_sold_date_sk 
JOIN 
    date_dim d2 ON sr.sr_returned_date_sk = d2.d_date_sk 
JOIN 
    date_dim d3 ON cs.cs_sold_date_sk = d3.d_date_sk 
JOIN 
    store s ON s.s_store_sk = ss.ss_store_sk 
JOIN 
    item i ON i.i_item_sk = ss.ss_item_sk 
WHERE 
    d1.d_quarter_name = '2001Q1' 
    AND d2.d_quarter_name IN ('2001Q1', '2001Q2', '2001Q3') 
    AND d3.d_quarter_name IN ('2001Q1', '2001Q2', '2001Q3') 
GROUP BY 
    i_item_id, 
    i_item_desc, 
    s_state 
ORDER BY 
    i_item_id, 
    i_item_desc, 
    s_state 
LIMIT 100;
```