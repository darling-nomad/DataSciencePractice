/*markdown
# SQL Practice Notebook
#### Table of Contents
**[Notes](#notes)** 
**[Interview Master →](#interview-master)** 
**[HackerRank →](#hackerrank)**
*/

/*markdown
#### Problem Title (template)
*/

/*markdown
##### The background
*/

/*markdown
###### The question
*/

-- The code

/*markdown
The takeaway
*/

/*markdown
### Notes
*/

/*markdown
##### Indices
*/

/*markdown

*/

/*markdown
##### Correlated Subquery
*/

SELECT dimension_x, dimension_y, metric
FROM table t1
WHERE metric > (SELECT AVG(metric) FROM table t2 WHERE t1.dimension_x = t2.dimension_x) 

/*markdown
__[Correlated subqueries](https://www.sqltutorial.org/sql-correlated-subquery/)__ are when you make a subquery that depends on the outerquery for its input values. The subquery executes once for each row in the outer query. In the query above, each row will be compared to an average in the inner query. Any values that exceed the average will be included. The inner query's where statement is what determines what criterion will be compared. For example, if the inner query had "WHERE t1.use_date = t2.use_date, it would compare the value in the outer query to an average of values with the same date. "WHERE t1.publisher_tier = t2.publisher_tier" would filter for values that exceed the average for the same publisher tier.
*/

/*markdown
##### Unpivoting
*/

SELECT dimension, 'metric_name_x' AS metric, SUM(metric_x_count)
FROM table
UNION ALL
SELECT dimension, 'metric_name_y' AS metric, SUM(metric_y_count)
FROM table

/*markdown
Unpivoting involves making a two columns, one that contains the metric name, and another that contains the aggregate of that metric. By taking UNION ALL of that table and another, you get a single set of columns that contain the metric name and the aggregate of the metric instead of an individual column for each metric.
Pivoting is when you make multiple columns for each dimension or metric, so it makes sense that unpivoting is making a single column from multiple.
See [example](#your-product-manager-requests-a-report-that-shows-impressions-likes-comments-and-shares-for-each-content-type-between-april-8-and-21-2024-she-specifically-requests-that-engagement-metrics-are-unpivoted-into-a-single-metric-type-column)
*/

/*markdown
##### Unpivoting
*/

SELECT dimension, 'metric_name_x' AS metric, SUM(metric_x_count)
FROM table
UNION ALL
SELECT dimension, 'metric_name_y' AS metric, SUM(metric_y_count)
FROM table

/*markdown
Unpivoting involves making a two columns, one that contains the metric name, and another that contains the aggregate of that metric. By taking UNION ALL of that table and another, you get a single set of columns that contain the metric name and the aggregate of the metric instead of an individual column for each metric.
Pivoting is when you make multiple columns for each dimension or metric, so it makes sense that unpivoting is making a single column from multiple.
See [example](#your-product-manager-requests-a-report-that-shows-impressions-likes-comments-and-shares-for-each-content-type-between-april-8-and-21-2024-she-specifically-requests-that-engagement-metrics-are-unpivoted-into-a-single-metric-type-column)
*/

/*markdown
##### Extract single value using MAX(CASE)
*/

SELECT MAX(
    CASE
WHEN x THEN y
END) AS max_case_name
FROM table

/*markdown
CASE typically returns multiple values, so if you only want a single value, you need to use an aggregator to return only one.
See [example](#within-may-2024-for-each-seller-id-please-generate-a-weekly-summary-that-reports-the-total-number-of-sales-transactions-and-shows-the-fee-amount-from-the-most-recent-sale-in-that-week-this-analysis-will-let-us-correlate-fee-changes-with-weekly-seller-performance-trends)
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
Subqueries are just what they sound like. A query inline within a query. We can use it to return aggregates or filter against aggregates. It can be used to update values as well.
*/

SELECT value, (
    SELECT MAX(value) FROM table
    )
FROM table;

SELECT value
FROM table
WHERE value = (SELECT MAX(value) FROM table)

/*markdown
CTE or Common Table Expressions are basically tables you generate from the data so that you can refer to them. They are defined at the front of the query and must always be names. A CTE can also be used multiple times throughout a query as if it were a table.
*/

WITH cte AS (
    SELECT value, AVG(value) AS avg_value, MAX(value) AS max_value
    FROM table
)
SELECT value, avg_value, max_value
FROM cte
WHERE avg_value > x

/*markdown
Window Functions are for when you need to perform calculations across multiple rows or sets of rows without collapsing the dataset (like you would with a grouped aggregate). It can include a typical aggregate potentially with a partition, it can index with (DENSE) RANK, ROW_NUMBER, or NTILE, or it can contain info from adjacent rows using LAG or LEAD. 
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
#### Advertiser Campaign Performance by Audience Segments
*/

/*markdown
##### You are a Data Analyst working with the X for Advertisers team to evaluate the effectiveness of advertising campaigns across various audience segments. Your team aims to understand how different audience groups are engaging with the campaigns to optimize targeting strategies. By analyzing engagement metrics, you will identify trends and growth rates to enhance campaign performance.
*/

/*markdown
###### What is the monthly total engagement count for each audience segment in April 2024 and May 2024? Hint: there is some messy data in the audience segment column, so you might want to clean that up first.
*/

SELECT UPPER(audience_segment) AS audience_segment,
STRFTIME('%m', engagement_date) AS month_num,
SUM(engagement_count) AS total_engagement
FROM fct_campaign_engagement
WHERE engagement_date BETWEEN '2024-04-01' AND '2024-05-31'
GROUP BY 1, 2

/*markdown
###### What is the monthly engagement growth rates from April 2024 to May 2024? This calculation will help the X for Advertisers team understand basic engagement performance trends across audience groups for campaign optimization.
*/

WITH cte AS (
  SELECT UPPER(audience_segment) AS audience_segment,
STRFTIME('%m', engagement_date) AS month_num,
SUM(engagement_count) AS total_engagement
FROM fct_campaign_engagement
WHERE engagement_date BETWEEN '2024-04-01' AND '2024-05-31'
GROUP BY 1, 2
  )
SELECT *,
  ROUND(100.*(total_engagement - LAG(total_engagement, 1) OVER
  (PARTITION BY audience_segment 
  ORDER BY month_num ASC)) / LAG(total_engagement, 1) OVER
  (PARTITION BY audience_segment 
  ORDER BY month_num ASC),2)
  AS percent_engagement_change
  FROM cte

/*markdown
###### Which audience segments had the highest engagement growth rate from April 2024 to May 2024, and which had the lowest? Don't forget to clean up the inconsistent capitalization in the audience segment column. Identifying these trends will help the X for Advertisers team optimize targeting strategies by focusing on the most responsive audience segments.
*/

WITH cte AS (
  SELECT UPPER(audience_segment) AS audience_segment,
STRFTIME('%m', engagement_date) AS month_num,
SUM(engagement_count) AS total_engagement
FROM fct_campaign_engagement
WHERE engagement_date BETWEEN '2024-04-01' AND '2024-05-31'
GROUP BY 1, 2
  ), cte2 AS (
SELECT *,
  ROUND(100.*(total_engagement - LAG(total_engagement, 1) OVER
  (PARTITION BY audience_segment 
  ORDER BY month_num ASC)) / LAG(total_engagement, 1) OVER
  (PARTITION BY audience_segment 
  ORDER BY month_num ASC),2)
  AS percent_engagement_change
  FROM cte
   ), cte3 AS (
SELECT *, RANK() OVER 
   ( 
   ORDER BY percent_engagement_change) AS rank_num
   FROM cte2
WHERE percent_engagement_change IS NOT NULL
   )
