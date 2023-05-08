
CREATE SCHEMA dannys_diner;
USE dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
 /* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
 
 SELECT s.customer_id, sum(m.price) AS total_amount_spent
 FROM sales s
 JOIN menu m ON s.product_id = m.product_id
 GROUP BY s.customer_id;
  
-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, count(DISTINCT order_date) AS total_visits
FROM sales s 
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

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

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.product_name, count(s.product_id) AS quantity
FROM menu m
JOIN sales s ON m.product_id = s.product_id
GROUP BY product_name
ORDER BY quantity DESC;

-- 5. Which item was the most popular for each customer?

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

-- 6. Which item was purchased first by the customer after they became a member?

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

-- 7. Which item was purchased just before the customer became a member?

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

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id, count(s.product_id)AS total_items, sum(m.price) AS total_Sales 
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE order_date < join_date
GROUP BY customer_id
ORDER BY customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

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

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?

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

-- Bonus Question to recreate the table "Join All The Things"

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


-- Bonus Question "Rank All The Things"

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

