-- ============================================================
-- 01 — BRONZE LAYER — Caricamento dati grezzi da CSV
-- Ogni tabella viene ricreata da zero ad ogni esecuzione.
-- I file CSV devono trovarsi nei percorsi indicati.
-- ============================================================

USE olist;
GO

-- ---- SORGENTI ORIGINALI KAGGLE ----

-- bronze.orders
DROP TABLE IF EXISTS bronze.orders;
GO

CREATE TABLE bronze.orders (
    order_id                      NVARCHAR(50),
    customer_id                   NVARCHAR(50),
    order_status                  NVARCHAR(50),
    order_purchase_timestamp      NVARCHAR(50),
    order_approved_at             NVARCHAR(50),
    order_delivered_carrier_date  NVARCHAR(50),
    order_delivered_customer_date NVARCHAR(50),
    order_estimated_delivery_date NVARCHAR(50)
);
GO

BULK INSERT bronze.orders
FROM 'C:\Users\matti\work\projects\portfolio-customer-analytics\sources\olist_orders_dataset.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
GO

-- bronze.customers
DROP TABLE IF EXISTS bronze.customers;
GO

CREATE TABLE bronze.customers (
    customer_id              NVARCHAR(50),
    customer_unique_id       NVARCHAR(50),
    customer_zip_code_prefix NVARCHAR(10),
    customer_city            NVARCHAR(100),
    customer_state           NVARCHAR(10)
);
GO

BULK INSERT bronze.customers
FROM 'C:\Users\matti\work\projects\portfolio-customer-analytics\sources\olist_customers_dataset.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
GO

UPDATE bronze.customers
SET customer_id        = REPLACE(customer_id,        '"', ''),
    customer_unique_id = REPLACE(customer_unique_id, '"', ''),
    customer_city      = REPLACE(customer_city,      '"', ''),
    customer_state     = REPLACE(customer_state,     '"', '');
GO

-- bronze.order_items
DROP TABLE IF EXISTS bronze.order_items;
GO

CREATE TABLE bronze.order_items (
    order_id            NVARCHAR(50),
    order_item_id       INT,
    product_id          NVARCHAR(50),
    seller_id           NVARCHAR(50),
    shipping_limit_date NVARCHAR(50),
    price               FLOAT,
    freight_value       FLOAT
);
GO

BULK INSERT bronze.order_items
FROM 'C:\Users\matti\work\projects\portfolio-customer-analytics\sources\olist_order_items_dataset.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
GO

UPDATE bronze.order_items
SET order_id   = REPLACE(order_id,   '"', ''),
    product_id = REPLACE(product_id, '"', ''),
    seller_id  = REPLACE(seller_id,  '"', '');
GO

-- bronze.payments
DROP TABLE IF EXISTS bronze.payments;
GO

CREATE TABLE bronze.payments (
    order_id             NVARCHAR(50),
    payment_sequential   INT,
    payment_type         NVARCHAR(50),
    payment_installments INT,
    payment_value        FLOAT
);
GO

BULK INSERT bronze.payments
FROM 'C:\Users\matti\work\projects\portfolio-customer-analytics\sources\olist_order_payments_dataset.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
GO

UPDATE bronze.payments
SET order_id = REPLACE(order_id, '"', '');
GO

-- bronze.products
DROP TABLE IF EXISTS bronze.products;
GO

CREATE TABLE bronze.products (
    product_id                 NVARCHAR(50),
    product_category_name      NVARCHAR(100),
    product_name_lenght        INT,
    product_description_lenght INT,
    product_photos_qty         INT,
    product_weight_g           FLOAT,
    product_length_cm          FLOAT,
    product_height_cm          FLOAT,
    product_width_cm           FLOAT
);
GO

BULK INSERT bronze.products
FROM 'C:\Users\matti\work\projects\portfolio-customer-analytics\sources\olist_products_dataset.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
GO

UPDATE bronze.products
SET product_id            = REPLACE(product_id,            '"', ''),
    product_category_name = REPLACE(product_category_name, '"', '');
GO

-- bronze.sellers (CODEPAGE UTF-8 per caratteri accentati brasiliani)
DROP TABLE IF EXISTS bronze.sellers;
GO

CREATE TABLE bronze.sellers (
    seller_id              NVARCHAR(50),
    seller_zip_code_prefix NVARCHAR(10),
    seller_city            NVARCHAR(100),
    seller_state           NVARCHAR(10)
);
GO

BULK INSERT bronze.sellers
FROM 'C:\Users\matti\work\projects\portfolio-customer-analytics\sources\olist_sellers_dataset.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', CODEPAGE='65001', MAXERRORS=100, TABLOCK);
GO

