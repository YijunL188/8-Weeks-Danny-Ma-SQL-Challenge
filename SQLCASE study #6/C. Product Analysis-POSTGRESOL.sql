SELECT *
FROM SALES;

SELECT * 
FROM product_details;

-- 1. What are the top 3 products by total revenue before discount?
SELECT prod_id,
       product_name,
	   SUM(s.qty * s.price) AS Revenue_before_discount
FROM sales s
JOIN product_details pd ON pd.product_id = s.prod_id
GROUP BY 1,2
ORDER BY revenue_before_discount DESC
LIMIT 3;

-- 2. What is the total quantity, revenue and discount for each segment?
SELECT segment_id,
       segment_name,
	   SUM(qty) AS quantity,
	   SUM(qty * s.price) AS revenue,
	   ROUND(SUM(qty * s.price * s.discount::numeric/100),2) AS after_discount
FROM sales s
JOIN product_details pd ON pd.product_id = s.prod_id
GROUP BY 1,2;
	  

-- 3. What is the top selling product for each segment?
WITH ranking_cte AS(
	SELECT segment_id,
		   segment_name,
		   product_id,
		   product_name,
		   SUM(s.qty) AS total_qty,
		   RANK() OVER (PARTITION BY segment_id ORDER BY SUM(s.qty) DESC) AS ranking
	FROM product_details pd
	JOIN sales s ON s.prod_id = pd.product_id
	GROUP BY 1,2,3,4)

SELECT segment_id,
       segment_name,
	   product_id,
	   product_name,
	   total_qty,
	   ranking
FROM ranking_cte
WHERE ranking =1;

-- 4. What is the total quantity, revenue and discount for each category?
SELECT category_id,
	   category_name,
	   SUM(s.qty) AS total_qty,
	   SUM(s.qty * pd.price) AS revenue,
	   ROUND(SUM(s.qty * pd.price * s.discount::numeric/100),2) AS total_discount
FROM product_details pd
JOIN sales s ON s.prod_id = pd.product_id
GROUP BY 1,2;

-- 5. What is the top selling product for each category?
WITH top_selling_product AS(	
	SELECT product_id,
		   product_name,
		   category_id,
		   category_name,
		   SUM(s.qty) AS total_qty,
		   RANK() OVER (PARTITION BY category_id ORDER BY SUM(s.qty) DESC) AS Ranking
	FROM product_details pd
	JOIN sales s ON pd.product_id = s.prod_id
	GROUP BY 1,2,3,4)

SELECT product_id,
	   product_name,
	   category_id,
	   category_name,
	   total_qty
FROM top_selling_product
WHERE Ranking = 1;

	   
-- 6. What is the percentage split of revenue by product for each segment?
WITH percentage_split_cte AS(
	SELECT product_id,
		   product_name,
		   segment_id,
		   segment_name,
		   SUM(s.qty * s.price) AS total_revenue
	FROM product_details pd
	JOIN sales s ON pd.product_id =s.prod_id
	GROUP BY 1,2,3,4)
	
SELECT *,
       ROUND(total_revenue * 100 / SUM(total_revenue) OVER (PARTITION BY segment_id),2) AS revenue_split_percentage
FROM percentage_split_cte
ORDER BY segment_id;

-- 7. What is the percentage split of revenue by segment for each category?
WITH percentage_revenue_seg AS(
	SELECT segment_id,
		   segment_name,
		   category_id,
		   category_name,
		   SUM(pd.price * s.qty) AS revenue
	FROM product_details pd
	JOIN sales s ON pd.product_id = s.prod_id
	GROUP BY 1,2,3,4)
SELECT *,
       ROUND(revenue * 100 / SUM(revenue) OVER (PARTITION BY category_id),2) AS revenue_percentage
FROM percentage_revenue_seg;	   


-- 8. What is the percentage split of total revenue by category?
WITH percentage_revenue_category AS(
	SELECT category_id,
		   category_name,
		   SUM(pd.price * s.qty) AS total_revenue
	FROM product_details pd
	JOIN sales s ON s.prod_id = pd.product_id
	GROUP BY 1,2)

SELECT category_id,
       category_name,
	   ROUND(total_revenue * 100 / (SELECT SUM(total_revenue) FROM percentage_revenue_category),2) AS percentage_revenue
FROM percentage_revenue_category;


-- What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
-- What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?