# <p align="center"> Case Study #3 - Foodie-Fi Solutions
 
## <p align="center">  Data Analysis Questions

### 1. How many customers has Foodie-Fi ever had?
```sql
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM subscriptions s;
```
**Output:**
| total_customers |
|:---------------:|
|      1,000      |
 
### 2. What is the monthly distribution of trial plan start_date values for our dataset?
  
```sql
SELECT MONTH(start_date) AS `month`, COUNT(*) AS total
FROM subscriptions s 
WHERE plan_id = 0
GROUP BY `month`
ORDER BY `month`; 
```
**Output:**
 | month | total |
|:-----:|:-----:|
|   1   |   88  |
|   2   |   68  |
|   3   |   94  |
|   4   |   81  |
|   5   |   88  |
|   6   |   79  |
|   7   |   89  |
|   8   |   88  |
|   9   |   87  |
|  10   |   79  |
|  11   |   75  |
|  12   |   84  |
  
- The month with lowest number of plans was February, while the month with the largest number of plans was March. 
  
### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
  
```sql
SELECT p.plan_name, COUNT(*) AS total
FROM subscriptions s 
JOIN plans p ON s.plan_id =p.plan_id 
WHERE start_date > '2020-12-31'
GROUP BY p.plan_name;   
```
**Output:**
|    plan_name    | total |
|:---------------:|:-----:|
|     churn       |   71  |
|   pro monthly   |   60  |
|    pro annual   |   63  |
| basic monthly   |   8   |
  
- In 2021,  the most common change in plan was to the Churn plan. Out of all paying plans, Pro annual was the most popular upgrade. I also noticed there were no trial plans in 2021. Since all customers begin with a trial plan then upgrade/downgrade accordingly, no new customers were acquired in the new year.
 To double check this assumption, I used the query below to find any new customers in 2021 that did not join in 2020. The output did not list anything.
 ```sql
SELECT customer_id, start_date
FROM subscriptions
WHERE start_date LIKE '2021%'
AND customer_id NOT IN (
    SELECT customer_id
    FROM subscriptions
    WHERE start_date LIKE '2020%');
```  

 ### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
  
```sql
SELECT
    COUNT(DISTINCT customer_id) AS customer_count
    ,ROUND(((COUNT(DISTINCT customer_id)) / (SELECT COUNT(DISTINCT customer_id) FROM  subscriptions))*100, 1) AS churn_percentage
FROM subscriptions
WHERE plan_id = 4;  
```
**Output:**
| customer_count | churn_percentage |
|:--------------:|:----------------:|
|      307       |       30.7       |
  
- 30.7% of all customers have churned.
  
### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
  
```sql
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
```
**Output:**
| churn_count | percentage_churned |
|:-----------:|:------------------:|
|      92     |         9.2        |
- 9.2% of all customers have churned after their free trial.
  
### 6. What is the number and percentage of customer plans after their initial free trial?
  
```sql
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
```
**Output:**
 | next_plan | total | percent_total |
|:---------:|:-----:|:-------------:|
|     1     |  546  |      54.6     |
|     2     |  325  |      32.5     |
|     3     |   37  |       3.7     |
|     4     |   92  |       9.2     |
  
- The largest percentage of customers switch to the Basic monthly plan after their free trial ends, while the lowest percentage of customers switch to the Pro annual plan. Foofie-fi can further investigate into why the pro annual plan of $199 isn't quite justifiable after the trial period & restrategize accordingly.
  
### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
  
  
```sql
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
```
**Output:**
| plan_id | customer_count | percent_total |
|:-------:|:--------------:|:-------------:|
|    0    |       19       |      1.9      |
|    1    |       224      |      22.4     |
|    2    |       326      |      32.6     |
|    3    |       195      |      19.5     |
|    4    |       236      |      23.6     |

- As at December 31, 2020, the most popular upgrade was to the Pro monthly plan. The least popular was for trial plans. 

### 8. How many customers have upgraded to an annual plan in 2020?
  
```sql
SELECT COUNT(DISTINCT customer_id) AS customer_count
FROM subscriptions s 
WHERE plan_id = 3 AND start_date <='2020-12-31';  
```
**Output:**
 | customer_count |
|:--------------:|
|       195      |
 
### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
  
```sql
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
```
**Output:**
| avg_days |
|:--------:|
|    105   |
  
### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
  
```sql
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
```
**Output:**
 |   breakdown   | total_customers | avg_days_to_upgrade |
|:-------------:|:---------------:|:-------------------:|
|   0-30 days   |        48       |          10         |
|   30-60 days  |        25       |          42         |
|   60-90 days  |        33       |          71         |
|  90-120 days  |        35       |         100         |
| 120-150 days  |        43       |         133         |
| 150-180 days  |        35       |         162         |
| 180-210 days  |        27       |         190         |
| 210-240 days  |        4        |         224         |
| 240-270 days  |        5        |         257         |
| 270-300 days  |        1        |         285         |
| 300-330 days  |        1        |         327         |
| 330-360 days  |        1        |         346         |
 
- Majority of customers upgrade to an annual plan within the first 30 days.
- At around 120-150 days (3-5 months) there is a slight increase of customers making the switch. Then after this period of time, less and less customers make the switch until there is barely any upgrades occuring from 270 days and on.
	
 ### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
  
```sql
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
```
**Output:**
| downgrade_count |
|:---------------:|
|        0         |

- no customers made this downgrade	    
                  
