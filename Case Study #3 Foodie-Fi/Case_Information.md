# <p align="center"> Case Study #3 - Foodie-Fi
 </p>

<p align="center">  
  <img src="https://github.com/abigayl3/SQL_Challenges/blob/main/Case%20Study%20%233%20Foodie-Fi/Images/Foodie_fi_title.png" width="500" height="500" align="center">
</p>
<p align="center"> 
  <a href="https://8weeksqlchallenge.com/case-study-3/">Access The Full Challenge Here</a>
</p>

---
## Case Background
Foodie-Fi is a subscription based streaming platform all about food related content. Foodie-Fi offers monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive world-wide food videos. The creator, Danny, wants to ensure future investment and feature decisions are data driven. Thus, this case study focuses on using subscription style digital data to answer important business questions.

## Understanding the Datasets
<p align="center">  
<img  src="https://github.com/abigayl3/SQL_Challenges/blob/main/Case%20Study%20%233%20Foodie-Fi/Images/Foodie_fi_ERD.png" width="500" height="200" align="center">
</p>

The ERD shows 2 tables available for analysis: the data table `subscriptions` and the lookup table `plans`.

``plans``
| plan_id |  plan_name   |  price  |
|---------|:-----------:|--------:|
|      0       |    trial    |   0.00  |
|      1       | basic monthly |   9.90 |
|      2       |  pro monthly |  19.90 |
|      3       |  pro annual | 199.00 |
|      4       |    churn    |   null |

- All customers start with a free-trial period then automatically continue with the pro-monthly plan unless they cancel or downgrade/upgrade to another plan during the trial period.
- When customers cancel their plans, they have a churn plan record

``subscriptions``
| customer_id	| plan_id |	start_date |
|-------------|:-------:|-----------:|
| 1	|0	|2020-08-01|
|1	|1	|2020-08-08|
|2	|0	|2020-09-20|
|2	|3	|2020-09-27|
|11	|0	|2020-11-19|
|11	|4	|2020-11-26|
|13	|0	|2020-12-15|
|13	|1	|2020-12-22|
|13	|2	|2021-03-29|
|15	|0	|2020-03-17|
|15	|2	|2020-03-24|
|15	|4	|2020-04-29|
|16	|0	|2020-05-31|
|16	|1	|2020-06-07|
|16	|3	|2020-10-21|
|18	|0	|2020-07-06|
|18	|2	|2020-07-13|
|19	|0	|2020-06-22|
|19	|2	|2020-06-29|
|19	|3	|2020-08-29|

---

## SQL Concepts
