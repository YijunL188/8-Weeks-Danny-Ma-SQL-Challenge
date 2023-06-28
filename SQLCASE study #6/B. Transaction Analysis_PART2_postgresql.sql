SELECT *
FROM sales;

SELECT *
FROM product_details;

-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
WITH revenue_per_txn AS(
	SELECT txn_id,
		   SUM(qty * price) AS txn_revenue
	FROM sales
	GROUP BY 1)
SELECT 
	   PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY txn_revenue) AS percent25th,
	   PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY txn_revenue) AS percent50th,
	   PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY txn_revenue) AS percent75th
FROM revenue_per_txn;
 
-- 4. What is the average discount value per transaction?
WITH AVG_discount_txn AS(	
	SELECT 
		   txn_id,
		   SUM(qty * price * discount/100) AS txn_discount
	FROM sales
	GROUP BY 1)
SELECT ROUND(AVG(txn_discount)) AS avg_discount
FROM AVG_discount_txn;

-- 5. What is the percentage split of all transactions for members vs non-members?
WITH membership AS(
	SELECT member,
		   COUNT(DISTINCT(txn_id)) AS transactions
	FROM sales
	GROUP BY 1)
SELECT member,
       transactions,
	   ROUND((transactions / (SELECT SUM(transactions) FROM membership)),1) * 100 AS percentage
FROM membership
GROUP BY 1,2;
       

-- 6. What is the average revenue for member transactions and non-member transactions?
WITH avg_revenue_membership AS (	
	SELECT member,
	       txn_id,
		   SUM(qty * price) AS revenue
	FROM sales
	GROUP BY 1,2)
SELECT member,
       ROUND(AVG(revenue)) AS avg_revenue_membership_txn
FROM avg_revenue_membership
GROUP BY 1;
