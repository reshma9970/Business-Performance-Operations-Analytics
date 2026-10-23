-- CREATE DATABASE OlistAnalytics;
USE OlistAnalytics;
GO
SELECT * FROM orders;
SELECT COUNT(*) AS total_rows 
FROM orders;
-- Total sales and order count
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(TRY_CAST(i.price AS DECIMAL(18,2))), 2) AS total_item_sales,
    ROUND(SUM(TRY_CAST(i.freight_value AS DECIMAL(18,2))), 2) AS total_freight
FROM orders o
JOIN items i
    ON o.order_id = i.order_id
WHERE o.order_status = 'delivered';
-- Monthly sales trend
SELECT
    LEFT(o.order_purchase_timestamp, 7) AS sales_month,
    ROUND(SUM(TRY_CAST(i.price AS FLOAT)), 2) AS item_sales,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN items i
    ON o.order_id = i.order_id
WHERE o.order_status = 'delivered'
GROUP BY LEFT(o.order_purchase_timestamp, 7)
ORDER BY sales_month;
-- Top product categories
SELECT TOP 10
    p.product_category_name,
    ROUND(SUM(TRY_CAST(i.price AS DECIMAL(18,2))), 2) AS item_sales,
    COUNT(DISTINCT i.order_id) AS total_orders
FROM items i
JOIN orders o
    ON i.order_id = o.order_id
JOIN products p
    ON i.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY item_sales DESC;
-- Orders by customer state
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;
-- Late delivery rate
SELECT
    COUNT(*) AS delivered_orders,
    SUM(
        CASE
            WHEN order_delivered_customer_date
                 > order_estimated_delivery_date
            THEN 1 ELSE 0
        END
    ) AS late_orders,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN order_delivered_customer_date
                     > order_estimated_delivery_date
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS late_delivery_percentage
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;
