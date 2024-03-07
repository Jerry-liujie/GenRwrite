with avg_discount as (
    SELECT
        avg(ws_ext_discount_amt) as avg_discount_amt
    FROM
        web_sales
    join date_dim on d_date_sk = ws_sold_date_sk
    WHERE
        d_date between '2000-02-01' and (cast('2000-02-01' as date) + interval '90' day)
)
select
    sum(ws_ext_discount_amt) as "Excess Discount Amount"
from
    web_sales
join item on i_item_sk = ws_item_sk
join date_dim on d_date_sk = ws_sold_date_sk
join avg_discount
where
    i_manufact_id = 714
    and d_date between '2000-02-01' and (cast('2000-02-01' as date) + interval '90' day)
    and ws_ext_discount_amt > 1.3 * avg_discount_amt
order by
    sum(ws_ext_discount_amt)
limit
    100;