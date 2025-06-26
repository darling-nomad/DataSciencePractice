/*markdown
# SQL Practice Notebook
#### Table of Contents
**[Notes](#notes)** <br>
**[Interview Master →](#interview-master)** <br>
**[HackerRank →](#hackerrank)**
*/

/*markdown
##### The problem (template)
*/

-- The code

/*markdown
The takeaway
*/

/*markdown
### Notes
*/

/*markdown
##### CASE
*/

SELECT CASE
WHEN x THEN y
WHEN p then q
ELSE z
END AS case_name
FROM table

/*markdown
Case is used like an if then in SQL
It can bucket values into categories
It can replace values or clean data
It can also be used to take inputs like 0, 1 and return True/False, or "yes"/"no" or vice versa.
*/

/*markdown
##### Subqueries versus CTE versus Window Functions

*/

/*markdown
###### Subqueries are just what they sound like. A query inline within a query. We can use it to return aggregates or filter against aggregates. It can be used to update values as well.
*/

SELECT value, (
    SELECT MAX(value) FROM table
    )
FROM table;

SELECT value
FROM table
WHERE value = (SELECT MAX(value) FROM table)

/*markdown
###### CTE or Common Table Expressions are basically tables you generate from the data so that you can refer to them. They are defined at the front of the query and must always be names. A CTE can also be used multiple times throughout a query as if it were a table.
*/

WITH cte AS (
    SELECT value, AVG(value) AS avg_value, MAX(value) AS max_value
    FROM table
)
SELECT value, avg_value, max_value
FROM cte
WHERE avg_value > x

/*markdown
###### Window Functions are for when you need to perform calculations across multiple rows or sets of rows without collapsing the dataset (like you would with a grouped aggregate). It can include a typical aggregate potentially with a partition, it can index with (DENSE) RANK, ROW_NUMBER, or NTILE, or it can contain info from adjacent rows using LAG or LEAD. 
*/

SELECT SUM(value) OVER (ORDER BY second_value) AS running_total
FROM table;
-- This would return a cumulative SUM in order of a second value like date or service.

SELECT dimension, RANK() OVER (PARTITION BY other_dimension ORDER BY value ASC) AS rank_number
FROM table;
-- This would return the dimension and its rank broken out by a secondary dimension.
-- This could be used to index the delivery times to an address or user
-- or it could index the number of sales made by account or seller

SELECT dimension, value - LAG(value, 1) OVER (PARTITION BY other_dimension ORDER BY dimension DESC)
FROMX table;
-- Returns the difference in the value and the value that preceded it.
-- Returns null for the first value, but a default value can be specified.

/*markdown
### Interview Master
*/

/*markdown
##### Reorder Patterns for Amazon Fresh
*/

/*markdown
###### As a Data Analyst on the Amazon Fresh product team, you and your team are focused on enhancing the customer experience by streamlining the process for customers to reorder their favorite grocery items. Your goal is to identify the most frequently reordered product categories, understand customer preferences for these products, and calculate the average reorder frequency across categories. By analyzing these metrics, you aim to provide actionable insights that will inform strategies to improve customer satisfaction and retention.

Question 1 of 3

The product team wants to analyze the most frequently reordered product categories. Can you provide a list of the product category codes (using first 3 letters of product code) and their reorder counts for Q4 2024?


*/

SELECT SUBSTR(product_code, 1, 3) AS product_category_code,
  COUNT(order_id)
FROM dim_products p
JOIN fct_orders o
ON p.product_id = o.product_id
WHERE order_date BETWEEN "2024-10-01" AND "2024-12-31"
  AND reorder_flag = 1
 GROUP BY 1

/*markdown
###### To better understand customer preferences, the team needs to know the details of customers who reorder specific products. Can you retrieve the customer information along with their reordered product code(s) for Q4 2024?



*/

