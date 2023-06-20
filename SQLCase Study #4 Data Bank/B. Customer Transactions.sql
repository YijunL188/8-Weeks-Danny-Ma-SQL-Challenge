-- 1 What is the unique count and total amount for each transaction type?
SELECT txn_type,
	   COUNT(*) AS unique_count,
       SUM(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY txn_type;

-- 2 What is the average total historical deposit counts and amounts for all customers?
SELECT 
    ROUND(COUNT(CASE WHEN txn_type = 'deposit' THEN 1 ELSE NULL END) / COUNT(DISTINCT customer_id), 2) AS avg_deposit_counts,
    ROUND(SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE 0 END) / COUNT(DISTINCT customer_id), 2) AS avg_deposit_amount
FROM customer_transactions;

-- 3 For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
WITH dep_txn_cte AS(
	SELECT customer_id, -- customers with more than 1 deposit for each mont
		   DATE_FORMAT(txn_date, '%Y-%m') AS txn_month,
		   CASE WHEN COUNT(txn_type) > 1 THEN 1 ELSE NULL END AS multi_dep	
	FROM customer_transactions
	WHERE txn_type ='deposit'
	GROUP BY customer_id, txn_month
	ORDER BY customer_id, txn_month),
    -- customers with at least 1 purchase or withdrawal for each month
    other_txn_cte AS(
			SELECT customer_id,
			DATE_FORMAT(txn_date, '%Y-%m') AS txn_month,
            CASE WHEN COUNT(txn_type) >=1 THEN 1 ELSE NULL END AS other_txn
	FROM customer_transactions
    WHERE txn_type !='deposit'
    GROUP BY customer_id, txn_month
    ORDER BY customer_id, txn_month)

SELECT dt.txn_month as 'year_month',
	   COUNT(DISTINCT dt.customer_id) as num_of_customers
FROM dep_txn_cte dt
JOIN other_txn_cte ot 
ON dt.customer_id = ot.customer_id AND
ot.txn_month = dt.txn_month
WHERE multi_dep = 1 AND other_txn = 1
GROUP BY 1;


-- What is the closing balance for each customer at the end of the month?
WITH monthly_txn_cte AS(
	SELECT customer_id,
		   LAST_DAY(txn_date) AS txn_month,
		   txn_amount,
           txn_type,
		   SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount 
				ELSE -1*txn_amount END) AS net_transaction_amt
	FROM customer_transactions
	GROUP BY customer_id, txn_month
	ORDER BY customer_id)
SELECT customer_id,
	   txn_month,
       net_transaction_amt,
       SUM(net_transaction_amt) OVER(PARTITION BY customer_id ORDER BY 
       txn_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS closing_balance
FROM monthly_txn_cte;

-- 5 What is the percentage of customers who increase their closing balance by more than 5%?

-- summing transactions for each month
 WITH sum_txns_cte AS(
    SELECT customer_id,
        LAST_DAY(txn_date)  AS end_month,
        SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount 
            ELSE -txn_amount END) AS amount
    FROM customer_transactions
    GROUP BY 1, 2
    ORDER BY 1, 2
),
-- generate closing dates till end of April	
closing_dates AS(
    SELECT DISTINCT customer_id, 
        LAST_DAY('2020-01-01' + INTERVAL n MONTH) AS ending_month
    FROM customer_transactions
    CROSS JOIN (
        SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
    ) m
    ORDER BY customer_id, ending_month
),
-- closing balance for each month
closing_balances AS(
    SELECT cd.customer_id,
        ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY ending_month) AS end_month_id,
        DATE_FORMAT(ending_month, '%M') AS endofmonth,
        SUM(amount) OVER(PARTITION BY customer_id ORDER BY ending_month) AS closing_balance
    FROM closing_dates cd
    JOIN sum_txns_cte st ON cd.customer_id = st.customer_id
        AND cd.ending_month = st.end_month
    ORDER BY cd.customer_id, end_month_id
),
-- closing balances for the previous month
prev_balance AS(
    SELECT *,
			LAG(closing_balance) OVER(PARTITION BY customer_id ORDER BY end_month_id) AS prev_closing_bal
    FROM closing_balances
)
SELECT 	
		ROUND((COUNT(DISTINCT(customer_id)) / (SELECT COUNT(DISTINCT customer_id) FROM customer_transactions)) * 100, 2) AS percentage
FROM prev_balance
WHERE closing_balance > (105 / 100) * prev_closing_bal AND prev_closing_bal NOT LIKE '-%';
