```sql
select
    cc.cc_call_center_id Call_Center,
    cc.cc_name Call_Center_Name,
    cc.cc_manager Manager,
    sum(cr.cr_net_loss) Returns_Loss
from
    call_center cc
join
    catalog_returns cr on cr.cr_call_center_sk = cc.cc_call_center_sk
join
    date_dim dd on cr.cr_returned_date_sk = dd.d_date_sk
join
    customer c on cr.cr_returning_customer_sk = c.c_customer_sk
join
    customer_demographics cd on cd.cd_demo_sk = c.c_current_cdemo_sk
join
    household_demographics hd on hd.hd_demo_sk = c.c_current_hdemo_sk
join
    customer_address ca on ca.ca_address_sk = c.c_current_addr_sk
where
    dd.d_year = 2000
    and dd.d_moy = 12
    and (
        (
            cd.cd_marital_status = 'M'
            and cd.cd_education_status = 'Unknown'
        )
        or(
            cd.cd_marital_status = 'W'
            and cd.cd_education_status = 'Advanced Degree'
        )
    )
    and hd.hd_buy_potential like 'Unknown%'
    and ca.ca_gmt_offset = -7
group by
    cc.cc_call_center_id,
    cc.cc_name,
    cc.cc_manager,
    cd.cd_marital_status,
    cd.cd_education_status
order by
    sum(cr.cr_net_loss) desc;
```