SELECT o.customer_id, customer_name, product_code, count(order_id)
FROM fct_orders o
JOIN dim_products p
ON p.product_id = o.product_id
JOIN dim_customers c
ON c.customer_id = o.customer_id
WHERE order_date BETWEEN "2024-10-01" AND "2024-12-31"
AND reorder_flag = 1
GROUP BY 1,2,3

/*markdown
###### When calculating the average reorder frequency, it's important to handle cases where reorder counts may be missing or zero. Can you compute the average reorder frequency across the product categories, ensuring that any missing or null values are appropriately managed for Q4 2024?



*/

WITH cte AS (
  SELECT category, COUNT(order_id) AS total_orders
  FROM fct_orders
  JOIN dim_products
  ON fct_orders.product_id = dim_products.product_id
  WHERE order_date BETWEEN "2024-10-01" AND "2024-12-31"
GROUP BY 1
), cte2 AS (
  SELECT category, COUNT(order_id) AS total_reorders
  FROM fct_orders
  JOIN dim_products
  ON fct_orders.product_id = dim_products.product_id
  WHERE order_date BETWEEN "2024-10-01" AND "2024-12-31"
    AND reorder_flag = 1
GROUP BY 1
)
SELECT cte.category, COALESCE(total_reorders / total_orders,0) AS avg_freq
FROM cte
LEFT JOIN cte2
  ON cte.category = cte2.category

/*markdown
The thing that stuck me was that I needed to add coalesce to the final query. I correctly used CTEs to filter and aggregate the queries, but in order to keep categories with no reorders from dropping off, I needed to use COALESCE to convert the null values to 0.
*/

/*markdown
##### Device Integration with Amazon Services

*/

/*markdown
###### As a Data Analyst on the Amazon Devices team, you are tasked with evaluating the usage patterns of Amazon services on devices like Echo, Fire TV, and Kindle. Your goal is to categorize device usage, assess overall engagement levels, and analyze the contribution of Prime Video and Amazon Music to total usage. This analysis will inform strategies to optimize service offerings and improve customer satisfaction.

Question 1 of 3

The team wants to identify the total usage duration of the services for each device type by extracting the primary device category from the device name for the period from July 1, 2024 to September 30, 2024. The primary device category is derived from the first word of the device name.


*/

SELECT SUBSTR(device_name, 1, (INSTR(device_name, " ") - 1)) AS device_type,
  SUM(usage_duration_minutes) AS usage_sum
FROM fct_device_usage u
  JOIN dim_device d
  ON u.device_id = d.device_id
WHERE usage_date BETWEEN "2024-07-01" AND "2024-09-30"
GROUP BY 1

/*markdown
###### The team also wants to label the usage of each device category into 'Low' or 'High' based on usage duration from July 1, 2024 to September 30, 2024. If the total usage time was less than 300 minutes, we'll category it as 'Low'. Otherwise, we'll categorize it as 'high'. Can you return a report with device ID, usage category and total usage time?
*/

SELECT d.device_id, CASE
   WHEN SUM(usage_duration_minutes) < 300 THEN "LOW"
   ELSE "HIGH" END AS usage_category,
  SUM(usage_duration_minutes) AS usage_sum
FROM fct_device_usage u
  JOIN dim_device d
  ON u.device_id = d.device_id
WHERE usage_date BETWEEN "2024-07-01" AND "2024-09-30"
GROUP BY 1;

/*markdown
###### The team is considering bundling the Prime Video and Amazon Music subscription. They want to understand what percentage of total usage time comes from Prime Video and Amazon Music services respectively. Please use data from July 1, 2024 to September 30, 2024.


*/

WITH cte AS (
  SELECT SUM(usage_duration_minutes) AS total_usage
  FROM fct_device_usage
  WHERE usage_date BETWEEN "2024-07-01" AND "2024-09-30"
), cte2 AS(
  SELECT s.service_name, SUM(usage_duration_minutes) AS usage_by_service
  FROM fct_device_usage u
  JOIN dim_service s
  ON u.service_id = s.service_id
  WHERE usage_date BETWEEN "2024-07-01" AND "2024-09-30"
    AND (service_name = "Amazon Music" OR service_name = "Prime Video")
GROUP BY 1
)
SELECT cte2.service_name, ROUND(usage_by_service / total_usage,2)*100 AS usage_percent
FROM cte2
JOIN cte
GROUP BY 1