SELECT audience_segment, percent_engagement_change FROM cte3 WHERE rank_num = 1
   OR rank_num = (SELECT MAX(rank_num) FROM cte3)

/*markdown
This one challenged me, cleaning the strings, using lots of window functions and then ranking on those window functions, it was all really interesting.
*/

/*markdown
#### Feed Content Quality: Engagement and Insights Impact
*/

/*markdown
##### As a Product Analyst on the LinkedIn Feed team, you are tasked with analyzing how different content types impact user engagement on the platform. Your team is focused on understanding which types of content consistently drive higher engagement scores. The ultimate goal is to leverage these insights to enhance content recommendation strategies and improve user experience on the feed.
*/

/*markdown
###### Identify which content formats performed best in July 2024 by reporting their average engagement scores, but only list the formats that achieved an average score of 50 or higher.
*/

SELECT content_type, AVG(engagement_score) AS avg_engagement_score
FROM fct_user_engagement
JOIN dim_content
  ON fct_user_engagement.content_id = dim_content.content_id
WHERE engagement_date LIKE '2024-07%'
GROUP BY 1
HAVING AVG(engagement_score) >= 50
  ORDER BY 2 DESC

/*markdown
###### For the first week of August 2024, identify the content type of the content that had the highest engagement score. For that content type, calculate the average engagement score for the entire month of August. If there is a tie for highest engagement score, select the content type with the earliest publish date.
*/

SELECT content_type, AVG(engagement_score)
FROM fct_user_engagement
JOIN dim_content
  ON fct_user_engagement.content_id = dim_content.content_id
WHERE engagement_date LIKE '2024-08%' AND 
 content_type IN (SELECT content_type
FROM fct_user_engagement
JOIN dim_content
  ON fct_user_engagement.content_id = dim_content.content_id
WHERE engagement_date BETWEEN '2024-08-01' AND '2024-08-07'
ORDER BY engagement_score DESC, publish_date ASC
LIMIT 1)

/*markdown
###### During Q3 2024, for each content type, calculate their highest engagement score each week. What was the average of those weekly highs over the quarter? This will help us identify content types that consistently generate peak engagement.
*/

WITH weekly_maxes AS ( 
  SELECT content_type,
   STRFTIME('%W', engagement_date) AS weeknum,
   MAX(engagement_score) AS max_engagement
FROM fct_user_engagement
JOIN dim_content
  ON fct_user_engagement.content_id = dim_content.content_id
WHERE engagement_date BETWEEN '2024-07-01' AND '2024-09-30'
GROUP BY 1,2
ORDER BY 1, 2
  )
SELECT *,
  ROUND(
  AVG(max_engagement) OVER (PARTITION BY content_type),2) AS avg_weekly_max
  FROM weekly_maxes

/*markdown
The takeaway: Part two was a little tricky with the subquery to get the content type to run the main query on, but I was able to puzzle through it well enough. I also got part three on my first try.
*/

/*markdown
#### Marketplace Payout Fees and Compliance Variations
*/

/*markdown
##### As a Data Analyst on the Stripe Connect team, you are tasked with evaluating payment performance across various marketplace segments. Your team is focused on understanding how payout fees and compliance costs differ between platform types to identify opportunities for optimizing fee structures and compliance strategies. Your goal is to provide insights that will help streamline costs and improve operational efficiency across segments.
*/

/*markdown
###### What is the average payout fee per transaction for each marketplace segment during April 2024? This result will provide an initial benchmark for fee structures by segment.
*/

SELECT marketplace_segment, AVG(payout_fee) AS avg_payout
FROM fct_transactions
WHERE transaction_date LIKE '2024-04%'
GROUP BY 1

/*markdown
###### For each marketplace segment, what is the total compliance costs in April 2024? This metric will help evaluate the efficiency of current compliance strategies.
*/

SELECT marketplace_segment, SUM(compliance_cost) AS total_compliance_cost
FROM fct_transactions
WHERE transaction_date LIKE '2024-04%'
GROUP BY 1

/*markdown
###### We know that one of the marketplace segments exhibited both the lowest total compliance overhead and the lowest average payout fee structures in April 2024. Can you identify which one it is?
*/

 WITH cte AS (
   SELECT marketplace_segment,
     AVG(payout_fee) AS avg_payout,
     SUM(compliance_cost) AS total_compliance_cost,
   RANK() OVER (ORDER BY AVG(payout_fee) ASC) AS payout_rank,
   RANK() OVER (ORDER BY SUM(compliance_cost) ASC) AS cost_rank
FROM fct_transactions
WHERE transaction_date LIKE '2024-04%'
GROUP BY 1
 )
SELECT * FROM cte
WHERE payout_rank = 1 AND cost_rank = 1

/*markdown
This one was really easy. I nailed every prompt on the first try!
*/

/*markdown
#### Capital Financing: Small Business Revenue Patterns
*/

/*markdown
##### You are a Data Analyst on the Stripe Capital team, focused on assessing lending patterns for small businesses. Your team is investigating how transaction volumes and growth trends can inform financing eligibility decisions. The objective is to identify businesses with stable and growing revenue patterns to streamline lending processes.
*/

/*markdown
###### For each business, what is the total transaction amount in January 2024, and how does its ranking compare to other businesses? This analysis will help establish baseline revenue activity levels for financing eligibility.
*/

SELECT business_name, SUM(transaction_amount) AS total_transactions,
  RANK() OVER
  (ORDER BY SUM(transaction_amount) DESC) AS ranknum
FROM fct_transactions
  JOIN dim_businesses
  ON fct_transactions.business_id = dim_businesses.business_id
WHERE transaction_date LIKE '2024-01%'
GROUP BY 1

/*markdown
###### For each business, calculate the percentage change in total transaction amount from January 2024 to February 2024. This metric will assist in understanding recent revenue growth trends.
*/

/* 
percent change is (a - b)/a
*/
WITH monthly_transactions AS (
SELECT business_name, STRFTIME('%m',transaction_date) AS month_num,
  SUM(transaction_amount) AS total_transactions
FROM fct_transactions
  JOIN dim_businesses
  ON fct_transactions.business_id = dim_businesses.business_id
  WHERE transaction_date BETWEEN '2024-01-01' AND '2024-02-28'
GROUP BY 1, 2
)
SELECT business_name, month_num, total_transactions,
  100.0*(total_transactions -
  LAG(total_transactions, 1) OVER
  (PARTITION BY business_name ORDER BY month_num ASC))
  / LAG(total_transactions, 1) OVER
  (PARTITION BY business_name ORDER BY month_num ASC) AS percent_transaction_change
  FROM monthly_transactions

/*markdown
###### For each business, compute the month-over-month growth in total transaction amounts from January 2024 through March 2024. Rank each business based on this average growth (from highest to lowest), and return the rank number along with the business name and average growth.
*/

WITH monthly_transactions AS (
SELECT business_name, STRFTIME('%m',transaction_date) AS month_num,
  SUM(transaction_amount) AS total_transactions
FROM fct_transactions
  JOIN dim_businesses
  ON fct_transactions.business_id = dim_businesses.business_id
  WHERE transaction_date BETWEEN '2024-01-01' AND '2024-03-30'
GROUP BY 1, 2
), monthly_changes AS (
SELECT business_name, month_num, total_transactions,
  100.0*(total_transactions -
  LAG(total_transactions, 1) OVER
  (PARTITION BY business_name ORDER BY month_num ASC))
  / LAG(total_transactions, 1) OVER
  (PARTITION BY business_name ORDER BY month_num ASC) AS percent_transaction_change
  FROM monthly_transactions
  )
