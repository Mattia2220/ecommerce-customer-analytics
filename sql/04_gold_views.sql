-- ============================================================
-- 05 — GOLD LAYER v2 — Viste riprogettate per Power BI
-- Una view per pagina dashboard: ogni pagina ha una sola
-- tabella sorgente così i filtri incrociati funzionano
-- su tutti i visual contemporaneamente.
--
-- Pagine previste:
--   gold.overview       → Pagina 1: trend, categorie, geo
--   gold.customers      → Pagina 2: clienti, RFM, pagamenti
--   gold.delivery       → Pagina 3: consegne, ritardi, recensioni
--   gold.sellers        → Pagina 4: performance venditori
--   gold.cohort         → Pagina 5: retention clienti
-- ============================================================

USE olist;
GO

-- ============================================================
-- gold.overview
-- Dimensioni: order_month, customer_state, category
-- Metriche:   order_numbers, order_value, average_price,
--             avg_number_product_per_order
-- ============================================================
DROP VIEW IF EXISTS gold.overview;
GO

CREATE VIEW gold.overview AS
SELECT
    o.order_month,
    c.customer_state,
    p.product_category_name_english,
    COUNT(DISTINCT o.order_id)                           AS order_numbers,
    SUM(ot.total_item_value)                             AS order_value,
    AVG(ot.price)                                        AS average_price,
    COUNT(ot.order_item_id) / COUNT(DISTINCT o.order_id) AS avg_number_product_per_order
FROM silver.orders AS o
JOIN silver.order_items AS ot ON o.order_id   = ot.order_id
JOIN silver.customers   AS c  ON c.customer_id = o.customer_id
LEFT JOIN silver.products AS p ON p.product_id = ot.product_id
GROUP BY o.order_month, c.customer_state, p.product_category_name_english;
GO

-- ============================================================
-- gold.customers
-- Dimensioni: segment, payment_type, customer_city, customer_state
-- Metriche:   total_payment, order_numbers
-- ============================================================
DROP VIEW IF EXISTS gold.customers;
GO

CREATE VIEW gold.customers AS
SELECT
    r.segment,
    p.payment_type,
    c.customer_city,
    c.customer_state,
    SUM(p.payment_value)       AS total_payment,
    COUNT(DISTINCT p.order_id) AS order_numbers
FROM silver.orders AS o
JOIN silver.customers AS c ON o.customer_id          = c.customer_id
JOIN silver.rfm       AS r ON r.customer_unique_id   = c.customer_unique_id
JOIN silver.payments  AS p ON p.order_id             = o.order_id
GROUP BY r.segment, p.payment_type, c.customer_city, c.customer_state;
GO

-- ============================================================
-- gold.delivery
-- Dimensioni: is_late, delivery_time, review_score,
--             customer_state, product_category_name_english
-- Metriche:   average_delivery_days, total_orders, total_revenue
-- ============================================================
DROP VIEW IF EXISTS gold.delivery;
GO

CREATE VIEW gold.delivery AS
SELECT
    o.is_late,
    AVG(o.delivery_days) AS average_delivery_days,
    CASE
        WHEN o.delivery_days < 7               THEN 'fast delivery'
        WHEN o.delivery_days BETWEEN 7 AND 14  THEN 'medium delivery'
        ELSE 'slow delivery'
    END                                        AS delivery_time,
    r.review_score,
    c.customer_state,
    p.product_category_name_english,
    COUNT(DISTINCT o.order_id)                 AS total_orders,
    SUM(ot.total_item_value)                   AS total_revenue
FROM silver.orders AS o
LEFT JOIN silver.order_items AS ot ON ot.order_id  = o.order_id
JOIN silver.customers        AS c  ON c.customer_id = o.customer_id
JOIN silver.products         AS p  ON p.product_id  = ot.product_id
JOIN silver.reviews          AS r  ON r.order_id    = o.order_id
GROUP BY
    o.is_late,
    CASE
        WHEN o.delivery_days < 7               THEN 'fast delivery'
        WHEN o.delivery_days BETWEEN 7 AND 14  THEN 'medium delivery'
        ELSE 'slow delivery'
    END,
    r.review_score,
    c.customer_state,
    p.product_category_name_english;
GO

-- ============================================================
-- gold.sellers
-- Dimensioni: seller_id, seller_state
-- Metriche:   total_orders, total_revenue, late_percentage,
--             average_review_score
-- ============================================================
DROP VIEW IF EXISTS gold.sellers;
GO

CREATE VIEW gold.sellers AS
SELECT
    s.seller_id,
    s.seller_state,
    SUM(CAST(o.is_late AS INT)) * 100.0 / COUNT(*) AS late_percentage,
    AVG(r.review_score)                             AS average_review_score,
    COUNT(DISTINCT o.order_id)                      AS total_orders,
    SUM(ot.total_item_value)                        AS total_revenue
FROM silver.orders     AS o
JOIN silver.order_items AS ot ON ot.order_id = o.order_id
JOIN silver.reviews     AS r  ON r.order_id  = o.order_id
JOIN silver.sellers     AS s  ON s.seller_id = ot.seller_id
GROUP BY s.seller_id, s.seller_state;
GO

-- ============================================================
-- gold.cohort
-- Dimensioni: cohort_month, period
-- Metriche:   customer_count
-- Nota: usa customer_unique_id (non customer_id) perché in
--       Olist ogni ordine ha un customer_id distinto
-- ============================================================
DROP VIEW IF EXISTS gold.cohort;
GO

CREATE VIEW gold.cohort AS
SELECT
    cohort_month,
    DATEDIFF(month, cohort_month, order_month) AS period,
    COUNT(DISTINCT customer_unique_id)         AS customer_count
FROM (
    SELECT
        c.customer_unique_id,
        TRY_CAST(MIN(o.order_month) OVER (PARTITION BY c.customer_unique_id) + '-01' AS DATE) AS cohort_month,
        TRY_CAST(o.order_month + '-01' AS DATE)                                               AS order_month
    FROM silver.orders    AS o
    JOIN silver.customers AS c ON c.customer_id = o.customer_id
) t
GROUP BY cohort_month, DATEDIFF(month, cohort_month, order_month);
GO
