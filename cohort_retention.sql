-- Task 22: Cohort retention table by first-purchase (signup) month
-- Dialect: SQLite (also valid in PostgreSQL with minor date-function changes)
-- Source table: transactions(Invoice, CustomerID, InvoiceDate, Quantity, Price)
-- Already cleaned: no cancellations, no missing customer IDs, Quantity > 0, Price > 0

WITH orders AS (
    SELECT DISTINCT
        CustomerID,
        CAST(strftime('%Y', InvoiceDate) AS INTEGER) * 12
          + CAST(strftime('%m', InvoiceDate) AS INTEGER) AS month_idx,
        strftime('%Y-%m', InvoiceDate)                  AS order_month
    FROM transactions
),
first_purchase AS (                       -- 1. DEFINE THE COHORT
    SELECT CustomerID,
           MIN(month_idx) AS cohort_idx
    FROM orders
    GROUP BY CustomerID
),
cohort_activity AS (                      -- 2. MONTHS SINCE FIRST PURCHASE
    SELECT
        f.CustomerID,
        f.cohort_idx,
        o.month_idx - f.cohort_idx AS period
    FROM first_purchase f
    JOIN orders o ON o.CustomerID = f.CustomerID
)
SELECT                                    -- 3. COUNT ACTIVE CUSTOMERS PER COHORT x PERIOD
    printf('%04d-%02d', (cohort_idx - 1) / 12, (cohort_idx - 1) % 12 + 1) AS cohort_month,
    period,
    COUNT(DISTINCT CustomerID) AS active_customers
FROM cohort_activity
GROUP BY cohort_idx, period
ORDER BY cohort_idx, period;