SELECT business_name, AVG(percent_transaction_change) AS percent_change_avg,
  RANK() OVER (
  ORDER BY AVG(percent_transaction_change) DESC) AS change_rank
  FROM monthly_changes
GROUP BY business_name
ORDER BY change_rank


/*markdown
Part three was really tricky. Essentially, I had to take an aggregate, find the change over time for that aggregate, then average and rank the change over time. Very complex!
*/

/*markdown
#### Ecommerce Shipping Performance for Customer Satisfaction
*/

/*markdown
##### You are a Data Analyst for Walmart.com's Shipping Experience team, tasked with assessing the reliability of shipping across different product categories. Your team is focused on identifying variations in shipping performance to find opportunities for improvement. The goal is to determine which product categories have the most reliable shipping and to rank them accordingly.
*/

/*markdown
###### What is the total count of orders with reliable shipping (i.e., delivered on or before the expected delivery date) for each product category in December 2024?
*/

SELECT category_name, COUNT(*)
  FROM fct_orders
  JOIN dim_product_categories
  ON fct_orders.product_category_id = dim_product_categories.product_category_id
WHERE order_date LIKE '2024-12%'
  AND actual_delivery_date <= expected_delivery_date
GROUP BY 1

/*markdown
###### Calculate the percentage of orders with unreliable shipping for each product category in December 2024. We define unreliable shipping as orders that were delivered after the expected delivery date, or orders that don’t currently have an actual delivery date.
*/

SELECT category_name, 100.0*SUM(CASE
   WHEN actual_delivery_date > expected_delivery_date
   THEN 1
   WHEN actual_delivery_date IS NULL THEN 1
   ELSE 0 END)/ COUNT(*) AS percent_unreliable
  FROM fct_orders
  JOIN dim_product_categories
  ON fct_orders.product_category_id = dim_product_categories.product_category_id
WHERE order_date LIKE '2024-12%'
GROUP BY 1

/*markdown
###### Rank product categories into four performance quartiles based on the percentage of reliable shipping in December 2024. Identify which quartile each product category falls into. Recall that reliable shipping is defined as orders delivered on or before the expected delivery date.
*/

WITH percent_ranked AS (
  SELECT category_name, 100.0*SUM(CASE
   WHEN actual_delivery_date <= expected_delivery_date
   THEN 1
   ELSE 0 END)/ COUNT(*) AS percent_reliable
  FROM fct_orders
  JOIN dim_product_categories
  ON fct_orders.product_category_id = dim_product_categories.product_category_id
WHERE order_date LIKE '2024-12%'
GROUP BY 1
  )
SELECT category_name, NTILE(4) OVER (ORDER BY percent_reliable ASC) AS quartile
  FROM percent_ranked

/*markdown
This problem came with interesting opportunities to use case and ntile to classify and assign values to metrics. 
*/

/*markdown
#### Eyewear Selection and Pricing in Vision Center
*/

/*markdown
##### You are a Data Analyst for the Walmart Vision Center team focused on understanding customer preferences and product performance in eyewear. Your team is interested in analyzing how different styles and price points influence customer satisfaction and sales volume. By leveraging data, you aim to identify the most popular styles, assess customer satisfaction for top-selling items, and determine the best-performing product combinations to inform strategic decisions on inventory and pricing.
*/

/*markdown
###### Using sales data from January 2024, what are the top 3 eyewear styles by total units sold and what is the total number of units sold for each style? This query helps identify the most popular styles among customers.
*/

SELECT style, SUM(quantity_sold) AS total_sold
  FROM fct_sales
  JOIN dim_products
  ON fct_sales.product_id = dim_products.product_id
  WHERE sale_date LIKE '2024-01%'
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 3

/*markdown
###### For each eyewear style sold in January 2024, what is the customer rating for the sale event that achieved the highest number of units sold? If there is a tie for highest units sold, return the event with the highest customer satisfaction rating. This query helps us understand if our most active buyers are happy with their purchase.
*/

WITH ranked_style AS (
  SELECT style, sale_id, customer_satisfaction, quantity_sold,
  RANK() OVER (PARTITION BY style ORDER BY quantity_sold DESC, customer_satisfaction DESC) AS sale_rank
  FROM fct_sales
  JOIN dim_products
  ON fct_sales.product_id = dim_products.product_id
  WHERE sale_date LIKE '2024-01%'
  )
SELECT * FROM ranked_style WHERE sale_rank = 1

/*markdown
###### For each unique combination of eyewear style and price point in January 2024, calculate the product performance score. Product performance score is defined as the total units sold multiplied by the average customer satisfaction score. Which combination has the highest product performance score? <br> Note: to derive the price point for each sale, you can divide the sale_amount by the quantity_sold. This query will inform strategic decisions by identifying the mix of style and price point that best drives both sales and customer satisfaction.



*/

SELECT style, sale_amount/quantity_sold AS price_point,
   ROUND(SUM(quantity_sold) * AVG(customer_satisfaction),2) AS product_performance
FROM fct_sales
  JOIN dim_products
  ON fct_sales.product_id = dim_products.product_id
   WHERE sale_date LIKE '2024-01%'
GROUP BY 1, 2
ORDER BY 3 DESC

/*markdown
Part two was tricky until I realized that I needed to use rank instead of trying to break out traditionally. Straightforward otherwise.
*/

/*markdown
#### Stays Host Communication Response Time Impact
*/

/*markdown
##### You are a Product Analyst on the Airbnb Stays team focusing on host communication patterns. Your team is exploring how host response times impact guest booking behaviors and overall satisfaction. The aim is to derive insights that can enhance host communication efficiency and improve booking conversion rates.
*/

/*markdown
###### What is the average response time for hosts during April 2024, and how does it vary across different property types?
*/

WITH cte AS (
SELECT host_id, property_type, AVG(response_time_minutes) AS host_response_avg
FROM fct_host_communications
JOIN dim_properties
ON fct_host_communications. property_id = dim_properties.property_id
  WHERE communication_date LIKE '2024-04%'
GROUP BY 1
  )
SELECT property_type,
  host_id, 
  host_response_avg, 
  AVG(host_response_avg) OVER (PARTITION BY 
  property_type) AS host_response_property_type_avg
  FROM cte GROUP BY property_type, host_id

/*markdown
###### Identify the top 5 hosts with the fastest average response times in April 2024. How does their response time compare to the overall average response time for that month?
*/

SELECT host_id, AVG(response_time_minutes), AVG(response_time_minutes) OVER ()
FROM fct_host_communications
JOIN dim_properties
ON fct_host_communications. property_id = dim_properties.property_id
  WHERE communication_date LIKE '2024-04%'
  GROUP BY 1
  ORDER BY 2 ASC
LIMIT 5

/*markdown
###### For the second quarter of 2024, calculate the average host response times and booking conversion rates for each property. This will help us understand if a quicker respsonse time leads to a higher booking conversion rate.
*/

SELECT fct_bookings.property_id, AVG(response_time_minutes), (1.0*SUM(CASE WHEN booking_status = 'confirmed' THEN 1 END)/COUNT(*))
AS conversion_rate
FROM fct_host_communications
  JOIN fct_bookings
  ON fct_bookings.property_id = fct_host_communications.property_id
WHERE communication_date BETWEEN '2024-04-01' AND '2024-06-30'
  AND booking_date BETWEEN '2024-04-01' AND '2024-06-30'
GROUP BY 1

/*markdown
This one provided good practice showing both aggregate values broken out and across different rows 
*/

/*markdown
#### Stays Pricing Transparency and Cancellation Impact
*/

