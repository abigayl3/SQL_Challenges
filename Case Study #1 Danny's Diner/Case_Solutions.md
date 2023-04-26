# <p align="center"> Case Study #1 - Danny's Diner Solutions
 
## <p align="center">  Data Analysis Questions
  
### 1. What is the total amount each customer spent at the restaurant?
```sql
 SELECT s.customer_id, sum(m.price) AS total_amount_spent
 FROM sales s
 JOIN menu m ON s.product_id = m.product_id
 GROUP BY s.customer_id;
 ```
**Output:**

| customer_id | total_amount_spent |
|:----------:|:-----------------:|
|      A     |         76         |
|      B     |         74         |
|      C     |         36         |


  
- Customers A & B have spent the most
  
### 2. How many days has each customer visited the restaurant?
- I used DISTINCT to count unique order dates assuming orders placed on the same day were from the same visit
```sql
SELECT customer_id, count(DISTINCT order_date) AS total_visits
FROM sales s 
GROUP BY customer_id;
  ```
 **Output:**
 | customer_id | total_visits |
|:----------:|:------------:|
|      A     |       4      |
|      B     |       6      |
|      C     |       2      |

  
  - Customer B has visited the restaurant the most

  ### 3. What was the first item from the menu purchased by each customer?
  ```sql
WITH rnk as
(SELECT 
    m.product_name
	,s.customer_id
	,s.order_date
	,DENSE_RANK () OVER (PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS rnk
FROM sales s
JOIN menu m 
ON s.product_id = m.product_id 
GROUP BY s.customer_id,s.order_date, m.product_name)

SELECT customer_id, product_name
FROM rnk
WHERE rnk = 1;
  ```
**Output:**
| customer_id | product_name |
|:----------:|:------------:|
|      A     |     sushi    |
|      A     |     curry    |
|      B     |     curry    |
|      C     |     ramen    |

  - customer A ordered both sushi and curry as their first order. The order_date column is a date data type versus a timestamp, so we don't know which one was technically ordered first
  

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
  
```sql
SELECT m.product_name, count(s.product_id) AS quantity
FROM menu m
JOIN sales s ON m.product_id = s.product_id
GROUP BY product_name
ORDER BY quantity DESC;
```
**Output:**
| product_name | quantity |
|:------------:|:--------:|
|    ramen     |     8    |
|    curry     |     4    |
|    sushi     |     3    |

 - The most purchased item is Ramen
  
### 5. Which item was the most popular for each customer?
  
 ```sql
 WITH item AS 
(SELECT 
    m.product_name 
   ,count(s.product_id) AS quantity 
   ,s.customer_id
   ,dense_rank() over(PARTITION BY s.customer_id ORDER BY count(s.product_id) DESC) AS rnk
FROM menu m
JOIN sales s ON m.product_id = s.product_id
GROUP BY s.customer_id, m.product_name)

SELECT customer_id, product_name,  quantity
FROM item
WHERE rnk = 1;
 ```
**Output:**
| customer_id | product_name | quantity |
|:----------:|:------------:|:--------:|
|      A     |    ramen     |     3    |
|      B     |    curry     |     2    |
|      B     |    sushi     |     2    |
|      B     |    ramen     |     2    |
|      C     |    ramen     |     3    |

  - Ramen is the most popular item for customer A and C
  - Customer B has purchased each of the menu items the same amount of times
  
### 6. Which item was purchased first by the customer after they became a member?
  
```sql
WITH rnk as
(SELECT 
   m.product_name
  ,s.customer_id
  ,s.order_date
  ,mb.join_date
  ,DENSE_RANK () OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id 
WHERE s.order_date >= mb.join_date)

SELECT 
  m.product_name
  ,s.customer_id
  ,s.order_date
  ,mb.join_date
FROM rnk
WHERE rnk = 1;
```
  
**Output:**
| product_name | customer_id | order_date | join_date  |
|:------------:|:----------:|:----------:|:----------:|
|    curry     |      A     | 2021-01-07 | 2021-01-07 |
|    sushi     |      B     | 2021-01-11 | 2021-01-09 |

- Customer A ordered curry on the same day they became a member
- Customer B ordered sushi first after they became a member
- Customer C has not become a member yet
  
