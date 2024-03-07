with avg_discount as (
    select
        1.3 * avg(cs_ext_discount_amt) as avg_discount
    from
        catalog_sales
    join
        date_dim on d_date_sk = cs_sold_date_sk
    where
        d_date between '2001-03-09' and (cast('2001-03-09' as date) + interval '90' day)
)

select
    sum(cs_ext_discount_amt) as "excess discount amount"
from
    catalog_sales
join
    item on i_item_sk = cs_item_sk
join
    date_dim on d_date_sk = cs_sold_date_sk
join
    avg_discount
where
    i_manufact_id = 722
    and d_date between '2001-03-09' and (cast('2001-03-09' as date) + interval '90' day)
    and cs_ext_discount_amt > avg_discount
limit
    100;