 /* --------------------
      Case Study #2 Cleaning
   --------------------*/
CREATE SCHEMA pizza_runner;
USE pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

 
DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
 -- Clean tables that have nulls(runners orders, customers orders)
 
 -- Customer Orders(has string nulls and blanks)
 
 CREATE TEMPORARY TABLE customer_orders_t
 SELECT order_id, customer_id, pizza_id,
 	CASE 
	 	WHEN exclusions = 'null' THEN NULL
	 	WHEN exclusions = '' THEN null
 		ELSE exclusions
 	END AS exclusions,
 	CASE 
 		WHEN extras = 'null' THEN NULL
 		WHEN extras = '' THEN NULL
 		ELSE extras
 	END AS extras,
 	order_time
 FROM customer_orders;

-- Clean Runner_orders
-- remove null strings in pickup_time
-- change data type of pickup_time
-- remove 'km' and 'null' in distance 
-- trim distance
-- change data type of distance
-- remove 'minutes','minute','mins','null'
-- trim duration
-- change data type of duration 
-- remove actual null values, 'null'

CREATE TEMPORARY TABLE runner_orders_t
SELECT order_id, runner_id,
	CASE 
		WHEN pickup_time = 'null' THEN null
		ELSE pickup_time 	
	END AS pickup_time,
	CASE 
		WHEN distance = 'null' THEN null
		WHEN distance LIKE '%km' THEN trim('km' FROM distance)
		ELSE distance
	END AS distance,
	CASE 
		WHEN duration LIKE '%mins' THEN trim('mins' FROM duration)
		WHEN duration LIKE '%minutes' THEN trim('minutes' FROM duration)
		WHEN duration LIKE '%minute' THEN trim('minute' FROM duration)
		WHEN duration LIKE 'null' THEN null
		ELSE duration
	END AS duration,
	CASE 
		WHEN cancellation LIKE 'null' THEN NULL
		WHEN cancellation LIKE '' THEN null
		ELSE cancellation
	END AS cancellation
FROM runner_orders;

ALTER TABLE runner_orders_t
MODIFY COLUMN pickup_time datetime, 
MODIFY COLUMN distance float,
MODIFY COLUMN duration int;

DROP TABLE runner_orders_t

-- A. Pizza Metrics
-- 1.How many pizzas were ordered?

SELECT count(pizza_id) AS total
FROM customer_orders_t;

total|
-----+
   14|

-- 2. How many unqiue customer orders were made? 

SELECT count(DISTINCT(order_id)) AS count_orders
FROM customer_orders_t;

count_orders|
------------+
          10|

-- 3. How many successful orders were delivered by each runner?
	
SELECT runner_id,count(order_id) AS total_successful_orders
FROM runner_orders_T
WHERE cancellation IS NULL
GROUP BY runner_id;

runner_id|total_successful_orders|
---------+-----------------------+
        1|                      4|
        2|                      3|
        3|                      1|
        
-- 4. how many of each type of pizza was delivered?

SELECT count(c.pizza_id) AS count, pn.pizza_name
FROM customer_orders_t c
JOIN pizza_names pn ON c.pizza_id = pn.pizza_id
JOIN runner_orders_t r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL 
GROUP BY pn.pizza_name;

count|pizza_name|
-----+----------+
    9|Meatlovers|
    3|Vegetarian|

-- 5. how many vegetarian and meatlovers were ordered by each customer?
SELECT c.customer_id,count(c.pizza_id) AS orders, pn.pizza_name
FROM customer_orders_t c
JOIN pizza_names pn ON c.pizza_id = pn.pizza_id
JOIN runner_orders_t r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL 
GROUP BY c.customer_id,pn.pizza_name
ORDER BY c.customer_id;

customer_id|orders|pizza_name|
-----------+------+----------+
        101|     2|Meatlovers|
        102|     2|Meatlovers|
        102|     1|Vegetarian|
        103|     2|Meatlovers|
        103|     1|Vegetarian|
        104|     3|Meatlovers|
        105|     1|Vegetarian|