### 7. Which item was purchased just before the customer became a member?

  
 ```sql
WITH rnk as
(SELECT 
  m.product_name
	,s.customer_id
	,s.order_date
	,mb.join_date
	,DENSE_RANK () OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rnk
 FROM sales s
 JOIN menu m ON s.product_id = m.product_id
 JOIN members mb ON s.customer_id = mb.customer_id 
 WHERE s.order_date < mb.join_date)

SELECT m.product_name, s.customer_id, s.order_date, mb.join_date
FROM rnk
WHERE rnk = 1;
```
**Output:**                                                              
| product_name | customer_id | order_date  | join_date   |
|:------------:|:-----------:|:----------:|:-----------:|
|    sushi     |      A      | 2021-01-01 | 2021-01-07  |
|    curry     |      A      | 2021-01-01 | 2021-01-07  |
|    sushi     |      B      | 2021-01-04 | 2021-01-09  |

- Customer A's last order before they became a member was Sushi & Curry, and Customer B's last order was also Sushi                                   
                                  
### 8. What is the total items and amount spent for each member before they became a member?
                                   
```sql
SELECT s.customer_id, count(s.product_id)AS total_items, sum(m.price) AS total_Sales 
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE order_date < join_date
GROUP BY customer_id
ORDER BY customer_id;     
```
**Output:**  
| customer_id | total_items | total_sales |
|:-----------:|:-----------:|:-----------:|
|      A      |      2      |      25     |
|      B      |      3      |      40     |
  
- Customer A purchased 2 items for $25
- Customer B purchased 3 items for $40
  
### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
- Using a CTE and a case statement, I was able to allocate points based on if the items ordered were Sushi (for 20 points) or any other menu item (for 10 points)
```sql
WITH points as
 (SELECT *, 
    CASE 
    WHEN product_name = 'Sushi' THEN price * 20 
    ELSE price * 10 
    END AS points 
  FROM menu)

SELECT s.customer_id, sum(points) AS total_points
FROM points p
JOIN sales s ON p.product_id = s.product_id 
GROUP BY s.customer_id;
```
**Output:**  
| customer_id | total_points |
|:-----------:|:------------:|
|      A      |      860     |
|      B      |      940     |
|      C      |      360     |

### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
- I created a `dates` CTE with date intervals and used a case statement to allocate the points under the following assumptions:
  - From January 1st to the day before their join date, each $1 spent equates to 10 points and sushi has a 2x points multiplier
  - From the join date to 6 days later, all items have a 2x points multiplier (days 1 to 6, total of 7 days)
  - From day 7 to the last day of January, each $1 spent equates to 10 points and sushi has a 2x points multiplier
  
  
```sql
WITH dates AS 
(SELECT * 
   ,DATE_ADD(join_date, INTERVAL 6 DAY) AS frame_date 
   ,LAST_DAY('2021-01-31') AS last_date
 FROM members) 

SELECT 
  s.customer_id 
  ,SUM(CASE
    WHEN s.order_date < d.join_date AND m.product_name = 'Sushi' THEN m.price *20
    WHEN s.order_date BETWEEN d.join_date AND d.frame_date THEN m.price * 20
    WHEN m.product_name = 'Sushi' AND s.order_date BETWEEN d.frame_date AND d.last_date THEN m.price * 20
    ELSE m.price * 10
    END) AS points
FROM dates d
JOIN sales s ON d.customer_id = s.customer_id
JOIN menu m ON s.product_id = m.product_id
WHERE s.order_date < d.last_date
GROUP BY s.customer_id
ORDER BY s.customer_id;
```
**Output:**  
- Dates CTE output: 
                                
| customer_id | join_date  | frame_date | last_date  |
|:-----------:|:---------:|:---------:|:----------:|
|      A      | 2021-01-07| 2021-01-13| 2021-01-31 |
|      B      | 2021-01-09| 2021-01-15| 2021-01-31 |
                                
- Final query output:
                                
| customer_id | points |
|:-----------:|:------:|
|      A      |  1370  |
|      B      |   820  |
  
