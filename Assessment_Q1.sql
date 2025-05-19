WITH savings AS (
    SELECT 
        owner_id, 
        COUNT(*) AS savings_count, 
        SUM(confirmed_amount) AS total_savings
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0
    GROUP BY owner_id
),
investments AS (
    SELECT 
        owner_id, 
        COUNT(*) AS investment_count, 
        SUM(confirmed_amount) AS total_investments
    FROM plans_plan
    WHERE is_a_fund = 1 AND confirmed_amount > 0
    GROUP BY owner_id
)
SELECT 
    u.id AS owner_id,
    u.name,
    s.savings_count,
    i.investment_count,
    (s.total_savings + i.total_investments) AS total_deposits
FROM users_customuser u
INNER JOIN savings s ON u.id = s.owner_id
INNER JOIN investments i ON u.id = i.owner_id
ORDER BY total_deposits DESC;