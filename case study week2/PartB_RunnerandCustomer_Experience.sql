select * from runner_orders1;
SELECT * from customer_orders1;
-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT WEEK(registration_date) AS 'WeekofRegistration',
	   COUNT(runner_id) AS 'Number of Runners'
FROM runners
GROUP by WeekofRegistration;

-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT runner_id,
	   timestampdiff(MINUTE,order_time, pickup_time) AS 'runner_pickup_time',
       AVG(timestampdiff(MINUTE,order_time, pickup_time)) AS 'avg_runner_pickup_time'
FROM customer_orders1 co
JOIN runner_orders1 ro ON co.order_id = ro.order_id
GROUP BY runner_id;


-- What was the average distance travelled for each customer?
SELECT customer_id,
	   ROUND(AVG(distance_km),2) AS 'Average_distancetravelled_km'
FROM customer_orders1 co
JOIN runner_orders1 ro ON co.order_id = ro.order_id
WHERE cancellation is NULL
GROUP BY customer_id;


-- What was the difference between the longest and shortest delivery times for all orders?
SELECT 
	   MAX(duration_mins) AS 'Max_delivery',
       MIN(duration_mins) AS 'Min_delivery',
       MAX(duration_mins) - MIN(duration_mins) AS ' Delivery_time_diff'
FROM runner_orders1
WHERE distance_km !=0;

-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id,
	   ROUND(AVG(distance_km),2) AS 'Avg_distance_km',
	   ROUND((distance_km * 1000) / (duration_mins*60),2) AS 'Avg_speed_m/s'
FROM runner_orders1
WHERE cancellation is NULL
GROUP BY runner_id;

-- What is the successful delivery percentage for each runner?
SELECT runner_id,
	   COUNT(pickup_time) AS 'delivery_order',
       COUNT(*) AS 'total_order',
       ROUND(COUNT(pickup_time) * 100/ COUNT(*),2) AS 'delivery_success'
FROM runner_orders1
WHERE runner_id
GROUP BY runner_id;