-- Q4: Customer Lifetime Value (CLV) Estimation
-- Estimate the CLV of each customer using:
-- CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction
-- where profit per transaction is 0.1% of the confirmed amount (in naira)

WITH transaction_stats AS (
    SELECT 
        s.owner_id,
        COUNT(*) AS total_transactions,                              -- Total number of transactions
        AVG(s.confirmed_amount) / 100000 AS avg_profit_per_txn       -- 0.1% of transaction value (confirmed_amount is in kobo)
    FROM savings_savingsaccount s
    GROUP BY s.owner_id
),

tenure_calc AS (
    SELECT 
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,              -- Full name for readability
        TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months -- Months since account creation
    FROM users_customuser u
    WHERE u.date_joined IS NOT NULL                                  -- Ensure valid date_joined
),

clv_estimate AS (
    SELECT 
        t.customer_id,
        t.name,
        t.tenure_months,
        COALESCE(ts.total_transactions, 0) AS total_transactions,    -- Use 0 if no transactions
        -- CLV formula: (transactions per month) * 12 * avg profit
        ROUND(
            (COALESCE(ts.total_transactions, 0) / t.tenure_months) * 12 * COALESCE(ts.avg_profit_per_txn, 0),
            2
        ) AS estimated_clv
    FROM tenure_calc t
    LEFT JOIN transaction_stats ts ON t.customer_id = ts.owner_id   -- Include users even if no transactions
    WHERE t.tenure_months > 0                                        -- Exclude users with zero-month tenure
)

-- Final output: sorted by highest estimated CLV
SELECT *
FROM clv_estimate
ORDER BY estimated_clv DESC;
