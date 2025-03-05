WITH frequent_ss_items AS (
    SELECT
        SUBSTR(i_item_desc, 1, 30) AS itemdesc,
        i_item_sk AS item_sk,
        d_date AS solddate,
        COUNT(*) AS cnt
    FROM
        store_sales
        JOIN date_dim ON ss_sold_date_sk = d_date_sk
        JOIN item ON ss_item_sk = i_item_sk
    WHERE
        d_year IN (2000, 2001, 2002, 2003)
    GROUP BY
        SUBSTR(i_item_desc, 1, 30),
        i_item_sk,
        d_date
    HAVING
        COUNT(*) > 4
),
max_store_sales AS (
    SELECT
        MAX(csales) AS tpcds_cmax
    FROM (
        SELECT
            c_customer_sk,
            SUM(ss_quantity * ss_sales_price) AS csales
        FROM
            store_sales
            JOIN customer ON ss_customer_sk = c_customer_sk
            JOIN date_dim ON ss_sold_date_sk = d_date_sk
        WHERE
            d_year IN (2000, 2001, 2002, 2003)
        GROUP BY
            c_customer_sk
    ) AS tmp
),
best_ss_customer AS (
    SELECT
        c_customer_sk,
        SUM(ss_quantity * ss_sales_price) AS ssales
    FROM
        store_sales
        JOIN customer ON ss_customer_sk = c_customer_sk
    GROUP BY
        c_customer_sk
    HAVING
        SUM(ss_quantity * ss_sales_price) > (SELECT tpcds_cmax * 0.95 FROM max_store_sales)
)
SELECT
    SUM(sales)
FROM (
    SELECT
        cs_sold_date_sk AS sold_date_sk,
        cs_quantity * cs_list_price AS sales,
        cs_item_sk AS item_sk,
        cs_bill_customer_sk AS bill_customer_sk
    FROM
        catalog_sales
    UNION ALL
    SELECT
        ws_sold_date_sk AS sold_date_sk,
        ws_quantity * ws_list_price AS sales,
        ws_item_sk AS item_sk,
        ws_bill_customer_sk AS bill_customer_sk
    FROM
        web_sales
) AS combined_sales
JOIN date_dim ON combined_sales.sold_date_sk = d_date_sk
WHERE
    d_year = 2000
    AND d_moy = 7
    AND combined_sales.item_sk IN (SELECT item_sk FROM frequent_ss_items)
    AND combined_sales.bill_customer_sk IN (SELECT c_customer_sk FROM best_ss_customer)
LIMIT 100;