---
### Bonus Questions 
<a href="https://8weeksqlchallenge.com/case-study-1/"> Refer to the Bonus Questions Here
#### Join All The Things - Recreate the output
- I used a left join to return all the data provided in the data table `sales` and to match with the data from the look up tables `menu` and `members`
```sql
 SELECT 
    s.customer_id
  ,s.order_date
  ,m.product_name
  ,m.price
  ,CASE 
    WHEN mb.join_date > s.order_date THEN 'N'
	  WHEN mb.join_date <= s.order_date THEN 'Y'
	  ELSE 'N'
	END AS `member`
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id 
LEFT JOIN members mb ON s.customer_id = mb.customer_id;
```
**Output:**    

| customer_id | order_date | product_name | price | member |
|:-----------:|:---------:|:------------:|:-----:|:------:|
|      A      |2021-01-01 |    sushi     |  10   |   N    |
|      A      |2021-01-01 |    curry     |  15   |   N    |
|      A      |2021-01-07 |    curry     |  15   |   Y    |
|      A      |2021-01-10 |    ramen     |  12   |   Y    |
|      A      |2021-01-11 |    ramen     |  12   |   Y    |
|      A      |2021-01-11 |    ramen     |  12   |   Y    |
|      B      |2021-01-01 |    curry     |  15   |   N    |
|      B      |2021-01-02 |    curry     |  15   |   N    |
|      B      |2021-01-04 |    sushi     |  10   |   N    |
|      B      |2021-01-11 |    sushi     |  10   |   Y    |
|      B      |2021-01-16 |    ramen     |  12   |   Y    |
|      B      |2021-02-01 |    ramen     |  12   |   Y    |
|      C      |2021-01-01 |    ramen     |  12   |   N    |
|      C      |2021-01-01 |    ramen     |  12   |   N    |
|      C      |2021-01-07 |    ramen     |  12   |   N    |

#### Rank All The Things - Recreate the Output
- Similarly to the question above, I used a left join to return all records from the `sales` table to match with the other tables `menu` and `members`
- I added the column 'ranking' to match the output by using a case statement and the window function rank so that each customer that is a member has a ranking of their orders based on the order date                                    
```sql
WITH cte as(
SELECT 
  s.customer_id
  ,s.order_date
  ,m.product_name
  ,m.price
  ,CASE 
    WHEN mb.join_date > s.order_date THEN 'N'
    WHEN mb.join_date <= s.order_date THEN 'Y'
    ELSE 'N'
  END AS `member`
FROM sales s
LEFT JOIN menu m ON s.product_id = m.product_id 
LEFT JOIN members mb ON s.customer_id = mb.customer_id)
                                    
SELECT *,
  CASE
    WHEN MEMBER = 'N' THEN NULL
    ELSE rank() OVER (PARTITION BY customer_id,member ORDER BY order_date)
  END AS ranking
FROM cte;                                    
```
**Output:**                                       
| customer_id | order_date | product_name | price | member | ranking |
|:-----------:|:---------:|:------------:|:-----:|:------:|:-------:|
|      A      | 2021-01-01|    sushi     |  10   |   N    |         |
|      A      | 2021-01-01|    curry     |  15   |   N    |         |
|      A      | 2021-01-07|    curry     |  15   |   Y    |    1    |
|      A      | 2021-01-10|    ramen     |  12   |   Y    |    2    |
|      A      | 2021-01-11|    ramen     |  12   |   Y    |    3    |
|      A      | 2021-01-11|    ramen     |  12   |   Y    |    3    |
|      B      | 2021-01-01|    curry     |  15   |   N    |         |
|      B      | 2021-01-02|    curry     |  15   |   N    |         |
|      B      | 2021-01-04|    sushi     |  10   |   N    |         |
|      B      | 2021-01-11|    sushi     |  10   |   Y    |    1    |
|      B      | 2021-01-16|    ramen     |  12   |   Y    |    2    |
|      B      | 2021-02-01|    ramen     |  12   |   Y    |    3    |
|      C      | 2021-01-01|    ramen     |  12   |   N    |         |
|      C      | 2021-01-01|    ramen     |  12   |   N    |         |
|      C      | 2021-01-07|    ramen     |  12   |   N    |         |

---
### Insights                                    
                                    

                                
