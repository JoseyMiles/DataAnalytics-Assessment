-- Q1: High-Value Customers with Multiple Products
-- Identify customers with at least one funded savings plan AND one funded investment plan,
-- sorted by total deposits (in naira).

WITH savings AS (
    SELECT 
        p.owner_id,
        COUNT(DISTINCT p.id) AS savings_count,       -- Count of unique savings plans
        SUM(s.confirmed_amount) AS total_savings     -- Total amount deposited (in kobo)
    FROM plans_plan p
    JOIN savings_savingsaccount s 
        ON p.id = s.plan_id
    WHERE p.is_regular_savings = 1                   -- Filter for savings plans
    GROUP BY p.owner_id
),
investments AS (
    SELECT 
        p.owner_id,
        COUNT(DISTINCT p.id) AS investment_count     -- Count of unique investment plans
    FROM plans_plan p
    WHERE p.is_a_fund = 1                            -- Filter for investment plans
    GROUP BY p.owner_id
)

-- Final selection: join savings and investments to find customers who have both
SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,   -- Full name of the customer
    s.savings_count,
    i.investment_count,
    ROUND(s.total_savings / 100, 2) AS total_deposits -- Convert kobo to naira
FROM savings s
JOIN investments i 
    ON s.owner_id = i.owner_id                        -- Ensure customer has both plan types
JOIN users_customuser u 
    ON u.id = s.owner_id
ORDER BY total_deposits DESC;                         -- Sort by total deposits descending
