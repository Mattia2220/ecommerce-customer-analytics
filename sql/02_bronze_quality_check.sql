-- ============================================================
-- 02 — BRONZE QUALITY CHECK
-- Verifiche di qualità sui dati grezzi: conteggi, NULL,
-- duplicati, distribuzioni categoriche, outlier numerici.
-- Da eseguire dopo 01_bronze_load.sql, prima di procedere
-- al layer Silver.
-- ============================================================

USE olist;
GO

-- ============================================================
-- 1. CONTEGGI PER TABELLA
-- ============================================================

SELECT 'bronze.orders'              AS tabella, COUNT(*) AS righe FROM bronze.orders             UNION ALL
SELECT 'bronze.customers'           AS tabella, COUNT(*) AS righe FROM bronze.customers          UNION ALL
SELECT 'bronze.order_items'         AS tabella, COUNT(*) AS righe FROM bronze.order_items        UNION ALL
SELECT 'bronze.payments'            AS tabella, COUNT(*) AS righe FROM bronze.payments           UNION ALL
SELECT 'bronze.products'            AS tabella, COUNT(*) AS righe FROM bronze.products           UNION ALL
SELECT 'bronze.sellers'             AS tabella, COUNT(*) AS righe FROM bronze.sellers            UNION ALL
SELECT 'bronze.reviews'             AS tabella, COUNT(*) AS righe FROM bronze.reviews            UNION ALL
SELECT 'bronze.geolocation'         AS tabella, COUNT(*) AS righe FROM bronze.geolocation        UNION ALL
SELECT 'bronze.category_translation'AS tabella, COUNT(*) AS righe FROM bronze.category_translation UNION ALL
SELECT 'bronze.orders_clean'        AS tabella, COUNT(*) AS righe FROM bronze.orders_clean       UNION ALL
SELECT 'bronze.rfm'                 AS tabella, COUNT(*) AS righe FROM bronze.rfm                UNION ALL
SELECT 'bronze.delivered_orders'    AS tabella, COUNT(*) AS righe FROM bronze.delivered_orders;
GO

-- ============================================================
-- 2. NULL CHECK — Colonne chiave
-- ============================================================

-- bronze.orders
SELECT
    SUM(CASE WHEN order_id                      IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN customer_id                   IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN order_status                  IS NULL THEN 1 ELSE 0 END) AS null_order_status,
    SUM(CASE WHEN order_purchase_timestamp      IS NULL THEN 1 ELSE 0 END) AS null_purchase_ts,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS null_delivered_date,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS null_estimated_date
FROM bronze.orders;
GO

-- bronze.customers
SELECT
    SUM(CASE WHEN customer_id         IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN customer_unique_id  IS NULL THEN 1 ELSE 0 END) AS null_unique_id,
    SUM(CASE WHEN customer_state      IS NULL THEN 1 ELSE 0 END) AS null_state
FROM bronze.customers;
GO

-- bronze.order_items
SELECT
    SUM(CASE WHEN order_id       IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN product_id     IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN seller_id      IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
    SUM(CASE WHEN price          IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN freight_value  IS NULL THEN 1 ELSE 0 END) AS null_freight
FROM bronze.order_items;
GO

-- bronze.reviews
SELECT
    SUM(CASE WHEN order_id      IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN review_score  IS NULL THEN 1 ELSE 0 END) AS null_score
FROM bronze.reviews;
GO

-- bronze.rfm
SELECT
    SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) AS null_customer,
    SUM(CASE WHEN recency            IS NULL THEN 1 ELSE 0 END) AS null_recency,
    SUM(CASE WHEN frequency          IS NULL THEN 1 ELSE 0 END) AS null_frequency,
    SUM(CASE WHEN monetary           IS NULL THEN 1 ELSE 0 END) AS null_monetary,
    SUM(CASE WHEN segment            IS NULL THEN 1 ELSE 0 END) AS null_segment
FROM bronze.rfm;
GO

-- ============================================================
-- 3. DUPLICATE CHECK
-- ============================================================

-- Ordini duplicati (order_id deve essere unico)
SELECT order_id, COUNT(*) AS occorrenze
FROM bronze.orders
GROUP BY order_id
HAVING COUNT(*) > 1;
GO

-- Clienti duplicati (customer_id deve essere unico)
SELECT customer_id, COUNT(*) AS occorrenze
FROM bronze.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
GO

-- Clienti RFM duplicati (customer_unique_id deve essere unico)
SELECT customer_unique_id, COUNT(*) AS occorrenze
FROM bronze.rfm
GROUP BY customer_unique_id
HAVING COUNT(*) > 1;
GO

-- ============================================================
-- 4. DISTRIBUZIONE CATEGORICA
-- ============================================================

-- Stato degli ordini
SELECT order_status, COUNT(*) AS totale
FROM bronze.orders
GROUP BY order_status
ORDER BY totale DESC;
GO

-- Metodo di pagamento
SELECT payment_type, COUNT(*) AS totale
FROM bronze.payments
GROUP BY payment_type
ORDER BY totale DESC;
GO

-- Distribuzione review score (1–5)
SELECT review_score, COUNT(*) AS totale
FROM bronze.reviews
GROUP BY review_score
ORDER BY review_score;
GO

-- Distribuzione segmenti RFM
SELECT segment, COUNT(*) AS clienti
FROM bronze.rfm
GROUP BY segment
ORDER BY clienti DESC;
GO

-- Stato di provenienza degli ordini (top 10)
SELECT TOP 10 c.customer_state, COUNT(*) AS ordini
FROM bronze.orders o
JOIN bronze.customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY ordini DESC;
GO

-- ============================================================
-- 5. OUTLIER CHECK — Colonne numeriche
-- ============================================================

-- Prezzi e frete in order_items
SELECT
    MIN(price)         AS price_min,
    MAX(price)         AS price_max,
    AVG(price)         AS price_avg,
    MIN(freight_value) AS freight_min,
    MAX(freight_value) AS freight_max,
    AVG(freight_value) AS freight_avg
FROM bronze.order_items;
GO

-- Valori di pagamento
SELECT
    MIN(payment_value)         AS pmt_min,
    MAX(payment_value)         AS pmt_max,
    AVG(payment_value)         AS pmt_avg,
    MAX(payment_installments)  AS max_installments
FROM bronze.payments;
GO

-- Metriche RFM
SELECT
    MIN(recency)  AS recency_min,  MAX(recency)  AS recency_max,  AVG(recency)  AS recency_avg,
    MIN(frequency)AS freq_min,     MAX(frequency)AS freq_max,     AVG(frequency)AS freq_avg,
    MIN(monetary) AS monetary_min, MAX(monetary) AS monetary_max, AVG(monetary) AS monetary_avg
FROM bronze.rfm;
GO

-- Giorni di consegna (delivered_orders)
SELECT
    MIN(delivery_days) AS days_min,
    MAX(delivery_days) AS days_max,
    AVG(delivery_days) AS days_avg,
    SUM(CASE WHEN is_late = 'True' THEN 1 ELSE 0 END) AS consegne_in_ritardo,
    COUNT(*)                                           AS totale_consegne
FROM bronze.delivered_orders;
GO

-- ============================================================
-- 6. RANGE DATE
-- ============================================================

SELECT
    MIN(TRY_CAST(order_purchase_timestamp AS DATETIME2)) AS prima_data,
    MAX(TRY_CAST(order_purchase_timestamp AS DATETIME2)) AS ultima_data
FROM bronze.orders;
GO
