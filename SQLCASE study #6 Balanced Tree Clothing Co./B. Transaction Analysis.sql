-- 1. How many unique transactions were there?
SELECT COUNT(DISTINCT(txn_id)) AS unique_txn
FROM sales;

-- 2. What is the average unique products purchased in each transaction?
WITH AVG_Product_CTE AS(
		SELECT COUNT(DISTINCT(prod_id)) AS unique_prod
		FROM sales
		GROUP BY txn_id)
SELECT ROUND(AVG(unique_prod),1) AS avg_unique_product_each_txn
FROM AVG_Product_CTE;

-- What are the 25th, 50th and 75th percentile values for the revenue per transaction?
-- What is the average discount value per transaction?
-- What is the percentage split of all transactions for members vs non-members?
-- What is the average revenue for member transactions and non-member transactions?