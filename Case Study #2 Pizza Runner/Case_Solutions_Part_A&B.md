# <p align="center"> Case Study #2 - Pizza Runner

## <p align="center">  Data Cleaning
- Before answering any business questions, it was evident that tables `customer_orders` & `runner_orders` had to be cleaned
- For `customer_orders`, there were string nulls and blank values:
--- 
  
  ```sql
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
 ```
  
 - For `runner_orders`:
    - Remove 'NaN' strings
    - standardize the distance & duration columns (remove string values)
    - change data types
 
```sql
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
```
---   
## <p align="center"> Data Analysis Questions  
### <p align="center"> Part A. Pizza Metrics  
### 1. How many pizzas were ordered?

```sql
SELECT COUNT(pizza_id) AS total
FROM customer_orders_t;
```
  
**Output:**
| total |
|:-----:|
|   14  |

### 2. How many unqiue customer orders were made?  
```sql
SELECT COUNT(DISTINCT(order_id)) AS count_orders
FROM customer_orders_t;  
```  
  
**Output:**  
| count_orders |
|:------------:|
|      10      |
  
 ### 3. How many successful orders were delivered by each runner?  
```sql
SELECT runner_id,COUNT(order_id) AS total_successful_orders
FROM runner_orders_T
WHERE cancellation IS NULL
GROUP BY runner_id;  
```  
  
**Output:**  
| runner_id | total_successful_orders |
|:---------:|:-----------------------:|
|     1     |            4             |
|     2     |            3             |
|     3     |            1             |
  
### 4.  How many of each type of pizza was delivered?
```sql
SELECT COUNT(c.pizza_id) AS count, pn.pizza_name
FROM customer_orders_t c
JOIN pizza_names pn ON c.pizza_id = pn.pizza_id
JOIN runner_orders_t r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL 
GROUP BY pn.pizza_name;  
```  
  
**Output:**   
 | count | pizza_name |
|:-----:|:----------:|
|   9   |  Meatlovers |
|   3   | Vegetarian |
 
### 5.  How many vegetarian and meatlovers were ordered by each customer?
```sql
SELECT c.customer_id,COUNT(c.pizza_id) AS orders, pn.pizza_name
FROM customer_orders_t c
JOIN pizza_names pn ON c.pizza_id = pn.pizza_id
JOIN runner_orders_t r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL 
GROUP BY c.customer_id,pn.pizza_name
ORDER BY c.customer_id;  
```  
  
**Output:**   
| customer_id | orders | pizza_name |
|:-----------:|:------:|:----------:|
|     101     |   2    |  Meatlovers |
|     102     |   2    |  Meatlovers |
|     102     |   1    | Vegetarian |
|     103     |   2    |  Meatlovers |
|     103     |   1    | Vegetarian |
|     104     |   3    |  Meatlovers |
|     105     |   1    | Vegetarian |
  
### 6.  What was the maximum number of pizzas delivered in a single order?
```sql
SELECT MAX(count_pizzas) AS max_num
FROM (
    SELECT COUNT(pizza_id) AS count_pizzas
    FROM customer_orders_t
    GROUP BY order_id
    ) subquery;  
```  
  
**Output:**    
|max_num|
|:-----:|
|      3|
  
### 7.  For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
```sql
SELECT c.customer_id,
	SUM(CASE 
		WHEN c.exclusions IS NOT NULL THEN 1
		WHEN c.extras IS NOT NULL THEN 1
		ELSE 0
	  END) AS MinOneChange,
	SUM(CASE
		WHEN (c.exclusions IS NULL) and
		(c.extras IS NULL) THEN 1
		ELSE 0
	  END) AS NoChange
FROM customer_orders_t c
JOIN runner_orders_t ro ON c.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY c.customer_id;  
```  
  
**Output:**    
  |customer_id|MinOneChange|NoChange|
|:---------:|:---------:|:------:|
|    101    |     0     |    2   |
|    102    |     0     |    3   |
|    103    |     3     |    0   |
|    104    |     2     |    1   |
|    105    |     1     |    0   |

### 8. How many pizzas were delivered that had both exclusions and extras? 
```sql
SELECT COUNT(c.order_id) AS num_pizza
FROM customer_orders_t c
JOIN runner_orders_t ro ON c.order_id = ro.order_id
WHERE ro.cancellation IS NULL AND c.exclusions IS NOT NULL and c.extras IS NOT NULL;  
```  
  
**Output:**    
| num_pizza |
|:---------:|
|      1    |


 ### 9.  What was the total volume of pizzas ordered for each hour of the day?
```sql
SELECT COUNT(order_id) AS total_ordered, HOUR(order_time) AS hour_of_day
FROM customer_orders_t
GROUP BY hour_of_day
ORDER BY hour_of_day;  
```  
  
**Output:**   
| total_ordered | hour_of_day |
|:-------------:|:-----------:|
|       1       |      11     |
|       3       |      13     |
|       3       |      18     |
|       1       |      19     |
|       3       |      21     |
|       3       |      23     |
  
