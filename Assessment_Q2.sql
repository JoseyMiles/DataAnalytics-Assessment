-- Q2: Transaction Frequency Analysis
-- This query analyzes customer transaction patterns and categorizes them
-- based on their average monthly transaction frequency.

WITH customer_monthly_txn AS (
    SELECT 
        s.owner_id,
        COUNT(*) AS total_txns,  -- Total number of transactions per customer
        -- Duration in months between first and last transaction (inclusive)
        TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)) + 1 AS active_months
    FROM savings_savingsaccount s
    GROUP BY s.owner_id
),

categorized AS (
    SELECT 
        c.owner_id,
        ROUND(c.total_txns / c.active_months, 1) AS avg_txns_per_month,  -- Average monthly transactions
        -- Frequency classification based on transaction volume
        CASE 
            WHEN (c.total_txns / c.active_months) >= 10 THEN 'High Frequency'
            WHEN (c.total_txns / c.active_months) BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM customer_monthly_txn c
)

-- Aggregate customer counts and average monthly frequency by category
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,                            -- Number of customers in each category
    ROUND(AVG(avg_txns_per_month), 1) AS avg_transactions_per_month  -- Overall average for category
FROM categorized
GROUP BY frequency_category;