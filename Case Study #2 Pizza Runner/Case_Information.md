# <p align="center"> Case Study #2 - Pizza Runner
 </p>

<p align="center">  
  <img src="https://github.com/abigayl3/SQL_Challenges/blob/main/Case%20Study%20%232%20Pizza%20Runner/Images/pizza_runner_title.png" width="500" height="500" align="center">
</p>
<p align="center"> 
  <a href="https://8weeksqlchallenge.com/case-study-2/">Access The Full Challenge Here</a>
</p>


---
## Case Background

Danny started ‘Pizza Runner’ as a way to “Uberize” his pizza business. He started recruiting delivery people, known as ‘Runners’, to deliver fresh pizza from Pizza Runner Headquarters. Danny understands that data collection will be critical for business growth but requires further assistance to clean his data and apply some calculations to better optimize his operations.

## Understanding the Data
<p align="center">  
<img  src="https://github.com/abigayl3/SQL_Challenges/blob/main/Case%20Study%20%232%20Pizza%20Runner/Images/ERD_PizzaRunner.png" width="700" height="400" align="center">
</p>

The database includes 6 tables with different relationships to eachother
- `runners` has a primary key of runner_id with a one to many relationship with `runner_orders` that has the foreign key, runner_id.
- `runner_orders` relates to `customer_orders` through the order_id.
- `customer_orders` has foreign keys, pizza_id, relating to both `pizza_names` and `pizza_recipes`.
- `pizza_toppings` has no relationship to any table within the ERD. 

Table 1: `runners`
|   runner_id   | registration_date |
|:-------------:|:-----------------:|
|       1       |   2021-01-01      |
|       2       |   2021-01-03      |
|       3       |   2021-01-08      |
|       4       |   2021-01-15      |

Table 2: `customer_orders`
| order_id | customer_id | pizza_id | exclusions | extras |      order_time      |
|:--------:|:-----------:|:-------:|:----------:|:------:|:--------------------:|
|    1     |     101     |    1    |            |        |  2021-01-01 18:05:02 |
|    2     |     101     |    1    |            |        |  2021-01-01 19:00:52 |
|    3     |     102     |    1    |            |        |  2021-01-02 23:51:23 |
|    3     |     102     |    2    |    NaN     |        |  2021-01-02 23:51:23 |
|    4     |     103     |    1    |     4      |        |  2021-01-04 13:23:46 |
|    4     |     103     |    1    |     4      |        |  2021-01-04 13:23:46 |
|    4     |     103     |    2    |     4      |        |  2021-01-04 13:23:46 |
|    5     |     104     |    1    |   null     |   1    |  2021-01-08 21:00:29 |
|    6     |     101     |    2    |   null     |  null  |  2021-01-08 21:03:13 |
|    7     |     105     |    2    |   null     |   1    |  2021-01-08 21:20:29 |
|    8     |     102     |    1    |   null     |  null  |  2021-01-09 23:54:33 |
|    9     |     103     |    1    |     4      | 1, 5   |  2021-01-10 11:22:59 |
|    10    |     104     |    1    |   null     |  null  |  2021-01-11 18:34:49 |
|    10    |     104     |    1    |   2, 6     | 1, 4   |  2021-01-11 18:34:49 |
- Requires cleaning

Table 3: `runner_orders`
| order_id | runner_id |    pickup_time    | distance | duration |       cancellation      |
|:--------:|:--------:|:----------------:|:--------:|:--------:|:-----------------------:|
|    1     |     1    | 2021-01-01 18:15:34 |   20km   | 32 minutes |             |
|    2     |     1    | 2021-01-01 19:10:54 |   20km   | 27 minutes |             |
|    3     |     1    | 2021-01-03 00:12:37 |  13.4km  |  20 mins  |            NaN          |
|    4     |     2    | 2021-01-04 13:53:03 |   23.4   |    40    |            NaN          |
|    5     |     3    | 2021-01-08 21:10:57 |    10    |    15    |            NaN          |
|    6     |     3    |        NaN        |    NaN   |    NaN   | Restaurant Cancellation |
|    7     |     2    | 2020-01-08 21:30:45 |   25km   |  25mins  |            NaN          |
|    8     |     2    | 2020-01-10 00:15:02 |  23.4 km | 15 minute |            NaN          |
|    9     |     2    |        NaN        |    NaN   |    NaN   | Customer Cancellation   |
|    10    |     1    | 2020-01-11 18:50:20 |   10km   | 10minutes|            NaN          |
- Requires cleaning

Table 4:`pizza_names`
| pizza_id | pizza_name     |
|:--------:|:--------------|
| 1        | Meat Lovers    |
| 2        | Vegetarian     |

Table 5: `pizza_recipes`
| pizza_id |          toppings           |
|:-------:|:---------------------------:|
|    1    | 1, 2, 3, 4, 5, 6, 8, 10      |
|    2    | 4, 6, 7, 9, 11, 12           |
- each row represents a pizza with multiple toppings and each topping can be associated with multiple pizzas. 

Table 6: `pizza_toppings`
| topping_id | topping_name   |
|:----------:|:--------------:|
|     1      |     Bacon      |
|     2      |   BBQ Sauce    |
|     3      |      Beef      |
|     4      |     Cheese     |
|     5      |     Chicken    |
|     6      |    Mushrooms   |
|     7      |     Onions     |
|     8      |    Pepperoni   |
|     9      |     Peppers    |
|     10     |     Salami     |
|     11     |    Tomatoes    |
|     12     |  Tomato Sauce  |

---

## SQL Concepts

This case focuses on the following SQL concepts:
- Common table expressions
- Group by aggregates
- Table joins
- String transformations
- Dealing with null values

<p> 
  <a href="https://github.com/abigayl3/SQL_Challenges/blob/main/Case%20Study%20%232%20Pizza%20Runner/Case_Solutions_Part_A%26B.md"> Click here for my solutions to the case study questions</a>
</p>