-- 6. what was the maximum number of pizzas delivered in a single order?

SELECT MAX(count_pizzas) AS max_num
FROM (
    SELECT COUNT(pizza_id) AS count_pizzas
    FROM customer_orders_t
    GROUP BY order_id
) subquery;

max_num|
-------+
      3|
      
-- the maximum number of pizzas delivered in a single order is 3


-- 7. for each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT c.customer_id,
	sum(CASE 
		WHEN c.exclusions IS NOT NULL THEN 1
		WHEN c.extras IS NOT NULL THEN 1
		ELSE 0
	END) AS MinOneChange,
	sum(CASE
		WHEN (c.exclusions IS NULL) and
		(c.extras IS NULL) THEN 1
		ELSE 0
	END) AS NoChange
FROM customer_orders_t c
JOIN runner_orders_t ro ON c.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY c.customer_id;
	
customer_id|MinOneChange|NoChange|
-----------+------------+--------+
        101|           0|       2|
        102|           0|       3|
        103|           3|       0|
        104|           2|       1|
        105|           1|       0|
        
-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT count(c.order_id) AS num_pizza
FROM customer_orders_t c
JOIN runner_orders_t ro ON c.order_id = ro.order_id
WHERE ro.cancellation IS NULL AND c.exclusions IS NOT NULL and c.extras IS NOT NULL;

num_pizza|
---------+
        1|

-- 1 pizza had both exclusions and extras

-- 9. what was the total volume of pizzas ordered for each hour of the day?

SELECT count(order_id) AS total_ordered, hour(order_time) AS hour_of_day
FROM customer_orders_t
GROUP BY hour_of_day
ORDER BY hour_of_day;

total_ordered|hour_of_day|
-------------+-----------+
            1|         11|
            3|         13|
            3|         18|
            1|         19|
            3|         21|
            3|         23|
-- 10. what was the volume of orders for each day of the week?

SELECT count(order_id) AS total_ordered, dayname(order_time) AS day_of_week
FROM customer_orders_t
GROUP BY day_of_week
ORDER BY total_ordered DESC;

total_ordered|day_of_week|
-------------+-----------+
            5|Wednesday  |
            5|Saturday   |
            3|Thursday   |
            1|Friday     |
            
-- most orders occur on wednesdays and saturdays

            
-- PART B.Runner and Customer Experience
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT  WEEK(registration_date) AS registration_week, COUNT(runner_id) AS `count`
FROM runners r 
GROUP BY registration_week;

registration_week|count|
-----------------+-----+
                0|    1|
                1|    2|
                2|    1|
    
-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT r.runner_id,avg(timestampdiff(MINUTE,c.order_time,r.pickup_time)) AS avg_time
FROM customer_orders_t c
JOIN runner_orders_t r ON c.order_id = r.order_id
GROUP BY r.runner_id;
runner_id|avg_time|
---------+--------+
        1| 15.3333|
        2| 23.4000|
        3| 10.0000|
        
-- NOTE: runner 4 hasn't started yet

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?**

WITH cte AS (
  SELECT
    c.order_id,
    COUNT(c.order_id) AS pizza_total,
    TIMESTAMPDIFF(MINUTE, c.order_time, r.pickup_time) AS `time`
  FROM customer_orders_t c
  JOIN runner_orders_t r ON c.order_id = r.order_id
  WHERE r.cancellation IS NULL
  GROUP BY
    c.order_id,
    `time`
)
SELECT
  subquery.pizza_total,
  subquery.avg_time
FROM
  (
    SELECT
      pizza_total,
      AVG(`time`) AS avg_time
    FROM
      cte
    GROUP BY
      pizza_total
  ) subquery
GROUP BY
  subquery.pizza_total,
  subquery.avg_time;
 
 pizza_total|avg_time|
