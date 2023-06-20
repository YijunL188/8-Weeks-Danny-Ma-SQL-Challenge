
-- 1 If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 
-- - how much money has Pizza Runner made so far if there are no delivery fees?
SELECT  
		pizza_name,
		SUM(CASE WHEN pizza_name ='Meatlovers' THEN 12 
			ELSE 10 END) AS 'TotalAmount'
FROM customer_orders1 co
LEFT JOIN pizza_names pn ON pn.pizza_id =co.pizza_id
INNER JOIN runner_orders1 ro ON ro.order_id = co.order_id
WHERE cancellation IS NULL
GROUP BY pizza_name;


-- 2 What if there was an additional $1 charge for any pizza extras?
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
				THEN CONCAT(pizza_name, '- Include ', GROUP_CONCAT(DISTINCT extra_topping), ' +$1')
			ELSE CONCAT(pizza_name, '- Exclude ', GROUP_CONCAT(DISTINCT excluded_topping), '- Include ', GROUP_CONCAT(DISTINCT extra_topping), ' +$1')
            END AS 'Order_item',
       SUM(CASE WHEN extra_topping IS NOT NULL THEN 1 ELSE 0 END) AS 'Number_of_Extras',
       SUM(CASE WHEN extra_topping IS NOT NULL THEN 1 ELSE 0 END) AS 'Extra_Charge'
FROM order_summary_cte
GROUP BY order_id
ORDER BY order_id;


-- 3 The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
-- how would you design an additional table for this new dataset - generate a schema for this new table and insert your 
-- own data for ratings for each successful customer order between 1 to 5.
DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings (
order_id integer,
rating integer);

INSERT INTO ratings VALUES
(1,3),
(2,5),
(3,2),
(4,1),
(5,4),
(7,5),
(8,4),
(10,5);
SELECT * FROM ratings;

-- 4 Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas

SELECT customer_id,
	   co.order_id,
       runner_id,
       rating,
       order_time,
       pickup_time,
       TIMESTAMPDIFF(MINUTE, order_time,pickup_time) AS timeorderandpick,
       duration_mins AS delivery_duration,
       ROUND(distance_km*60/duration_mins, 2) AS average_speed,
       COUNT(pizza_id) AS total_pizza_count
FROM customer_orders1 co
JOIN runner_orders1 ro ON ro.order_id = co.order_id
JOIN ratings r ON r.order_id = co.order_id
GROUP BY co.order_id;

--  5 If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner 
-- is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

WITH CTE AS (
    SELECT co.*,
        distance_km,
        pizza_name,    
        (CASE WHEN co.pizza_id = 1 THEN 12 
            ELSE 10 END) AS pizzatype_cost,
        ROUND(0.30 * distance_km,2) AS delivery_cost
    FROM customer_orders1 co
    JOIN pizza_names pn ON pn.pizza_id = co.pizza_id
    JOIN runner_orders1 ro ON ro.order_id =  co.order_id
    WHERE cancellation is NULL
)
SELECT 
    ROUND(SUM(pizzatype_cost - delivery_cost),2) AS total_cost
FROM CTE;


