```sql
select
    distinct(i_product_name)
from
    item i1
where
    i_manufact_id between 704 and 744
    and exists (
        select 1
        from
            item i2
        where
            i2.i_manufact = i1.i_manufact
            and (
                (
                    i2.i_category = 'Women'
                    and i2.i_color in ('forest', 'lime', 'dark', 'aquamarine', 'frosted', 'plum')
                    and i2.i_units in ('Pallet', 'Pound', 'Ton', 'Tbl', 'Dram', 'Box')
                    and i2.i_size in ('economy', 'small', 'extra large', 'petite')
                )
                or (
                    i2.i_category = 'Men'
                    and i2.i_color in ('powder', 'sky', 'maroon', 'smoke', 'papaya', 'peach', 'firebrick', 'sienna')
                    and i2.i_units in ('Dozen', 'Lb', 'Ounce', 'Case', 'Bundle', 'Carton', 'Cup', 'Each')
                    and i2.i_size in ('N/A', 'large', 'economy', 'small')
                )
            )
    )
order by
    i_product_name
limit
    100;
```