UPDATE bronze.sellers
SET seller_id    = REPLACE(seller_id,    '"', ''),
    seller_city  = REPLACE(seller_city,  '"', ''),
    seller_state = REPLACE(seller_state, '"', '');
GO

-- bronze.reviews (FORMAT='CSV' per gestire virgole e newline nei testi delle recensioni)
DROP TABLE IF EXISTS bronze.reviews;
GO

CREATE TABLE bronze.reviews (
    review_id               NVARCHAR(50),
    order_id                NVARCHAR(50),
    review_score            NVARCHAR(5),
    review_comment_title    NVARCHAR(MAX),
    review_comment_message  NVARCHAR(MAX),
    review_creation_date    NVARCHAR(100),
    review_answer_timestamp NVARCHAR(100)
);
GO

BULK INSERT bronze.reviews
FROM 'C:\Users\matti\work\projects\portfolio-customer-analytics\sources\olist_order_reviews_dataset.csv'
WITH (
    FORMAT        = 'CSV',
    FIRSTROW      = 2,
    FIELDQUOTE    = '"',
    CODEPAGE      = '65001',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

-- bronze.geolocation (CODEPAGE UTF-8 per caratteri accentati brasiliani)
DROP TABLE IF EXISTS bronze.geolocation;
GO

CREATE TABLE bronze.geolocation (
    geolocation_zip_code_prefix NVARCHAR(10),
    geolocation_lat             FLOAT,
    geolocation_lng             FLOAT,
    geolocation_city            NVARCHAR(100),
    geolocation_state           NVARCHAR(10)
);
GO

BULK INSERT bronze.geolocation
FROM 'C:\Users\matti\work\projects\portfolio-customer-analytics\sources\olist_geolocation_dataset.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', CODEPAGE='65001', MAXERRORS=100, TABLOCK);
GO

-- bronze.category_translation
DROP TABLE IF EXISTS bronze.category_translation;
GO

CREATE TABLE bronze.category_translation (
    product_category_name         NVARCHAR(100),
    product_category_name_english NVARCHAR(100)
);
GO

BULK INSERT bronze.category_translation
FROM 'C:\Users\matti\work\projects\portfolio-customer-analytics\sources\product_category_name_translation.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
GO

-- ---- OUTPUT PYTHON (EDA + RFM) ----

-- bronze.orders_clean (esportato da Python — ha colonna indice come prima colonna)
DROP TABLE IF EXISTS bronze.orders_clean;
GO

CREATE TABLE bronze.orders_clean (
    idx                           INT,
    order_id                      NVARCHAR(50),
    customer_id                   NVARCHAR(50),
    order_status                  NVARCHAR(50),
    order_purchase_timestamp      NVARCHAR(50),
    order_approved_at             NVARCHAR(50),
    order_delivered_carrier_date  NVARCHAR(50),
    order_delivered_customer_date NVARCHAR(50),
    order_estimated_delivery_date NVARCHAR(50),
    order_month                   NVARCHAR(10)
);
GO

BULK INSERT bronze.orders_clean
FROM 'C:\Users\matti\work\projects\portfolio-customer-analytics\sources\orders_clean.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
GO

-- bronze.rfm (esportato da Python — segmentazione RFM clienti)
DROP TABLE IF EXISTS bronze.rfm;
GO

CREATE TABLE bronze.rfm (
    customer_unique_id NVARCHAR(50),
    recency            INT,
    frequency          INT,
    monetary           FLOAT,
    R                  NVARCHAR(5),
    F                  NVARCHAR(5),
    M                  NVARCHAR(5),
    RFM_score          NVARCHAR(10),
    segment            NVARCHAR(50)
);
GO

BULK INSERT bronze.rfm
FROM 'C:\Users\matti\work\projects\portfolio-customer-analytics\sources\rfm_table.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
GO

-- bronze.delivered_orders (esportato da Python — ordini consegnati con metriche delivery)
DROP TABLE IF EXISTS bronze.delivered_orders;
GO

CREATE TABLE bronze.delivered_orders (
    idx                           INT,
    order_id                      NVARCHAR(50),
    customer_id                   NVARCHAR(50),
    order_status                  NVARCHAR(50),
    order_purchase_timestamp      NVARCHAR(50),
    order_approved_at             NVARCHAR(50),
    order_delivered_carrier_date  NVARCHAR(50),
    order_delivered_customer_date NVARCHAR(50),
    order_estimated_delivery_date NVARCHAR(50),
    order_month                   NVARCHAR(10),
    delivery_days                 INT,
    is_late                       NVARCHAR(10)
);
GO

BULK INSERT bronze.delivered_orders
FROM 'C:\Users\matti\work\projects\portfolio-customer-analytics\sources\delivered_orders.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='0x0a', TABLOCK);
GO
