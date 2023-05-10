-- Data Analysis Questions

-- 1. How many customers has Foodie-Fi ever had?

SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM subscriptions s;

-- 2.What is the monthly distribution of trial plan start_date values for our dataset?
           
SELECT MONTH(start_date) AS `month`, COUNT(*) AS total
FROM subscriptions s 
WHERE plan_id = 0
GROUP BY `month`
ORDER BY `month`;

-- 3.What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
   
SELECT p.plan_name, COUNT(*) AS total
FROM subscriptions s 
JOIN plans p ON s.plan_id =p.plan_id 
WHERE start_date > '2020-12-31'
GROUP BY p.plan_name; 

-- 4.What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT
    COUNT(DISTINCT customer_id) AS customer_count
    ,ROUND(((COUNT(DISTINCT customer_id)) / (SELECT COUNT(DISTINCT customer_id) FROM  subscriptions))*100, 1) AS churn_percentage
FROM subscriptions


-- 5.How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

WITH cte AS
(	
    SELECT * 
   ,LEAD(plan_id,1) OVER (PARTITION BY customer_id ORDER BY plan_id) AS next_plan
    FROM subscriptions s
) 
 
 SELECT
    COUNT(next_plan) AS churn_count
    ,ROUND((COUNT(DISTINCT customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions))*100, 1) AS percentage_churned
FROM cte
WHERE plan_id = 0 AND next_plan = 4; 

 
-- 6.What is the number and percentage of customer plans after their initial free trial?

WITH cte AS
(
    SELECT * 
    ,LEAD(plan_id,1) OVER (PARTITION BY customer_id ORDER BY plan_id) AS next_plan
    FROM subscriptions s
)  
 
SELECT 
    next_plan 
    ,COUNT(next_plan) AS total
    ,ROUND(COUNT(next_plan) / (SELECT COUNT(DISTINCT customer_id) FROM cte) * 100, 1) AS percent_total
FROM cte
WHERE plan_id = 0
GROUP BY next_plan
ORDER BY next_plan; 
        
-- 7.What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

WITH cte_recent_date AS	
(
SELECT s.customer_id, s.plan_id, s.start_date
FROM subscriptions s
JOIN  (SELECT customer_id, MAX(start_date) AS max_start_date
    FROM subscriptions
    WHERE start_date <='2020-12-31'
    GROUP BY customer_id) s2
    ON s.customer_id = s2.customer_id AND s.start_date = s2.max_start_date
)

SELECT 
	plan_id 
	,count(customer_id) AS customer_count
	,ROUND(COUNT(customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100, 1) AS percent_total
FROM cte_recent_date
GROUP BY plan_id
ORDER BY plan_id;
      
      
 -- 8. How many customers have upgraded to an annual plan in 2020?

SELECT count(DISTINCT customer_id) AS customer_count
FROM subscriptions s 
WHERE plan_id = 3 AND start_date <='2020-12-31'; 

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

WITH trial as
(SELECT *
  FROM subscriptions s 
  WHERE plan_id = 0)
  
,annual as
(SELECT * 
  FROM subscriptions s2 
  WHERE plan_id = 3)

SELECT ROUND(AVG(DATEDIFF(a.start_date, t.start_date)),0) AS avg_days
FROM trial t
JOIN annual a ON t.customer_id = a.customer_id;  
     
-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
         
WITH trial AS	
(SELECT customer_id, start_date AS trial_date
  FROM subscriptions
  WHERE plan_id = 0)
  
, annual AS 
(SELECT customer_id, start_date as annual_date
  FROM subscriptions
  WHERE plan_id = 3)
  
, time_to_upgrade AS 
(SELECT 
    t.customer_id
    ,FLOOR(DATEDIFF(a.annual_date, t.trial_date) / 30) AS period
    ,DATEDIFF(a.annual_date, t.trial_date) AS days_to_upgrade
  FROM trial t
  JOIN annual a ON t.customer_id = a.customer_id
  WHERE a.annual_date IS NOT NULL)
  
SELECT 
    CONCAT(period * 30, '-', (period + 1) * 30, ' days') AS breakdown
    ,COUNT(*) AS total_customers
    ,ROUND(AVG(days_to_upgrade), 0) AS avg_days_to_upgrade
FROM time_to_upgrade
GROUP BY breakdown
ORDER BY avg_days_to_upgrade;  


-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

WITH cte AS 
 ( 
    SELECT * 
    ,LEAD(plan_id,1) OVER (PARTITION BY customer_id ORDER BY plan_id) AS next_plan
    FROM subscriptions s
 ) 
 
SELECT COUNT(next_plan) AS downgrade_count 		
FROM cte
WHERE plan_id = 2 
  AND next_plan = 1
  AND start_date <= '2020-12-31';                            
           
