# DataAnalytics-Assessment

This repository contains solutions to the SQL Proficiency Assessment focused on analyzing customer savings and investment behavior. 
The assessment file is made up of a relational database with the following key tables:

- `users_customuser`: Customer demographic and registration details
- `plans_plan`: Details of customer plans (savings/investments)
- `savings_savingsaccount`: Records of deposit transactions
- `withdrawals_withdrawal`: Records of withdrawal transactions

---

## Question 1: High-Value Customers with Multiple Products

**Objective**: Identify customers who have at least one funded savings plan and one funded investment plan, sorted by their total deposits.

**Approach**:
- Two separate `WITH` subqueries were used:
  - One to identify users with savings plans that have confirmed deposits (`is_regular_savings = 1`)
  - Another to identify users with at least one investment plan (`is_a_fund = 1`)
- Only users appearing in both groups were selected.
- Deposits (in kobo) were converted to naira using `SUM(confirmed_amount) / 100`.
- Final output includes user ID, name, plan counts, and total deposits.

**Challenges**:
- Joining all three tables in one query caused inaccurate results due to mixed filtering.
- This was resolved by using two separate CTEs and joining them by `owner_id`.

---

## Question 2: Transaction Frequency Analysis

**Objective**: Segment customers into High, Medium, or Low frequency users based on their average number of transactions per month.

**Approach**:
- A CTE (`customer_monthly_txn`) calculated total transactions and the active number of months based on transaction date range.
- A second CTE (`categorized`) calculated the average monthly transaction frequency and assigned a frequency category using a `CASE` expression.
- The final `SELECT` aggregated the customer count and average monthly frequency for each category.

**Challenges**:
- Initially, `TIMESTAMPDIFF` between `MIN` and `MAX` transaction dates didn’t reflect full tenure for all users.
- This was adjusted by adding `+1` to ensure partial-month customers were included.

---

## Question 3: Account Inactivity Alert

**Objective**: Flag all active savings or investment accounts with no transactions in the last 365 days.

**Approach**:
- Used a `LEFT JOIN` to connect `plans_plan` with `savings_savingsaccount`, ensuring plans with no transactions were still considered.
- Used `MAX(transaction_date)` to determine the most recent activity per plan.
- Included a `HAVING` clause to filter for plans with:
  - No transactions at all (`MAX(...) IS NULL`)
  - Or transactions older than 365 days.
- Filtered only active plans using `is_deleted = 0` and `is_archived = 0`.

**Challenges**:
- Some plans had no transaction records, leading to `NULL` values in aggregation.
- This was resolved by using `LEFT JOIN` and explicitly handling `NULL` conditions in the `HAVING` clause.


## Question 4: Customer Lifetime Value (CLV) Estimation

**Objective**: Estimate the lifetime value of each customer based on account tenure and transaction volume.

**Approach**:
- A `transaction_stats` CTE calculated:
  - Total number of transactions
  - Average profit per transaction (0.1% of `confirmed_amount`, converted from kobo to naira)
- A `tenure_calc` CTE determined the tenure in months using `TIMESTAMPDIFF` on `date_joined`.
- The `clv_estimate` CTE combined the above to apply the simplified CLV formula:  
  **CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction**
- Used `COALESCE()` to ensure customers without transactions are still included with a CLV of `0`.

**Challenges**:
- Initially used an `INNER JOIN`, which excluded users with no transactions. But for transparency, those users were included.
- Switching to `LEFT JOIN` and wrapping metrics with `COALESCE()` allowed inclusion of all users.
