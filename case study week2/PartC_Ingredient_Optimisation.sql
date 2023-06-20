
-- 1 What are the standard ingredients for each pizza?
SELECT pizza_id,topping_name
FROM pizza_recipes_cleaned pr
JOIN pizza_toppings pt ON  pt.topping_id =pr.toppings;
		
-- 2 What was the most commonly added extra?
SELECT 
	   COUNT(topping_id) AS 'topping_count',
	   extras,	
	   topping_name
FROM customer_orders_cleaned co
JOIN pizza_toppings pt ON pt.topping_id = co.extras
GROUP BY topping_id;

-- 3 What was the most common exclusion?
SELECT COUNT(topping_id) AS 'topping_count',
	   topping_name
FROM customer_orders_cleaned co
JOIN pizza_toppings pt ON co.exclusions = pt.topping_id
GROUP BY topping_id
LIMIT 1;



-- 4 Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
	SELECT co.*,
		   pizza_name,
		   pt1.topping_name AS excluded_topping,
		   pt2.topping_name AS extra_topping
	FROM customer_orders_cleaned co
    JOIN pizza_names pn ON pn.pizza_id = co.pizza_id
	LEFT JOIN pizza_toppings pt1 ON pt1.topping_id = co.exclusions
	LEFT JOIN pizza_toppings pt2 ON pt2.topping_id = co.extras;
    
WITH order_summary_cte AS(
	SELECT co.*,
		   pizza_name,
		   pt1.topping_name AS excluded_topping,
		   pt2.topping_name AS extra_topping
	FROM customer_orders_cleaned co
    JOIN pizza_names pn ON pn.pizza_id = co.pizza_id
	LEFT JOIN pizza_toppings pt1 ON pt1.topping_id = co.exclusions
	LEFT JOIN pizza_toppings pt2 ON pt2.topping_id = co.extras)
SELECT order_id,
	   customer_id,
       CASE 
			WHEN excluded_topping is NULL AND extra_topping is NULL THEN pizza_name
			WHEN excluded_topping is NOT NULL AND extra_topping is NULL 
				THEN CONCAT(pizza_name, '- Exclude ', GROUP_CONCAT(DISTINCT excluded_topping))
			WHEN excluded_topping is NULL AND extra_topping is NOT NULL 
				THEN CONCAT(pizza_name, '- Include ', GROUP_CONCAT(DISTINCT extra_topping))
			ELSE CONCAT(pizza_name, '- Exclude ', GROUP_CONCAT(DISTINCT excluded_topping), '- Include ', GROUP_CONCAT(DISTINCT extra_topping))
            END AS 'Order_item'
FROM order_summary_cte
GROUP BY order_id
ORDER BY order_id;


