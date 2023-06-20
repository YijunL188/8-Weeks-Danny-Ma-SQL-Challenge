-- cleaning data
DROP TABLE IF EXISTS customer_orders1;
CREATE TABLE customer_orders1 
SELECT 
	order_id,
    customer_id,
    pizza_id,
    CASE WHEN exclusions ='' THEN NULL
		 WHEN exclusions = 'NULL' THEN null ELSE exclusions
	END AS exclusions,
    CASE WHEN extras = '' THEN NULL
		 WHEN extras = 'NULL' THEN NULL ELSE extras 
	END AS extras,
    order_time
FROM customer_orders;

SELECT * FROM customer_orders1;

DROP TABLE IF EXISTS runner_orders1;
CREATE TABLE runner_orders1
SELECT
		order_id,
        runner_id,
        CASE WHEN pickup_time ='null' THEN NULL ELSE pickup_time
        END AS pickup_time,
        CASE WHEN distance = 'null' THEN NULL 
			ELSE CAST(REGEXP_REPLACE(distance,'[a-z]+','') AS FLOAT)
		END AS distance_km,
        
        CASE WHEN duration = 'null' THEN NULL
			ELSE CAST(REGEXP_REPLACE(duration,'[a-z]+','') AS FLOAT)
		END AS duration_mins,
        
        CASE WHEN cancellation = '' THEN NULL
			 WHEN cancellation = 'null' THEN NULL
			ELSE cancellation
		END AS cancellation
FROM runner_orders;

SELECT* FROM runner_orders1;

ALTER TABLE pizza_recipes_cleaned
DROP COLUMN MyUnknownColumn;
SELECT * FROM pizza_recipes_cleaned;

ALTER TABLE customer_orders_cleaned
DROP COLUMN MyUnknownColumn;
SELECT * FROM customer_orders_cleaned;

ALTER TABLE pizza_toppings
RENAME COLUMN toppings TO topping_name;