/*markdown
This one was pretty complicated, as it required crafting substrings and searching strings in part one, then requiring two ctes to filter and aggregate the queries correctly. But first try on all three parts!
*/

/*markdown
##### Engagement with Facebook Events

*/

/*markdown
###### As a Data Scientist on the Facebook Events Discovery team, you are tasked with analyzing user interaction with event recommendations to enhance the relevance of these suggestions. Your goal is to identify which event categories receive the most user clicks, determine if users are engaging with events in their preferred categories, and understand user engagement patterns by analyzing click data. This analysis will help optimize recommendation algorithms to increase user satisfaction and event attendance.

Question 1 of 3


*/

/*markdown
###### How many times did users click on event recommendations for each event category in March 2024? Show the category name and the total clicks.


*/

SELECT category_name, COUNT(click_id)
FROM fct_event_clicks c
  JOIN dim_events d
  ON c.event_id = d.event_id
WHERE click_date LIKE "2024-03%"
GROUP BY 1
-- Nothing too fancy here, simple count, join, and filter

/*markdown
###### For event clicks in March 2024, identify whether each user clicked on an event in their preferred category. Return the user ID, event category, and a label indicating if it was a preferred category ('Yes' or 'No').


*/

SELECT u.user_id, category_name,
CASE WHEN e.category_name = u.preferred_category THEN "Yes"
ELSE "No"
END AS category_match
FROM fct_event_clicks c
JOIN dim_events e
ON c.event_id = e.event_id
JOIN dim_users u
ON u.user_id = c.user_id
WHERE c.click_date LIKE "2024-03%"
-- A little more complex as there are two joins, but ultimately still a simple CASE with a filter.

/*markdown
###### Generate a report that combines the user ID, their full name (first and last name), and the total clicks for events they interacted with in March 2024. Sort the report by user ID in ascending order.


*/

SELECT dim_users.user_id, CONCAT(first_name, " ", last_name), COUNT(click_id)
FROM dim_users
JOIN fct_event_clicks
ON dim_users.user_id = fct_event_clicks.user_id
WHERE fct_event_clicks.click_date LIKE "2024-03%"
GROUP BY 1
ORDER BY 1 ASC

/*markdown
This one felt pretty easy, I think because it mostly focused on my ability to join multiple tables correctly, something I'm very comfortable with.
*/

/*markdown
##### App Download Conversion Rates by Category

*/

/*markdown

###### You are on the Google Play store's App Marketplace team. You and your team want to understand how different app categories convert from browsing to actual downloads. This analysis is critical in informing future product placement and marketing strategies for app developers and users.
*/

Question 1 of 3

The marketplace team wants to identify high and low performing app categories. Provide the total downloads for the app categories for November 2024. If there were no downloads for that category, return the value as 0.

WITH cte AS (SELECT app_id, SUM(download_count) AS app_downloads
FROM fct_app_downloads
WHERE download_date BETWEEN "2024-11-01" AND "2024-11-30"
GROUP BY 1)
SELECT category, COALESCE(SUM(app_downloads),0) AS nov_downloads
FROM dim_app a
LEFT JOIN cte
ON a.app_id = cte.app_id
GROUP BY 1
ORDER BY 2 DESC;

-- I initially ran this as a straightforward LEFT JOIN, thinking that would catch all the category names.
-- But the date filter was eliminating categories that should have been included, so I used a CTE
-- to prefilter the values and joined to that instead, with success!

/*markdown
###### Our team's goal is download conversion rate -- defined as downloads per browse event. For each app category, calculate the download conversion rate in December, removing categories where browsing counts are be zero.
*/

