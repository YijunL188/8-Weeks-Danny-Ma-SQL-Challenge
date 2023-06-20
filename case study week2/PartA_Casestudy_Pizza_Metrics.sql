select * from customer_orders_cleaned;
select * from customer_orders1;
select * from runner_orders1;
select * from runners;
-- How many pizzas were ordered?
SELECT COUNT(*) AS 'Total Number of Pizza Ordered'
FROM customer_orders;

-- How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS 'Number of Unique Ordered'
FROM customer_orders_cleaned;

-- How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(order_id) AS 'Number of Succesful Orders' 
FROM runner_orders1
WHERE cancellation is NULL
GROUP BY runner_id;


-- How many of each type of pizza was delivered?

SELECT pn.pizza_name, 
COUNT(co.pizza_id) AS 'TotalDelivered'
FROM customer_orders co
JOIN runner_orders1 ro ON ro.order_id = co.order_id
JOIN pizza_names pn ON pn.pizza_id = co.pizza_id
WHERE cancellation is NULL
GROUP BY pn.pizza_name;


-- How many Vegetarian and Meatlovers were ordered by each customer?

SELECT customer_id, pizza_name,
		COUNT(co.pizza_id) as 'Number pizza_ordered'
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
GROUP BY pizza_name,customer_id
ORDER BY customer_id;

-- What was the maximum number of pizzas delivered in a single order?
SELECT order_id,
		COUNT(pizza_id) AS total_pizzas
FROM customer_orders1
GROUP BY order_id
ORDER BY total_pizzas DESC
LIMIT 1;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
	   customer_id,
	   SUM(CASE WHEN (exclusions IS NOT NULL OR extras IS NOT NULL)
			THEN 1 ELSE 0 END) AS 'atleastonechange',
	   SUM(CASE WHEN (exclusions IS NULL AND extras IS NULL)
			THEN 1 ELSE 0 END) AS 'no_change'
FROM customer_orders1 co
JOIN runner_orders1 ro ON ro.order_id = co.order_id
WHERE cancellation IS NULL
GROUP BY customer_id;


-- How many pizzas were delivered that had both exclusions and extras?
SELECT customer_id,
	 SUM(CASE WHEN (exclusions IS NOT NULL AND extras is not null) THEN 1 ELSE 0
	 END) AS 'Both_change'
FROM customer_orders1 co
JOIN runner_orders1 ro ON co.order_id = ro.order_id
WHERE cancellation is NULL
GROUP BY customer_id;


-- What was the total volume of pizzas ordered for each hour of the day?
SELECT COUNT(order_id) AS 'order_count',
	   HOUR(order_time) AS 'hour'
FROM customer_orders1
GROUP BY hour;


-- What was the volume of orders for each day of the week?
SELECT COUNT(order_id) AS 'order_count',
	   ROUND(count(order_id)*100/sum(count(order_id)) over(),2) AS 'Volume_pizza',
	   dayofweek(order_time) AS ' Day_of_week',
       dayname(order_time) AS 'Name_of_day'
FROM customer_orders1
GROUP BY Name_of_day;