WITH savings_plans AS (
    SELECT 
        p.id AS plan_id,
        p.owner_id,
        'Savings' AS type,
        MAX(s.created_at) AS last_transaction_date
    FROM plans_plan p
    INNER JOIN savings_savingsaccount s ON p.id = s.plan_id
    WHERE p.is_regular_savings = 1
    GROUP BY p.id, p.owner_id
),
investment_plans AS (
    SELECT 
        p.id AS plan_id,
        p.owner_id,
        'Investment' AS type,
        p.created_at AS last_transaction_date
    FROM plans_plan p
    WHERE p.is_a_fund = 1 AND p.confirmed_amount > 0
),
all_plans AS (
    SELECT * FROM savings_plans
    UNION ALL
    SELECT * FROM investment_plans
)
SELECT 
    plan_id,
    owner_id,
    type,
    last_transaction_date,
    CURRENT_DATE - last_transaction_date AS inactivity_days
FROM all_plans
WHERE last_transaction_date < CURRENT_DATE - INTERVAL '365 days'
ORDER BY inactivity_days DESC;