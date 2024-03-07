```
select
    i_manager_id,
    sum_sales,
    avg_monthly_sales
from
    (
        select
            i_manager_id,
            sum(ss_sales_price) sum_sales,
            avg(sum(ss_sales_price)) over (partition by i_manager_id, d_moy) avg_monthly_sales
        from
            item
        join store_sales on ss_item_sk = i_item_sk
        join date_dim on ss_sold_date_sk = d_date_sk
        join store on ss_store_sk = s_store_sk
        where
            d_month_seq between 1222 and 1233
            and (
                (
                    i_category in ('Books', 'Children', 'Electronics')
                    and i_class in ('personal', 'portable', 'reference', 'self-help')
                    and i_brand in (
                        'scholaramalgamalg #14',
                        'scholaramalgamalg #7',
                        'exportiunivamalg #9',
                        'scholaramalgamalg #9'
                    )
                )
                or(
                    i_category in ('Women', 'Music', 'Men')
                    and i_class in ('accessories', 'classical', 'fragrances', 'pants')
                    and i_brand in (
                        'amalgimporto #1',
                        'edu packscholar #1',
                        'exportiimporto #1',
                        'importoamalg #1'
                    )
                )
            )
        group by
            i_manager_id,
            d_moy
    ) tmp1
where
    avg_monthly_sales > 0 and abs (sum_sales - avg_monthly_sales) / avg_monthly_sales > 0.1
order by
    i_manager_id,
    avg_monthly_sales,
    sum_sales
limit
    100;
```