# <p align="center"> Case Study #1 - Danny's Diner
 </p>
 
<p align="center">  
  <img src="https://github.com/abigayl3/SQL_Challenges/blob/main/Case%20Study%20%231%20Danny's%20Diner/Images/1.png" width="500" height="500" align="center">
</p>

<p align="center"> 
  <a href="https://8weeksqlchallenge.com/case-study-1/">Access The Full Challenge Here</a>
</p>

---
## Case Background

In 2021, Danny opened a small Japanese Restuarant selling 3 different menu items; Sushi, Curry, and Ramen. He wants to better understand his customers by investigating their visiting, spending, and ordering patterns using data. With these insights, Danny can decide whether he should expand his current loyalty program. 

## Understanding the Datasets

<p align="center">  
<img  src="https://github.com/abigayl3/SQL_Challenges/blob/main/Case%20Study%20%231%20Danny's%20Diner/Images/ERD%20.png" width="600" height="400" align="center">
</p>

The ERD shows 3 different tables available for analysis: the data table `sales` and the lookup tables `members` & `menu`. The diagram shows the relationship between the tables through their primary and foreign keys.
- The primary key for `members` is customer_id with a one to many relationship to `sales`
- The primary key for `menu` is product_id with a one to many relationship to `sales`
- `sales` contains the foreign keys of customer_id & product_id

``Sales Table``
| customer_id | order_date | product_id |
|-------------|------------|------------|
|      A      | 2021-01-01 |      1     |
|      A      | 2021-01-01 |      2     |
|      A      | 2021-01-07 |      2     |
|      A      | 2021-01-10 |      3     |
|      A      | 2021-01-11 |      3     |
|      A      | 2021-01-11 |      3     |
|      B      | 2021-01-01 |      2     |
|      B      | 2021-01-02 |      2     |
|      B      | 2021-01-04 |      1     |
|      B      | 2021-01-11 |      1     |
|      B      | 2021-01-16 |      3     |
|      B      | 2021-02-01 |      3     |
|      C      | 2021-01-01 |      3     |
|      C      | 2021-01-01 |      3     |
|      C      | 2021-01-07 |      3     |


``menu table``
| product_id | product_name | price |
|------------|--------------|-------|
|      1     |    sushi     |  10   |
|      2     |    curry     |  15   |
|      3     |    ramen     |  12   |


``members table``
| customer_id | join_date  |
|-------------|------------|
|      A      | 2021-01-07 |
|      B      | 2021-01-09 |

---

## SQL Concepts

This case focuses on the follwoing SQL concepts:
- Common Table Expressions
- Group By Aggregates
- Window Functions for ranking
- Joins

<p> 
  <a href="https://github.com/abigayl3/SQL_Challenges/blob/main/Case%20Study%20%231%20Danny's%20Diner/Case_Solution.md"> Click here for my solutions to the case study questions</a>
</p>
