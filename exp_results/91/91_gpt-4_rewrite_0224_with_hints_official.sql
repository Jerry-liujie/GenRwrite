```sql
SELECT 
    cc.cc_call_center_id AS call_center, 
    cc.cc_name AS call_center_name, 
    cc.cc_manager AS manager, 
    SUM(cr.cr_net_loss) AS returns_loss 
FROM 
    call_center cc
JOIN 
    catalog_returns cr ON cr.cr_call_center_sk = cc.cc_call_center_sk
JOIN 
    date_dim d ON cr.cr_returned_date_sk = d.d_date_sk
JOIN 
    customer c ON cr.cr_returning_customer_sk= c.c_customer_sk
JOIN 
    customer_demographics cd ON cd.cd_demo_sk = c.c_current_cdemo_sk
JOIN 
    household_demographics hd ON hd.hd_demo_sk = c.c_current_hdemo_sk
JOIN 
    customer_address ca ON ca.ca_address_sk = c.c_current_addr_sk
WHERE 
    d.d_year = 2000 
    AND d.d_moy = 12 
    AND ( 
        (cd.cd_marital_status = 'M' AND cd.cd_education_status = 'Unknown') 
        OR (cd.cd_marital_status = 'W' AND cd.cd_education_status = 'Advanced Degree')
    ) 
    AND hd.hd_buy_potential LIKE 'Unknown%' 
    AND ca.ca_gmt_offset = -7 
GROUP BY 
    cc.cc_call_center_id,
    cc.cc_name,
    cc.cc_manager
ORDER BY 
    returns_loss DESC;
```