/*markdown
##### You are a Data Scientist on the Airbnb Stays team, focusing on analyzing guest booking behaviors. Your team is investigating how pricing transparency and cancellation policies influence booking completion rates and daily booking volume. The goal is to provide insights into how these factors impact booking conversions and inform strategies to optimize guest satisfaction and booking success.
*/

/*markdown
###### What is the average booking completion rate for properties with 'low' and 'high' pricing transparency levels during April 2024? Use a 7-day rolling window to capture short-term trends. This analysis will help us understand the impact of pricing transparency on booking conversions.
*/

WITH aggregator AS (
  SELECT pricing_transparency_level, booking_date, completion_status, 
  SUM(CASE WHEN completion_status = 'completed'  THEN 1 ELSE 0 END) / COUNT(*) AS completion_rate,
  COUNT(*) AS attempt_count
FROM fct_bookings
WHERE booking_date BETWEEN '2024-04-01' AND '2024-04-30'
  AND pricing_transparency_level IN ('low','high')
GROUP BY 1, 2
)
SELECT pricing_transparency_level, booking_date,
  AVG(completion_rate) OVER 
  (PARTITION BY pricing_transparency_level ORDER BY booking_date ASC
  ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS avg_completion
  FROM aggregator

/*markdown
###### What are the day-over-day changes number of bookings for properties with varying cancellation policies in April 2024? Compare each day with the previous day to reveal trends over time. This analysis will help us assess how cancellation policies influence booking volume on a daily basis.
*/

SELECT cancellation_policy, booking_date, COUNT(*) AS booking_attempts,
  COUNT(*) - LAG(COUNT(*),1) OVER
  (PARTITION BY cancellation_policy ORDER BY booking_date ASC) AS daily_booking_change
  FROM fct_bookings
  WHERE booking_date BETWEEN '2024-04-01' AND '2024-04-30'
GROUP BY 1,2

/*markdown
###### What is the percentage difference in booking completion rates between properties with high pricing transparency and those with low transparency in April 2024, when also accounting for differing cancellation policies? Compute the booking completion rates separately for high and low transparency levels within each cancellation policy, then calculate the percentage difference between them to compare the results.



*/

WITH completion_rate_table AS (
  SELECT pricing_transparency_level, cancellation_policy, 
  SUM(1.0*CASE WHEN completion_status = 'completed' THEN 1 ELSE 0 END) / COUNT(*) AS completion_rate
FROM fct_bookings
WHERE booking_date BETWEEN '2024-04-01' AND '2024-04-30' 
  AND pricing_transparency_level IN ('low','high')
GROUP BY 1,2
)
SELECT pricing_transparency_level, cancellation_policy, completion_rate, 
  ((completion_rate - LEAD(completion_rate, 1) OVER
  (PARTITION BY cancellation_policy ORDER BY pricing_transparency_level ASC)) / completion_rate
  )*100.0 AS percent_change
  FROM completion_rate_table
GROUP BY 1,2

/*markdown
In part one, I got the SUM(CASE) built out neatly, but that only got the total completions. If there was more than one attempt per day, I would have returned an inflated value. By dividing by the count, that is adjusted for.
Part two wasn't particularly tricky, but part three was!
This one required a lot of work, combining a complicated SUM(CASE) and a LAG function. But I won!
*/

/*markdown
#### Teams Chat Productivity and Collaboration Insights
*/

/*markdown
##### You are a Product Analyst on the Microsoft Teams collaboration platform. Your team is focused on enhancing user engagement with chat features to streamline communication and reduce the need for switching between applications. By analyzing user interaction data, you aim to identify key usage patterns and prioritize feature improvements that will drive user satisfaction and efficiency.
*/

/*markdown
###### For October 2024, what is the average number of chat messages sent per user in Microsoft Teams? This baseline metric will help us understand overall user engagement.
*/

WITH aggregator AS (
  SELECT user_id, COUNT(*) as message_count
  FROM fct_chat_interactions
  WHERE interaction_date BETWEEN '2024-10-01' AND '2024-10-31'
  GROUP BY 1
  )
SELECT AVG(message_count) as avg_chats_per_user FROM aggregator

/*markdown
###### In October 2024, which are the top five chat features ranked by the number of unique users interacting with them? Identifying these features will help prioritize enhancements to reduce context-switching.
*/

SELECT feature_used, COUNT(DISTINCT user_id)
  FROM fct_chat_interactions
  WHERE interaction_date BETWEEN '2024-10-01' AND '2024-10-31'
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 5

/*markdown
###### For October 2024, what percentage of highly engaged users (those sending more than 50 messages) used the 'reply' feature at least once? This metric directly informs recommendations for feature enhancements that boost engagement and minimize context-switching.
*/

WITH counts AS (
   SELECT user_id, COUNT(message_id) as message_count, MAX(CASE
   WHEN feature_used = 'reply' THEN 1 END) AS replies
  FROM fct_chat_interactions
  WHERE interaction_date BETWEEN '2024-10-01' AND '2024-10-31'
  GROUP BY 1
  HAVING COUNT(message_id) > 50
   )
SELECT ROUND(1.0*COUNT(replies) / COUNT(user_id),2) AS percent_engaged_repliers
FROM counts

/*markdown
I had to collapse the CASE using MAX like I've done before. This is because without MAX, the CASE would only return the value of the last row, meaning this would only correctly count replies if the reply was the last interaction recorded. I tried specifically to avoid having to do multiple CTEs, so I'm glad that was successful.
*/

/*markdown
#### Mobile App User Session Continuation Patterns
*/

/*markdown
##### As a Data Analyst on the Netflix Mobile Experience team, you are investigating how users resume watching shows on mobile devices to enhance the seamless viewing experience. Your goal is to analyze user engagement through resume events, understand the distribution of these events per user, and identify the most popular shows for resumption on different mobile platforms. This analysis will help product managers optimize the app's resume functionality and reduce friction in content consumption.
*/

/*markdown
###### For the week from October 1st to October 7th, 2024, how many total resume events occurred on mobile devices? This analysis will help the Netflix Mobile Experience team evaluate overall user engagement during content resumption.
*/

SELECT COUNT(*) as mobile_resumption_count
  FROM fct_user_resumptions
WHERE resumption_timestamp BETWEEN '2024-10-01 00:00:00' AND '2024-10-07 23:59:59'
AND device_type IN ('iOS', 'Android')

/*markdown
###### For October 2024, we want to analyze the distribution of resume events per user. Calculate the median, 90th percentile, and maximum number of resume events across users who had at least 1 resume event.
*/

WITH aggregator AS (
  SELECT user_id, count(user_id) AS user_count,
  PERCENT_RANK() OVER (ORDER BY COUNT(user_id)) AS rank_percent
  FROM fct_user_resumptions
  WHERE resumption_timestamp LIKE '2024-10%'
  GROUP BY 1
)
SELECT max(user_count),
  (SELECT user_count FROM aggregator WHERE rank_percent >= .5 LIMIT 1) AS median,
  (SELECT user_count FROM aggregator WHERE rank_percent >= .9 LIMIT 1) AS ninetieth_percentile
FROM aggregator

/*markdown
###### During the fourth quarter of 2024, which show titles generated the highest number of resume events on each device type?
*/

WITH resumption_count AS (
  SELECT show_title, device_type, COUNT(*) AS counter,
  ROW_NUMBER() OVER (PARTITION BY device_type ORDER BY COUNT(*) DESC) AS rank_num
  FROM  fct_user_resumptions
  WHERE resumption_timestamp BETWEEN '2024-10-01' AND '2024-12-31'
GROUP BY 1,2
  )
SELECT show_title, device_type, counter FROM resumption_count WHERE rank_num = 1

/*markdown
The second problem had big new learnings for me, first in the usage of PERCENT_RANK and second in the use of subqueries with a LIMIT to find the specific values within the percent rank function.
*/

/*markdown
#### WhatsApp Call and Group Chat Interface Usage
*/

/*markdown
##### You are a Data Scientist on the WhatsApp consumer experience team focusing on enhancing user interaction with call and group chat features. Your team aims to understand user engagement patterns with family-focused group chats, average call durations, and group chat participation levels. The end goal is to simplify the user interface and interaction flows based on these insights.
*/

/*markdown
###### How many distinct users have participated in group chats with names containing the word ''family'', where the chat was created in April 2024? This analysis will inform product managers about user engagement trends with family-focused chat groups.
*/

SELECT COUNT(DISTINCT g.user_id) AS distinct_user_id_count
FROM fct_group_chats g
  LEFT JOIN fct_user_calls u
  ON u.user_id = g.user_id
  WHERE chat_creation_date LIKE '2024-04%' AND
UPPER(chat_name) LIKE '%FAMILY%'

/*markdown
###### To better understand user call behavior, we want to analyze the total call duration per user in May 2024. What is the average total call duration across all users?
*/

WITH aggregator AS (
  SELECT user_id, SUM(call_duration) AS call_duration_sum
FROM fct_user_calls
WHERE call_date LIKE '2024-05%'
GROUP BY 1
  )
SELECT user_id, call_duration_sum,
  AVG(call_duration_sum) OVER () AS avg_call_duration_per_user
FROM aggregator
GROUP BY 1

/*markdown
###### What is the maximum number of group chats any user has participated in during the second quarter of 2024 and how does this compare to the average participation rate? This insight will guide decisions on simplifying the chat interface for both heavy and average users.
*/

WITH call_count AS (
  SELECT user_id, COUNT(user_id) AS user_count
  FROM fct_group_chats
  WHERE chat_creation_date BETWEEN '2024-04-01' AND '2024-06-30'
  GROUP BY 1
)
  SELECT MAX(user_count), AVG(user_count)
  FROM call_count

/*markdown
These questions targeted my ability to perform joins, aggregates of aggregates, and the use of wildcard string functions. Window fnunctions played a role as well.
*/

/*markdown
#### iPhone Camera Performance Across User Segments
*/

/*markdown
##### As a Product Analyst on the iPhone Camera team, you are tasked with evaluating camera quality metrics across different user groups. Your team aims to understand variations in photo and video capture performance to identify opportunities for hardware or software improvements. The end goal is to prioritize future camera development efforts based on data-driven insights into user group performance trends.
*/

/*markdown
###### For the month of July 2024, how do average photo capture quality scores vary across different user groups? This analysis will help us identify segments where camera performance improvements could be prioritized.
*/

SELECT user_group_name, AVG(photo_quality_score)
  FROM fct_capture_quality c
  JOIN dim_user_group g
  ON c.user_group_id = g.user_group_id
WHERE capture_date LIKE '2024-07%'
GROUP BY 1

/*markdown
###### Between August 1st and August 7th, 2024, how do photo capture quality scores change for each iPhone user group? Use a 3-day average rolling window for this analysis.


*/

SELECT  user_group_name, capture_date,
  AVG(photo_quality_score)
  OVER (PARTITION BY user_group_name ORDER BY capture_date ASC
  ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
  FROM fct_capture_quality c
  JOIN dim_user_group g
  ON c.user_group_id = g.user_group_id
WHERE capture_date BETWEEN '2024-08-01' AND '2024-08-07'

/*markdown
###### For Q3 2024 (July 1st to September 30th), how do video capture quality scores trend for each iPhone user group when comparing each capture to the subsequent one? This insight will support our approach to optimize video performance through targeted hardware or software improvements.


*/

SELECT user_group_name, video_quality_score, capture_date,
   video_quality_score - LEAD(video_quality_score, 1)
   OVER (PARTITION BY user_group_name ORDER BY capture_date ASC)
  FROM fct_capture_quality c
  JOIN dim_user_group g
  ON c.user_group_id = g.user_group_id
   WHERE capture_date BETWEEN '2024-07-01' AND '2024-09-30'

/*markdown
This was some good practice using window functions, one with a frame spec and another using LEAD.
*/

/*markdown
#### Google Play Developer Monetization and Distribution Performance
*/

/*markdown
##### You are a Data Analyst on the Google Play Developer Ecosystem team. Your team is focused on understanding how different app categories and monetization models influence developer revenue and app distribution. The goal is to provide strategic insights to optimize developer monetization strategies and enhance platform engagement.
*/

/*markdown
###### For the month of April 2024, which app categories generated the highest total revenue (top 10 only)? This insight will be used to refine monetization strategies for developers.
*/

SELECT category_name, SUM(revenue_amount) AS revenue_sum
  FROM fct_app_revenue r
  JOIN dim_app_category c
  ON r.category_id = c.category_id
WHERE revenue_date LIKE '2024-04%'
  GROUP BY 1
  ORDER BY 2 DESC
LIMIT 10

/*markdown
###### During the second quarter of 2024, how does the weekly revenue ranking of each app category change? The team will use this analysis to identify performance trends and adjust engagement efforts.
*/

WITH weekly_rev AS (
  SELECT category_name, STRFTIME('%W',revenue_date) AS week,
  SUM(revenue_amount) AS weekly_rev_sum
FROM fct_app_revenue r
  JOIN dim_app_category c
  ON r.category_id = c.category_id
WHERE revenue_date BETWEEN '2024-04-01' AND '2024-06-30'
GROUP BY 1, 2
)
SELECT *,
  RANK() OVER
  (PARTITION BY week ORDER BY weekly_rev_sum DESC) AS weekly_rank
FROM weekly_rev

/*markdown
###### For apps using a subscription monetization model, can you give us the running total revenue by app for every day in April 2024? We are investigating a complaint from app developers about a slowdown in revenue in that month.
*/

SELECT r.app_id, revenue_date, SUM(revenue_amount) OVER (PARTITION BY r.app_id ORDER BY revenue_date ASC)
FROM fct_app_revenue r
  JOIN dim_monetization_model m
ON r.app_id = m.app_id  
WHERE revenue_date LIKE '2024-04%' AND monetization_type = 'subscription'

/*markdown
Lots of good practice using window functions in these questions
*/

/*markdown
#### Google Ads Campaign Performance Optimization
*/

/*markdown
##### You are a Data Analyst on the Google Ads Performance team working to optimize ad campaign strategies. The goal is to assess the diversity of ad formats, identify high-reach campaigns, and evaluate the return on investment across different campaign segments. Your team will use these insights to make strategic budget allocations and targeting adjustments for future campaigns.
*/

/*markdown
###### For each ad campaign segment, what are the unique ad formats used during July 2024? This will help us understand the diversity in our ad formats.
*/

SELECT DISTINCT ad_format, segment
FROM fct_ad_performance p 
JOIN dim_campaign c
ON p.campaign_id = c.campaign_id
WHERE campaign_date LIKE '2024-07%'
GROUP BY 2

/*markdown
###### How many unique campaigns had at least one rolling 7-day period in August 2024 where their total impressions exceeded 1,000? We want to identify campaigns that had a high reach in at least one 7-day window during this month.


*/

WITH rolling AS (
   SELECT campaign_id, campaign_date, SUM(impressions) OVER 
   (PARTITION BY campaign_id
   ORDER BY campaign_date ROWS BETWEEN 7 PRECEDING AND CURRENT ROW) AS rolling_sum
FROM fct_ad_performance
)
SELECT COUNT(DISTINCT campaign_id) FROM rolling
WHERE rolling_sum > 1000 AND campaign_date LIKE '2024-08%'

/*markdown
###### What is the total ROI for each campaign segment in Q3 2024? And, how does it compare to the average ROI of all campaigns (return labels 'higher than average' or 'lower than average')? We will use this to identify which segments are outperforming the average.
*/

WITH roi_table AS (
SELECT segment, ((SUM(revenue) - SUM(cost)) / SUM(cost)) AS roi
FROM fct_ad_performance
JOIN dim_campaign
ON fct_ad_performance.campaign_id = dim_campaign.campaign_id
WHERE campaign_date BETWEEN '2024-07-01' AND '2024-09-30'
  GROUP BY 1
)
SELECT segment, roi, AVG(roi) OVER () AS avg_roi,
  CASE WHEN roi > AVG(roi) OVER () THEN 'higher than average'
  ELSE 'lower than average' END AS roi_comparison
  FROM roi_table
GROUP BY 1

/*markdown
This one had an interesting new learning for me, [frame specifications](https://www.sqlite.org/syntax/frame-spec.html). I was able to specify which rows in the window function I wanted to roll over. That's WILD. It also only works if there are no date values missing or anything like that. If there was one missing, the values would come incorrectly.
*/

/*markdown
#### Phone Partnership Subscriber Retention Metrics 
*/

/*markdown
##### You are a Data Analyst in the Partnerships & Bundling team at a telecom company. Your team is investigating the impact of different telecom partners on Netflix subscriber conversion, retention, and engagement for phone plan bundles. The goal is to identify which partners drive the most conversions, longest retention, and highest engagement to inform future partnership strategies and pricing models. 
*/

/*markdown
###### For subscribers who converted in January 2024, give us the name of the Telecom partner that led to acquiring the most new subscribers?
*/

SELECT partner_name, COUNT(subscriber_id) AS subscriber_count
FROM fct_bundle_subscriptions s
  JOIN dim_telecom_partners p
  ON p.partner_id = s.partner_id
WHERE conversion_date LIKE '2024-01%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1

/*markdown
###### For each telecom partner, what is the longest number of days that a subscriber remained active after conversion and which bundle(s) did they subscribe on? For this analysis, only look at conversions between October 8th, 2024 and October 14th, 2024. If there are multiple bundles resulting in the same highest retention, return all the bundles.
*/

WITH ranked AS (
  SELECT partner_name, bundle_id, retention_days,
   RANK() OVER (PARTITION BY partner_name ORDER BY retention_days DESC) AS ranknum
  FROM fct_bundle_subscriptions s
  JOIN dim_telecom_partners p
  ON p.partner_id = s.partner_id
  WHERE conversion_date BETWEEN '2024-10-08' AND '2024-10-14'
    )
SELECT partner_name, bundle_id, retention_days FROM ranked WHERE ranknum = 1

/*markdown
###### For subscribers who converted in November 2024, what is the average engagement score for each bundle within each telecom partner. How does each bundle’s average engagement score compare to the all-time highest engagement score recorded by its respective telecom partner expressed as a percentage of that maximum?
*/

WITH max_all_dates AS (
  SELECT partner_name, MAX(engagement_score) AS max_engagement_score
FROM fct_bundle_subscriptions s
  JOIN dim_telecom_partners p
  ON p.partner_id = s.partner_id
  GROUP BY 1
), agg_values AS (
  SELECT partner_name, bundle_id, AVG(engagement_score) AS avg_engagement_score
  FROM fct_bundle_subscriptions s
  JOIN dim_telecom_partners p
  ON p.partner_id = s.partner_id
WHERE conversion_date LIKE '2024-11%'
GROUP BY 1, 2
)
SELECT m.partner_name, bundle_id, avg_engagement_score, max_engagement_score,
  ROUND(avg_engagement_score / max_engagement_score * 100,1) AS percent_engagment_score
FROM agg_values v
LEFT JOIN max_all_dates m
ON m.partner_name = v.partner_name

/*markdown
This one wasn't too hard, though it tried to get a little tricky with the different selection criteria in the last problem.
*/

/*markdown
#### Creators Growth: Engagement and Follower Metrics
*/

/*markdown
##### You are a Data Analyst on the Creator Growth team at Meta, focused on evaluating how different content types influence creator success. Your team aims to determine which content types most effectively drive engagement and follower growth for creators. The ultimate goal is to provide creators with actionable insights to optimize their content strategies for maximum audience expansion.
*/

/*markdown
###### For content published in May 2024, which creator IDs show the highest new follower growth within each content type? If a creator published multiple of the same content type, we want to look at the total new follower growth from that content type.
*/

WITH growth AS (
SELECT content_type, creator_id, SUM(new_followers_count) AS total_follower_growth,
  ROW_NUMBER() OVER (PARTITION BY content_type ORDER BY SUM(new_followers_count) DESC) AS rownum
FROM fct_creator_content
WHERE published_date LIKE '2024-05%'
GROUP BY 1, 2
  )
SELECT * FROM growth WHERE rownum = 1

/*markdown
###### Your Product Manager requests a report that shows impressions, likes, comments, and shares for each content type between April 8 and 21, 2024. She specifically requests that engagement metrics are unpivoted into a single 'metric type' column.
*/

SELECT content_type, 'impressions' AS metric, SUM(impressions_count) AS total
FROM fct_creator_content
WHERE published_date BETWEEN '2024-04-08' AND '2024-04-21'
GROUP BY 1
UNION ALL
SELECT content_type, 'likes' AS metric, SUM(likes_count) AS total
FROM fct_creator_content
WHERE published_date BETWEEN '2024-04-08' AND '2024-04-21'
GROUP BY 1
UNION ALL
SELECT content_type, 'comments' AS metric, SUM(comments_count) AS total
FROM fct_creator_content
WHERE published_date BETWEEN '2024-04-08' AND '2024-04-21'
GROUP BY 1
UNION ALL
SELECT content_type, 'shares' AS metric, SUM(shares_count) AS total
FROM fct_creator_content
WHERE published_date BETWEEN '2024-04-08' AND '2024-04-21'
GROUP BY 1

/*markdown
-- This is my first time ever "unpivoting"
*/

/*markdown
###### For content published between April and June 2024, can you calculate for each creator, what % of their new followers came from each content type?
*/

SELECT content_type, creator_id,
  SUM(new_followers_count) / SUM(new_followers_count) OVER (PARTITION BY creator_id) * 100
FROM fct_creator_content
WHERE published_date BETWEEN '2024-04-01' AND '2024-06-31'
  GROUP BY 2, 1

/*markdown
The major learning here was definitely problem 2, which required me to unpivot something. 
The last problem was interesting in that I used a window function to get help me get the proportion of a value across a dimension. 
*/

/*markdown
#### Corporate Social Responsibility Community Program Impact
*/

/*markdown
##### As a Data Analyst on Apple's Corporate Social Responsibility team, you are tasked with evaluating the effectiveness of recent philanthropic initiatives. Your focus is on understanding participant engagement across different communities and programs. The insights you gather will guide strategic decisions for resource allocation and future program expansions.
*/

/*markdown
###### Apple's Corporate Social Responsibility team wants a summary report of philanthropic initiatives in January 2024. Please compile a report that aggregates participant numbers by community and by program.
*/

SELECT community_name, program_name, SUM(participants) AS total_participants
FROM fct_philanthropic_initiatives i
JOIN dim_community c
ON c.community_id = i.community_id
  WHERE event_date LIKE '2024-01%'
GROUP BY 1, 2

/*markdown
###### The team is reviewing the execution of February 2024 philanthropic programs. For each initiative, provide details along with the earliest event date recorded within each program campaign to understand start timings.
*/

SELECT program_name, community_name, i.community_id, region, MIN(event_date)
FROM fct_philanthropic_initiatives i
JOIN dim_community c
ON c.community_id = i.community_id
WHERE event_date LIKE '2024-02%'
GROUP BY 1, 2, 3, 4

/*markdown
###### For a refined analysis of initiatives held during the first week of March 2024, include for each program the maximum participation count recorded in any event. This information will help highlight the highest engagement levels within each campaign.
*/

SELECT program_name, MAX(participants)
FROM fct_philanthropic_initiatives i
JOIN dim_community c
ON c.community_id = i.community_id
WHERE event_date BETWEEN '2024-03-01' AND '2024-03-07'
GROUP BY 1

/*markdown
This problem set felt really easy all across the board. Like, besides interpreting what data to include when it asked for "details," I really didn't struggle with any part of the work. Identifying the maxes and mins was probably what this was testing.
*/

/*markdown
#### Prime Member Exclusive Product Engagement Metrics
*/

/*markdown
##### As a Data Analyst on the Amazon Prime product analytics team, you are tasked with evaluating Prime member engagement with exclusive promotions. Your team is focused on understanding how members interact with special deals and early product access. The goal is to identify engagement patterns and target highly engaged members to enhance member value and drive higher engagement with these offerings
*/

SELECT COUNT(DISTINCT member_id) AS deal_purchasers, COUNT(*) / COUNT(DISTINCT member_id) AS avg_purchases_per_user
FROM fct_prime_deals
WHERE purchase_date LIKE '2024-01%'

/*markdown
###### To gain insights into purchase patterns, what is the distribution of members based on the number of deals purchased in February 2024? Group the members into the following categories: 1-2 deals, 3-5 deals, and more than 5 deals.
*/

WITH cte AS (
  SELECT member_id, COUNT(*) AS deals_per_user
FROM fct_prime_deals
WHERE purchase_date LIKE '2024-02%'
GROUP BY 1
  )
SELECT CASE
WHEN deals_per_user BETWEEN 1 AND 2 THEN "1-2 deals"
WHEN deals_per_user BETWEEN 3 AND 5 THEN "3-5 deals"
WHEN deals_per_user > 5 THEN "more than 5 deals" END AS purchase_buckets,
  COUNT(*)
FROM cte
GROUP BY 1

/*markdown
###### To target highly engaged members for tailored promotions, can we identify Prime members who purchased more than 5 exclusive deals between January 1st and March 31st, 2024? How many such members are there and what is their average total spend on these deals?
*/

WITH high_spenders AS (
  SELECT member_id, SUM(purchase_amount) AS purchase_sum
  FROM fct_prime_deals
  WHERE purchase_date BETWEEN '2024-01-01' AND '2024-03-31'
  GROUP BY 1
    HAVING COUNT(*) >5
)
SELECT count(member_id), AVG(purchase_sum) FROM high_spenders

/*markdown
I initially made this one way harder than it was, trying to use subqueries to find member ids with >5 purchases, and a seperate subquery to aggregate the sums before I took the average. A single cte was all that I needed to do both at the same time, since the count of the members ids and the average of their total spends can be easily taken from a cte grouped by ids.
*/

/*markdown
#### Third-Party Seller Fees and Performance Metrics
*/

/*markdown
###### For each seller, please identify their top sale transaction in April 2024 based on sale amount. If there are multiple transactions with the same sale amount, select the one with the most recent sale_date.
*/

WITH cte AS (
SELECT *,
RANK() OVER
(PARTITION BY seller_name ORDER BY sale_amount DESC, sale_date DESC) AS ranked_by_sale
FROM fct_seller_sales
JOIN dim_seller
ON fct_seller_sales.seller_id = dim_seller.seller_id
WHERE sale_date LIKE "2024-04%"
)
SELECT *
FROM cte
WHERE ranked_by_sale = 1

/*markdown
###### Within May 2024, for each seller ID, please generate a weekly summary that reports the total number of sales transactions and shows the fee amount from the most recent sale in that week. This analysis will let us correlate fee changes with weekly seller performance trends.
*/

WITH weekly_sales AS (
  SELECT sale_id, sale_amount, fee_amount_percentage, seller_id,
    strftime('%W', sale_date) AS week,
    ROW_NUMBER() OVER
      (PARTITION BY strftime('%W',sale_date), seller_id ORDER BY sale_date DESC) AS rownum
    FROM fct_seller_sales
    WHERE sale_date LIKE '2024-05%'
 ORDER BY week ASC
)
SELECT week, ws.seller_id, seller_name, COUNT(*) AS sales_per_week,
  MAX(CASE WHEN rownum = 1 THEN fee_amount_percentage END) AS recent_fee_amount_percentage
FROM weekly_sales ws
JOIN dim_seller ds
ON ws.seller_id = ds.seller_id
GROUP BY 1,2

/*markdown
This one was really tricky and I needed a lot of help with it. Specifically, I needed assistance with the window function in the CTE and the CASE function in the main query. More practice!
*/

/*markdown
###### Using June 2024, for each seller, create a daily report that computes a cumulative count of transactions up to that day.
*/

SELECT seller_id, sale_date, COUNT(*) OVER (PARTITION BY seller_id ORDER BY sale_date)
FROM fct_seller_sales
WHERE sale_date LIKE '2024-06%'

/*markdown
The takeaway:
Part three was MUCH easier than part two, or even part one, haha. The main thing is that I'm getting practice with window functions and how I can use them to effect change.
*/

/*markdown
#### Google Pay Digital Wallet Transaction Security Patterns
*/

/*markdown
##### You are a Product Analyst on the Google Pay security team focused on improving the reliability of digital payments. Your team needs to analyze transaction success and failure rates across various merchant categories to identify potential friction points in payment experiences. By understanding these patterns, you aim to guide product improvements for a smoother and more reliable payment process.
*/

/*markdown
###### For January 2024, what are the total counts of successful and failed transactions in each merchant category? This analysis will help the Google Pay security team identify potential friction points in payment processing.
*/

SELECT merchant_category, transaction_status, COUNT(transaction_status) AS transaction_status_count
FROM fct_transactions
WHERE transaction_date LIKE "2024-01%"
GROUP BY 1, 2

/*markdown
###### For the first quarter of 2024, which merchant categories recorded a transaction success rate below 90%? This insight will guide our prioritization of security enhancements to improve payment reliability.
*/

WITH cte AS (
  SELECT merchant_category, transaction_id, CASE
  WHEN transaction_status = "SUCCESS" THEN 1.0
  ELSE 0.0
  END AS transaction_count
FROM fct_transactions
WHERE transaction_date BETWEEN "2024-01-01" AND "2024-03-31"
), cte2 AS (
  SELECT merchant_category, SUM(transaction_count) / COUNT(transaction_id) AS transaction_success_rate
  FROM cte
  GROUP BY 1
)
SELECT merchant_category, transaction_success_rate
  FROM cte2
  WHERE transaction_success_rate <.9
GROUP BY 1

/*markdown
###### From January 1st to March 31st, 2024, can you generate a list of merchant categories with their concatenated counts for successful and failed transactions? Then, rank the categories by total transaction volume. This ranking will support our assessment of areas where mixed transaction outcomes may affect user experience.
*/

SELECT merchant_category, CONCAT(SUM(CASE
   WHEN transaction_status = "SUCCESS" THEN 1.0
   ELSE 0 END), "-",
   SUM(CASE
   WHEN transaction_status = "FAILED" THEN 1.0
   ELSE 0 END)) AS transaction_success_rates
FROM fct_transactions
WHERE transaction_date BETWEEN "2024-01-01" AND "2024-03-31"
GROUP BY 1
ORDER BY COUNT(*) DESC

/*markdown
The takeaway
*/

/*markdown
#### Photo Sharing Platform User Engagement Metrics
*/

/*markdown
##### As a Product Analyst on the Facebook Photos team, you are tasked with understanding user engagement with the photo sharing feature across different age and geographic segments. Your team is particularly interested in how users under 18 or over 50, as well as international users, are utilizing these features. The insights will guide your team in tailoring product strategies and enhancements to boost engagement among these key user segments.
*/

/*markdown
###### How many photos were shared by users who are either under 18 years old or over 50 years old during July 2024? This metric will help us understand if these age segments are engaging with the photo sharing feature.
*/

SELECT COUNT(photo_id)
FROM fct_photo_sharing
  JOIN dim_user
  ON fct_photo_sharing.user_id = dim_user.user_id
WHERE (age < 18 OR age > 50)
AND shared_date LIKE "2024-07%"

/*markdown
###### What are the user IDs and the total number of photos shared by users who are not from the United States during August 2024? This analysis will help us identify engagement patterns among international users.
*/

SELECT fct_photo_sharing.user_id, COUNT(photo_id)
FROM fct_photo_sharing
  JOIN dim_user
  ON fct_photo_sharing.user_id = dim_user.user_id
WHERE country != "United States" AND shared_date LIKE "2024-08%"
GROUP BY 1

/*markdown
###### What is the total number of photos shared by users who are either under 18 years old or over 50 years old and who are not from the United States during the third quarter of 2024? This measure will inform us if there are significant differences in usage across these age and geographic segments.
*/

SELECT COUNT(photo_id)
FROM fct_photo_sharing
  JOIN dim_user
  ON fct_photo_sharing.user_id = dim_user.user_id
WHERE (age < 18 OR age > 50) AND country != "United States"
AND shared_date BETWEEN "2024-07-01" AND "2024-09-30"

/*markdown
This one was testing my ability to use logic to construct complex conditionals for the filters. I find that particularly easy as I have a really strong backgound in logic.
*/

/*markdown
#### Pro Content Creator Mac Software Usage Insights
*/

/*markdown
##### As a Product Analyst on the Mac software team, you are tasked with understanding user engagement with multimedia tools. Your team aims to identify key usage patterns and determine how much time users spend on these tools. The end goal is to use these insights to enhance product features and improve user experience.
*/

/*markdown
###### As a Product Analyst on the Mac software team, you need to understand the engagement of professional content creators with multimedia tools. What is the number of distinct users on the last day in July 2024?
*/

SELECT COUNT(DISTINCT user_id) FROM fct_multimedia_usage
WHERE usage_date = "2024-07-31"

/*markdown
###### As a Product Analyst on the Mac software team, you are assessing how much time professional content creators spend using multimedia tools. What is the average number of hours spent by users during August 2024? Round the result up to the nearest whole number.
*/

 SELECT CEIL(AVG(hours_spent))
FROM fct_multimedia_usage
WHERE usage_date LIKE "2024-08%"

/*markdown
######  As a Product Analyst on the Mac software team, you are investigating exceptional daily usage patterns in September 2024. For each day, determine the distinct user count and the total hours spent using multimedia tools. Which days have both metrics above the respective average daily values for September 2024?
*/

WITH daily_metrics AS (
  SELECT usage_date,
  COUNT(DISTINCT user_id) as daily_user_count,
  SUM(hours_spent) AS daily_hours_spent
  FROM fct_multimedia_usage
  WHERE usage_date LIKE "2024-09%"
  GROUP BY usage_date
  ),
average_metrics AS (
  SELECT AVG(daily_hours_spent) AS avg_hours_spent,
  AVG(daily_user_count) AS avg_user_count
  FROM daily_metrics
)
  SELECT usage_date, daily_user_count, daily_hours_spent
FROM daily_metrics
  JOIN average_metrics
WHERE daily_user_count > avg_user_count
AND daily_hours_spent > avg_hours_spent

/*markdown
I didn't know you could call one cte in another cte, that's wild. It was really cool to learn, and will definitely be an important tool in my toolbox going forward.
*/

/*markdown
#### Reorder Patterns for Amazon Fresh
*/

/*markdown

##### As a Data Analyst on the Amazon Fresh product team, you and your team are focused on enhancing the customer experience by streamlining the process for customers to reorder their favorite grocery items. Your goal is to identify the most frequently reordered product categories, understand customer preferences for these products, and calculate the average reorder frequency across categories. By analyzing these metrics, you aim to provide actionable insights that will inform strategies to improve customer satisfaction and retention.


*/

/*markdown
###### The product team wants to analyze the most frequently reordered product categories. Can you provide a list of the product category codes (using first 3 letters of product code) and their reorder counts for Q4 2024?
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
#### Device Integration with Amazon Services
*/

/*markdown
##### As a Data Analyst on the Amazon Devices team, you are tasked with evaluating the usage patterns of Amazon services on devices like Echo, Fire TV, and Kindle. Your goal is to categorize device usage, assess overall engagement levels, and analyze the contribution of Prime Video and Amazon Music to total usage. This analysis will inform strategies to optimize service offerings and improve customer satisfaction.
*/

/*markdown
###### The team wants to identify the total usage duration of the services for each device type by extracting the primary device category from the device name for the period from July 1, 2024 to September 30, 2024. The primary device category is derived from the first word of the device name.
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
#### Engagement with Facebook Events
*/

##### As a Data Scientist on the Facebook Events Discovery team, you are tasked with analyzing user interaction with event recommendations to enhance the relevance of these suggestions. Your goal is to identify which event categories receive the most user clicks, determine if users are engaging with events in their preferred categories, and understand user engagement patterns by analyzing click data. This analysis will help optimize recommendation algorithms to increase user satisfaction and event attendance.

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
#### App Download Conversion Rates by Category
*/

/*markdown
##### You are on the Google Play store's App Marketplace team. You and your team want to understand how different app categories convert from browsing to actual downloads. This analysis is critical in informing future product placement and marketing strategies for app developers and users.
*/

/*markdown
###### The marketplace team wants to identify high and low performing app categories. Provide the total downloads for the app categories for November 2024. If there were no downloads for that category, return the value as 0.
*/

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

/*markdown
I initially ran this as a straightforward LEFT JOIN, thinking that would catch all the category names.
But the date filter was eliminating categories that should have been included, so I used a CTE
to prefilter the values and joined to that instead, with success!
*/

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

/*markdown
I first thought that I would need two CTEs but I tried doing it first with no CTE and then with one CTE, but filtering download and download date and browse and browse date couldn't happen in the same functions. I also got stuck on where to filter out the aggregate of the browse count when it was 0
*/

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

/*markdown
This was very easy, all I had to do was include app_type in both the select and group by sections and update the date to include all of Q4
*/

/*markdown
Takeaway: It's important to remember that it's unwise to apply filters on multiple aggregates at a time. It introduces the risk that your filter for one aggregate will falsify the other and vice versa. Multiple CTEs were necessary this time to ensure that was successful.
*/

/*markdown
### HackerRank
*/

/*markdown
### Data Lemur
*/



###### 3-Topping Pizzas



You’re a consultant for a major pizza chain that will be running a promotion where all 3-topping pizzas will be sold for a fixed price, and are trying to understand the costs involved.
Given a list of pizza toppings, consider all the possible 3-topping pizzas, and print out the total cost of those 3 toppings. Sort the results with the highest total cost on the top followed by pizza toppings in ascending order.
Break ties by listing the ingredients in alphabetical order, starting from the first ingredient, followed by the second and third.




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
**[Interview Master →](#interview-master)** 
**[HackerRank →](#hackerrank)**
*/