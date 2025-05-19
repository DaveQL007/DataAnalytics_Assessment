# DataAnalytics_Assessment
Assessment For Cowrywise Interview
# Data Analyst Assessment - SQL Solutions

## Overview
This repository contains SQL solutions to four business scenario questions focused on customer analysis, transaction patterns, account activity monitoring, and customer lifetime value estimation. Below are detailed explanations of my approach to each problem and challenges encountered.

---

## 1. High-Value Customers with Multiple Products

Approach
- Objective: Identify customers with ≥1 funded savings plan AND ≥1 funded investment plan.
- Key Tables: `users_customuser`, `savings_savingsaccount`, `plans_plan`
- Strategy:
  1. Created CTEs to separately aggregate:
     - Savings plans using `confirmed_amount > 0` in `savings_savingsaccount`
     - Investment plans using `is_a_fund = 1` and `confirmed_amount > 0` in `plans_plan`
  2. Joined the CTEs on `owner_id` to find overlapping customers
  3. Calculated `total_deposits` as sum of confirmed amounts from both plans
- Optimization: Used filtered aggregates in CTEs to minimize dataset size before joining.

Challenges
- Plan Type Identification: Clarified `is_regular_savings` vs. `is_a_fund` flags using assessment hints
- Edge Cases: Explicitly filtered `confirmed_amount > 0` to exclude unfunded plans
- Data Type Handling: Converted kobo amounts to Naira implicitly by treating all values as numeric

---

2. Transaction Frequency Analysis

Approach
- Objective: Categorize customers by monthly transaction frequency.
- Key Tables: `users_customuser`, `savings_savingsaccount`
- Strategy:
  1. Calculated total transactions and active months per customer
  2. Used `DATE_TRUNC('month', created_at)` to group transactions into months
  3. Implemented `CASE` statement for frequency categorization
  4. Included all users with `LEFT JOIN` to account for zero-transaction customers
- Edge Case Handling: Used `NULLIF` to avoid division-by-zero errors in `transactions_per_month`.

Challenges
- Inactive Users: Addressed by using `LEFT JOIN` instead of `INNER JOIN`
- Partial Months: Used `DATE_TRUNC` to standardize month comparisons
- Decimal Precision: Explicitly cast counts to `FLOAT` for accurate averages

---

3. Account Inactivity Alert

Approach
- Objective: Flag accounts with no inflows for >365 days.
- Key Tables: `plans_plan`, `savings_savingsaccount`
- Strategy:
  1. Created separate CTEs for:
     - Savings accounts (last deposit date from `savings_savingsaccount`)
     - Investment plans (creation date from `plans_plan`)
  2. Used `UNION ALL` to combine results
  3. Calculated `inactivity_days` using `CURRENT_DATE - last_transaction_date`
- Assumption: Treated investment plan creation date as last activity if no withdrawals exist.

Challenges
- Multiple Transaction Types: Differentiated savings (transaction-based) vs. investments (plan-based)
- Time Zone Handling: Used `CURRENT_DATE` instead of `NOW()` to avoid timestamp issues
- Performance: Limited historical data scan using `created_at < CURRENT_DATE - 365`


4. Customer Lifetime Value (CLV) Estimation

Approach
- Objective: Calculate CLV based on transaction volume and tenure.
- Key Tables: `users_customuser`, `savings_savingsaccount`
- Strategy:
  1. Calculated tenure using `AGE()` on `created_at`
  2. Derived `estimated_clv` using formula:
     ```
     (total_confirmed_amount * 0.001) / tenure_months * 12
     ```
  3. Handled kobo-to-Naira conversion via `* 0.00001` multiplier
  4. Used `COALESCE` for customers with zero transactions

Challenges
- Currency Conversion: Addressed kobo (base unit) to Naira conversion in calculations
- New Customers: Handled `tenure_months = 0` using `NULLIF`
- Formula Interpretation: Clarified "total transactions" to mean sum of transaction values, not count

---

General Challenges
1. Schema Ambiguity: 
   - Resolved by analyzing foreign key relationships (`owner_id` → `users_customuser.id`)
   - Verified plan types using `is_regular_savings` and `is_a_fund` flags

2. Data Scale Handling:
   - Used CTEs instead of subqueries for better readability
   - Limited aggregation before joins to reduce computational load

3. Edge Case Coverage:
   - Explicitly handled division-by-zero scenarios
   - Addressed users with missing transactions using `LEFT JOIN`

4. Date Arithmetic:
   - Standardized date calculations using PostgreSQL date functions
   - Validated date ranges against business requirements

