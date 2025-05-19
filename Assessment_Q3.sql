-- Q3: Account Inactivity Alert
-- This query identifies all active savings or investment plans that have had 
-- no inflow transactions (confirmed deposits) in the last 365 days.

SELECT 
    p.id AS plan_id,
    p.owner_id,
    
    -- Classify the plan type for output
    CASE 
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
        ELSE 'Other'
    END AS type,

    -- Get the most recent transaction date for each plan
    MAX(s.transaction_date) AS last_transaction_date,

    -- Calculate how many days have passed since the last transaction
    DATEDIFF(CURDATE(), MAX(s.transaction_date)) AS inactivity_days

FROM plans_plan p

-- Use LEFT JOIN to include plans with no transactions at all
LEFT JOIN savings_savingsaccount s 
    ON p.id = s.plan_id AND s.confirmed_amount > 0  -- Only count valid inflow transactions

WHERE 
    -- Include only savings or investment plans
    (p.is_regular_savings = 1 OR p.is_a_fund = 1)
    
    -- Only consider active plans (not deleted or archived)
    AND (p.is_deleted IS NULL OR p.is_deleted = 0)
    AND (p.is_archived IS NULL OR p.is_archived = 0)

GROUP BY 
    p.id, 
    p.owner_id, 
    p.is_regular_savings, 
    p.is_a_fund

HAVING 
    -- Include plans with no transactions or where the last one was over a year ago
    last_transaction_date IS NULL 
    OR DATEDIFF(CURDATE(), last_transaction_date) > 365;