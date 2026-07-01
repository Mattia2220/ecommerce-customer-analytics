-- ============================================================
-- 03 — SILVER LAYER — Pulizia, tipizzazione e arricchimento
-- Fonte: tabelle bronze.*
-- Output: tabelle silver.* pronte per il layer Gold
-- ============================================================

USE olist;
GO

-- silver.orders
-- Aggiunge: date tipizzate, order_month, delivery_days, is_late
DROP TABLE IF EXISTS silver.orders;
GO

CREATE TABLE silver.orders (
    order_id                      NVARCHAR(50),
    customer_id                   NVARCHAR(50),
    order_status                  NVARCHAR(50),
    order_purchase_timestamp      DATETIME2,
    order_approved_at             DATETIME2,
    order_delivered_carrier_date  DATETIME2,
    order_delivered_customer_date DATETIME2,
    order_estimated_delivery_date DATETIME2,
    order_month                   NVARCHAR(10),
    delivery_days                 INT,
    is_late                       BIT
);
GO

INSERT INTO silver.orders
SELECT
    order_id,
    customer_id,
    order_status,
    TRY_CAST(order_purchase_timestamp      AS DATETIME2),
    TRY_CAST(order_approved_at             AS DATETIME2),
    TRY_CAST(order_delivered_carrier_date  AS DATETIME2),
    TRY_CAST(order_delivered_customer_date AS DATETIME2),
    TRY_CAST(order_estimated_delivery_date AS DATETIME2),
    order_month,
    DATEDIFF(
        day,
        TRY_CAST(order_purchase_timestamp      AS DATETIME2),
        TRY_CAST(order_delivered_customer_date AS DATETIME2)
    ),
    CASE
        WHEN TRY_CAST(order_delivered_customer_date AS DATETIME2)
           > TRY_CAST(order_estimated_delivery_date AS DATETIME2)
        THEN 1 ELSE 0
    END
FROM bronze.orders_clean;
GO

-- silver.customers
DROP TABLE IF EXISTS silver.customers;
GO

CREATE TABLE silver.customers (
    customer_id              NVARCHAR(50),
    customer_unique_id       NVARCHAR(50),
    customer_zip_code_prefix NVARCHAR(10),
    customer_city            NVARCHAR(100),
    customer_state           NVARCHAR(10)
);
GO

INSERT INTO silver.customers
SELECT customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state
FROM bronze.customers;
GO

-- silver.order_items
-- Aggiunge: total_item_value = price + freight_value
DROP TABLE IF EXISTS silver.order_items;
GO

CREATE TABLE silver.order_items (
    order_id            NVARCHAR(50),
    order_item_id       INT,
    product_id          NVARCHAR(50),
    seller_id           NVARCHAR(50),
    shipping_limit_date DATETIME2,
    price               FLOAT,
    freight_value       FLOAT,
    total_item_value    FLOAT
);
GO

INSERT INTO silver.order_items
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    TRY_CAST(shipping_limit_date AS DATETIME2),
    price,
    freight_value,
    price + freight_value
FROM bronze.order_items;
GO

-- silver.payments
DROP TABLE IF EXISTS silver.payments;
GO

CREATE TABLE silver.payments (
    order_id             NVARCHAR(50),
    payment_sequential   INT,
    payment_type         NVARCHAR(50),
    payment_installments INT,
    payment_value        FLOAT
);
GO

INSERT INTO silver.payments
SELECT order_id, payment_sequential, payment_type, payment_installments, payment_value
FROM bronze.payments;
GO

-- silver.products
-- Aggiunge: categoria in inglese tramite JOIN con category_translation
DROP TABLE IF EXISTS silver.products;
GO

CREATE TABLE silver.products (
    product_id                    NVARCHAR(50),
    product_category_name         NVARCHAR(100),
    product_category_name_english NVARCHAR(100),
    product_weight_g              FLOAT,
    product_length_cm             FLOAT,
    product_height_cm             FLOAT,
    product_width_cm              FLOAT
);
GO

INSERT INTO silver.products
SELECT
    p.product_id,
    p.product_category_name,
    ISNULL(ct.product_category_name_english, 'unknown'),
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM bronze.products p
LEFT JOIN bronze.category_translation ct
    ON p.product_category_name = ct.product_category_name;
GO

-- silver.sellers
DROP TABLE IF EXISTS silver.sellers;
GO

CREATE TABLE silver.sellers (
    seller_id              NVARCHAR(50),
    seller_zip_code_prefix NVARCHAR(10),
    seller_city            NVARCHAR(100),
    seller_state           NVARCHAR(10)
);
GO

INSERT INTO silver.sellers
SELECT seller_id, seller_zip_code_prefix, seller_city, seller_state
FROM bronze.sellers;
GO

-- silver.reviews
-- Aggiunge: date tipizzate DATETIME2, review_score come INT; escluse righe senza chiavi
DROP TABLE IF EXISTS silver.reviews;
GO

CREATE TABLE silver.reviews (
    review_id               NVARCHAR(50),
    order_id                NVARCHAR(50),
    review_score            INT,
    review_creation_date    DATETIME2,
    review_answer_timestamp DATETIME2
);
GO

INSERT INTO silver.reviews
SELECT
    review_id,
    order_id,
    TRY_CAST(review_score            AS INT),
    TRY_CAST(review_creation_date    AS DATETIME2),
    TRY_CAST(review_answer_timestamp AS DATETIME2)
FROM bronze.reviews
WHERE review_id IS NOT NULL
  AND order_id  IS NOT NULL;
GO

-- silver.rfm
DROP TABLE IF EXISTS silver.rfm;
GO

CREATE TABLE silver.rfm (
    customer_unique_id NVARCHAR(50),
    recency            INT,
    frequency          INT,
    monetary           FLOAT,
    R                  INT,
    F                  INT,
    M                  INT,
    RFM_score          NVARCHAR(10),
    segment            NVARCHAR(50)
);
GO

INSERT INTO silver.rfm
SELECT
    customer_unique_id,
    recency,
    frequency,
    monetary,
    TRY_CAST(R AS INT),
    TRY_CAST(F AS INT),
    TRY_CAST(M AS INT),
    RFM_score,
    segment
FROM bronze.rfm;
GO
