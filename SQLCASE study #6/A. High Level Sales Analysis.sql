select*
from sales;

select *
from product_details;
-- 1. What was the total quantity sold for all products?
SELECT pd.product_name,
	   SUM(s.qty) AS total_qty
FROM sales s
JOIN product_details pd ON s.prod_id = pd.product_id
GROUP BY pd.product_name;

-- 2. What is the total generated revenue for all products before discounts?
SELECT pd.product_name,  
       s.price AS price,
	   SUM(s.qty) AS total_qty,
       s.price * SUM(s.qty) AS total_revenue
FROM sales s
JOIN product_details pd ON s.prod_id = pd.product_id
GROUP BY pd.product_name
ORDER BY total_revenue DESC;

-- 3. What was the total discount amount for all products?
	SELECT pd.product_name,
		   SUM(s.qty) AS total_qty,
		   s.price,
		   s.discount AS p_discount,
		   ROUND(SUM(s.qty * s.price * s.discount/100),2) AS total_discount
	FROM sales s
	JOIN product_details pd ON s.prod_id = pd.product_id
    GROUP BY pd.product_name;


WITH total_discount_CTE AS(
	SELECT pd.product_name,
		   SUM(s.qty) AS total_qty,
		   s.price,
		   s.discount AS p_discount,
		   ROUND(SUM(s.qty * s.price * s.discount/100),2) AS total_discount
	FROM sales s
	JOIN product_details pd ON s.prod_id = pd.product_id
	GROUP BY pd.product_name)
SELECT SUM(total_discount) AS total_disc_all_products
FROM total_discount_CTE;