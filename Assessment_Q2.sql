WITH customer_transactions AS (
    SELECT 
        u.id AS owner_id,
        COUNT(s.id) AS total_transactions,
        COUNT(DISTINCT DATE_TRUNC('month', s.created_at)) AS num_months
    FROM users_customuser u
    LEFT JOIN savings_savingsaccount s ON u.id = s.owner_id
    GROUP BY u.id
),
customer_frequency AS (
    SELECT 
        owner_id,
        CASE 
            WHEN num_months = 0 THEN 0
            ELSE total_transactions::FLOAT / num_months
        END AS transactions_per_month
    FROM customer_transactions
)
SELECT 
    CASE 
        WHEN transactions_per_month >= 10 THEN 'High Frequency'
        WHEN transactions_per_month >= 3 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    COUNT(owner_id) AS customer_count,
    ROUND(AVG(transactions_per_month), 1) AS avg_transactions_per_month
FROM customer_frequency
GROUP BY frequency_category
ORDER BY frequency_category;