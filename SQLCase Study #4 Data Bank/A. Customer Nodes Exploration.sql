select *from customer_nodes;
select * from customer_transactions;
-- 1.How many unique nodes are there on the Data Bank system?
SELECT COUNT(DISTINCT node_id) AS unique_nodes
FROM customer_nodes;

-- 2 What is the number of nodes per region?
SELECT cn.region_id,
	   COUNT(node_id) AS nodes_per_region,
       region_name
FROM customer_nodes cn
JOIN regions r ON cn.region_id = r.region_id
GROUP BY region_name
ORDER BY region_id;

-- 3 How many customers are allocated to each region?
SELECT cn.region_id,
       region_name,
       COUNT(DISTINCT customer_id) AS total_customer
FROM customer_nodes cn
INNER JOIN regions r ON cn.region_id = r.region_id
GROUP BY region_id;

-- 4 How many days on average are customers reallocated to a different node?
SELECT 
	   AVG(DATEDIFF(end_date, start_date)) AS avg_days
FROM customer_nodes
WHERE end_date != '9999-12-31';

-- 5 What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
-- Median
WITH reallocation_cte AS
	(SELECT *,
		   (DATEDIFF(end_date, start_date)) AS reallocation_days
	FROM customer_nodes cn
	INNER JOIN regions USING (region_id)
	WHERE end_date != '9999-12-31'),
    
    percentile_cte AS
    (SELECT *,
			PERCENT_RANK() OVER(PARTITION BY region_id ORDER BY reallocation_days) * 100 AS percent
	 FROM reallocation_cte)
SELECT region_id,
       region_name,
       reallocation_days
FROM percentile_cte
WHERE percent >50
GROUP BY region_id;  


-- 80th percentile
WITH reallocation_cte AS(
	SELECT *, 
		   (DATEDIFF(end_date,start_date)) AS reallocation_days
	FROM customer_nodes cn
	INNER JOIN regions USING (region_id)
	WHERE end_date !='9999-12-21'),
    
	percentile_cte AS
		(SELECT *,
			   PERCENT_RANK() OVER(PARTITION BY region_id ORDER BY reallocation_days) * 100 AS percent
		FROM reallocation_cte)
	select region_id,
		   region_name,
		   reallocation_days
	FROM percentile_cte
    WHERE percent >80
    GROUP BY region_id;

-- 80th percentile
WITH reallocation_cte AS(
	SELECT *,
			DATEDIFF(end_date,start_date) AS reallocation_days
	FROM customer_nodes
	INNER JOIN regions USING (region_id)
	WHERE end_date !='9999-12-31'),

percentile_cte AS(
	SELECT *,
		   PERCENT_RANK() OVER(PARTITION BY region_id ORDER BY reallocation_days) * 100 AS percent
	FROM reallocation_cte)
SELECT region_id,
	   region_name,
       reallocation_days
FROM percentile_cte
WHERE percent >90
GROUP BY region_id;