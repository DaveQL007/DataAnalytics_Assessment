SELECT 
    u.id AS customer_id,
    u.name,
    EXTRACT(MONTH FROM AGE(CURRENT_DATE, u.created_at)) AS tenure_months,
    COUNT(s.id) AS total_transactions,
    COALESCE(
        (SUM(s.confirmed_amount) * 0.00001 * 12) / 
        NULLIF(EXTRACT(MONTH FROM AGE(CURRENT_DATE, u.created_at)), 0),
        0
    ) AS estimated_clv
FROM users_customuser u
LEFT JOIN savings_savingsaccount s ON u.id = s.owner_id
GROUP BY u.id, u.name
ORDER BY estimated_clv DESC;