-----------+--------+
          1| 12.0000|
          2| 18.0000|
          3| 29.0000|
          
-- as the number of pizzas increases, so does the average time(from order to pickup). One pizza can approximately take 10-12 mins
 
 
-- 4. What was the average distance travelled for each customer?
 
 SELECT c.customer_id, ROUND(AVG(r.distance),2) AS avg_distance
 FROM customer_orders_t c
 JOIN runner_orders_t r ON c.order_id = r.order_id
 WHERE r.cancellation IS NULL
 GROUP BY c.customer_id;

customer_id|avg_distance|
-----------+------------+
        101|        20.0|
        102|       16.73|
        103|        23.4|
        104|        10.0|
        105|        25.0|
-- customer 105 is the farthest away, while customer 104 is the closest
 
-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT (max(r.duration)- min(r.duration)) AS difference
FROM customer_orders_t c
JOIN runner_orders_t r ON c.order_id = r.order_id;

difference|
----------+
        30|
-- the difference is 30 minutes

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
WITH CTE AS(
   SELECT runner_id,order_id, round(avg(distance/(duration/60)),1) AS speed
	FROM runner_orders_t
	WHERE cancellation IS NULL
	GROUP BY runner_id,order_id
	ORDER BY runner_id)

SELECT runner_id, avg(speed) AS avg_speed FROM CTE
GROUP BY runner_id;

-- cte query:
runner_id|order_id|speed|
---------+--------+-----+
        1|       1| 37.5|
        1|       2| 44.4|
        1|       3| 40.2|
        1|      10| 60.0|
        2|       4| 35.1|
        2|       7| 60.0|
        2|       8| 93.6|
        3|       5| 40.0|
-- FINAL query:
        
runner_id|avg_speed         |
---------+------------------+
        1|45.525000000000006|
        2|              62.9|
        3|              40.0|

-- runner 2 has driven the fastest & slowest, probably goes on more main roads/highways

-- 7. What is the successful delivery percentage for each runner?

WITH cte as( 
	SELECT runner_id
	,sum(CASE WHEN cancellation IS NULL THEN 1
		ELSE 0
		END) AS success, count(order_id) AS total
	FROM runner_orders_t
	GROUP BY runner_id) 
	
SELECT runner_id,((success/total)*100) AS success_rate
FROM cte;

runner_id|success_rate|
---------+------------+
        1|    100.0000|
        2|     75.0000|
        3|     50.0000|
-- Runner 1 has the best success rate while 3 has the worst. However, it's important to note that runner 3 only has 2 orders, one of which was cancelled
	


-- C. Ingredient Optimisation
-- 1.What are the standard ingredients for each pizza?
-- Have to normalize pizza recipe table
-- 

DROP TABLE IF EXISTS pizza_recipes1;
CREATE TABLE pizza_recipes1 (
  pizza_id INTEGER,
  toppings INTEGER
);
INSERT INTO pizza_recipes1
  (pizza_id, toppings)
VALUES
 (1,1),
 (1,2),
 (1,3),
 (1,4),
 (1,5),
 (1,6),
 (1,8),
 (1,10),
 (2,4),
 (2,6),
 (2,7),
 (2,9), 
 (2,11),
 (2,12);


SELECT pizza_name, group_concat(topping_name) AS standard_toppings
from(
	SELECT pn.pizza_name,pt.topping_name
	FROM pizza_recipes1 pr
	JOIN pizza_names pn ON pr.pizza_id = pn.pizza_id 
	JOIN pizza_toppings pt  ON pr.toppings = pt.topping_id 
	ORDER BY pn.pizza_name) AS subquery
GROUP BY pizza_name 

-- 2.What was the most commonly added extra?

SELECT * FROM customer_orders_t

	


-- 3.What was the most common exclusion?
-- 4.Generate an order item for each record in the customers_orders table in the format of one of the following:

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?