### 10.  What was the volume of orders for each day of the week?
```sql
SELECT COUNT(order_id) AS total_ordered, DAYNAME(order_time) AS day_of_week
FROM customer_orders_t
GROUP BY day_of_week
ORDER BY total_ordered DESC;  
```  
  
**Output:**  
| total_ordered | day_of_week |
|--------------|-------------|
|      5       |  Wednesday  |
|      5       |  Saturday   |
|      3       |  Thursday   |
|      1       |   Friday    |
---   
### <p align="center"> Part B. Runner & Customer Experience
 ### 1.  How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
```sql
SELECT WEEK(registration_date) AS registration_week, COUNT(runner_id) AS `count`
FROM runners r 
GROUP BY registration_week;  
```  
  
**Output:** 
| registration_week | count |
|:-----------------:|:-----:|
|         0         |   1   |
|         1         |   2   |
|         2         |   1   |
  
  
### 2.  What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
```sql
SELECT r.runner_id,AVG(TIMESTAMPDIFF(MINUTE,c.order_time,r.pickup_time)) AS avg_time
FROM customer_orders_t c
JOIN runner_orders_t r ON c.order_id = r.order_id
GROUP BY r.runner_id;  
```  
  
**Output:**  
 | runner_id | avg_time |
|:----------:|:----------:|
|     1    |  15.3333 |
|     2    |  23.4000 |
|     3    |  10.0000 |
 
- NOTE: runner 4 hasn't started yet  
### 3.  Is there any relationship between the number of pizzas and how long the order takes to prepare?
```sql
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
    `time`)
  
SELECT
  subquery.pizza_total,
  subquery.avg_time
FROM
  (
    SELECT
      pizza_total,
      AVG(`time`) AS avg_time
    FROM cte
    GROUP BY
      pizza_total
  ) subquery
GROUP BY
  subquery.pizza_total,
  subquery.avg_time;  
```  
  
**Output:** 
| pizza_total | avg_time |
|:-----------:|:--------:|
|           1|  12.0000 |
|           2|  18.0000 |
|           3|  29.0000 |
  
- As the number of pizza orders increases, so does the average time(from order to pickup) as expected.   Also from order to pickup time, making 2 pizzas is the most efficient( 1 pizza = 12 minutes, 2 pizzas = 9 minutes per pizza, 3 pizzas = 9.6 minutes per pizza)
  
### 4. What was the average distance travelled for each customer? 
```sql
 SELECT c.customer_id, ROUND(AVG(r.distance),2) AS avg_distance_km
 FROM customer_orders_t c
 JOIN runner_orders_t r ON c.order_id = r.order_id
 WHERE r.cancellation IS NULL
 GROUP BY c.customer_id;  
```  
  
**Output:** 
| customer_id | avg_distance_km |
|:-----------:|:------------:|
| 101         | 20.0         |
| 102         | 16.73        |
| 103         | 23.4         |
| 104         | 10.0         |
| 105         | 25.0         |
- customer 105 is the farthest away, while customer 104 is the closest  
  
### 5. What was the difference between the longest and shortest delivery times for all orders? 
```sql
SELECT (MAX(r.duration)- MIN(r.duration)) AS difference
FROM customer_orders_t c
JOIN runner_orders_t r ON c.order_id = r.order_id;  
```  
  
**Output:** 
 | difference |
|:----------:|
|         30 |
- the difference is 30 minutes
  
### 6.  What was the average speed for each runner for each delivery and do you notice any trend for these values?
```sql
WITH CTE AS(
   SELECT runner_id,order_id, ROUND(AVG(distance/(duration/60)),1) AS speed
	FROM runner_orders_t
	WHERE cancellation IS NULL
	GROUP BY runner_id,order_id
	ORDER BY runner_id)

SELECT runner_id, AVG(speed) AS avg_speed FROM CTE
GROUP BY runner_id;  
```  
  
**CTE Output:**  
| runner_id|order_id|speed|
|:--------:|:-------:|:---:|
|        1|       1| 37.5|
|        1|       2| 44.4|
|        1|       3| 40.2|
|        1|      10| 60.0|
|        2|       4| 35.1|
|        2|       7| 60.0|
|        2|       8| 93.6|
|        3|       5| 40.0|
 
**Final Query Output:**
 | runner_id |    avg_speed     |
|:---------:|:---------------:|
|     1     | 45.525000000000006 |
|     2     |       62.9      |
|     3     |       40.0      |
 
### 7.  What is the successful delivery percentage for each runner?
```sql
WITH cte as( 
	SELECT runner_id
	,SUM(CASE WHEN cancellation IS NULL THEN 1
	ELSE 0
	END) AS success, count(order_id) AS total
	FROM runner_orders_t
	GROUP BY runner_id) 
	
SELECT runner_id,((success/total)*100) AS success_rate
FROM cte;  
```  
  
**Output:**   
| runner_id | success_rate |
|:--------:|:-----------:|
|    1     |   100.0000  |
|    2     |    75.0000  |
|    3     |    50.0000  |
  
- Runner 1 has the best success rate while 3 has the worst. However, it's important to note that runner 3 only has 2 orders, one of which was cancelled   