WITH cte1 AS (
  SELECT app_id, SUM(browse_count) as total_browse_count
  FROM fct_app_browsing
  WHERE browse_date LIKE "2024-12%"
  GROUP BY 1
),
cte2 AS (
  SELECT app_id, SUM(download_count) as total_download_count
  FROM fct_app_downloads
  WHERE download_date LIKE "2024-12%"
  GROUP BY 1
)
SELECT category, SUM(total_download_count) / SUM(total_browse_count) AS cvr
FROM dim_app a
JOIN cte1
ON a.app_id = cte1.app_id
JOIN cte2
ON a.app_id = cte2.app_id
GROUP BY 1
HAVING SUM(total_browse_count) > 0;

-- I first thought that I would need two CTEs but I tried doing it first with no CTE and then with one CTE,
-- but filtering download and download date and browse and browse date couldn't happen in the same functions.
-- I also got stuck on where to filter out the aggregate of the browse count when it was 0

/*markdown
###### The team wants to compare conversion rates between free and premium apps across all categories. Combine the conversion data for both app types to present a unified view for Q4 2024.
*/

WITH cte1 AS (
  SELECT app_id, SUM(browse_count) as total_browse_count
  FROM fct_app_browsing
  WHERE browse_date BETWEEN "2024-10-01" AND "2024-12-31"
  GROUP BY 1
),
cte2 AS (
  SELECT app_id, SUM(download_count) as total_download_count
  FROM fct_app_downloads
  WHERE download_date BETWEEN "2024-10-01" AND "2024-12-31"
  GROUP BY 1
)
SELECT category, app_type, SUM(total_download_count) / SUM(total_browse_count) AS cvr
FROM dim_app a
JOIN cte1
ON a.app_id = cte1.app_id
JOIN cte2
ON a.app_id = cte2.app_id
GROUP BY category, app_type
HAVING SUM(total_browse_count) > 0

-- This was very easy, all I had to do was include app_type in both the select and group by sections
-- and update the date to include all of Q4

/*markdown
Takeaway: It's important to remember that it's unwise to apply filters on multiple aggregates at a time. It introduces the risk that your filter for one aggregate will falsify the other and vice versa. Multiple CTEs were necessary this time to ensure that was successful.
*/

/*markdown
### HackerRank
*/

/*markdown
### Data Lemur
*/

/*markdown
###### 3-Topping Pizzas

You’re a consultant for a major pizza chain that will be running a promotion where all 3-topping pizzas will be sold for a fixed price, and are trying to understand the costs involved.

Given a list of pizza toppings, consider all the possible 3-topping pizzas, and print out the total cost of those 3 toppings. Sort the results with the highest total cost on the top followed by pizza toppings in ascending order.

Break ties by listing the ingredients in alphabetical order, starting from the first ingredient, followed by the second and third.



*/

WITH cte1 AS (SELECT * FROM pizza_toppings),
cte2 AS (SELECT * FROM pizza_toppings)
SELECT CONCAT(cte1.topping_name, ',' ,cte2.topping_name, ',', p.topping_name), cte1.ingredient_cost + cte2.ingredient_cost + p.ingredient_cost AS total_cost
FROM cte1
CROSS JOIN cte2
CROSS JOIN pizza_toppings p
WHERE cte1.topping_name < cte2.topping_name AND cte2.topping_name < p.topping_name
ORDER BY 2 DESC, 1 ASC

/*markdown
This one was really interesting! I didn't struggle with duplicating the tables really, but figuring out how to remove the duplicate toppings options was tricky. I initially did topping1 != topping2 || topping3 and that made sure there were no repeated toppings in the same list, but it didn't account for reorderings of toppings. I looked at the hint and saw the solution and it was so simple it blew my mind. topping1 < topping2 < topping3
*/

/*markdown
### Jump To
**[Interview Master →](#interview-master)** <br>
**[HackerRank →](#hackerrank)**
*/