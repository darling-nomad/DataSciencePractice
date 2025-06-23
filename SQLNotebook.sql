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
##### App Download Conversion Rates by Category
###### You are on the Google Play store's App Marketplace team. You and your team want to understand how different app categories convert from browsing to actual downloads. This analysis is critical in informing future product placement and marketing strategies for app developers and users.

Tables <br>
Explore data<br>
dim_app(app_id, app_name, category, app_type)<br>
fct_app_browsing(app_id, browse_date, browse_count)<br>
fct_app_downloads(app_id, download_date, download_count)<br>

Question 1 of 3

The marketplace team wants to identify high and low performing app categories. Provide the total downloads for the app categories for November 2024. If there were no downloads for that category, return the value as 0.


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
##### The problem
*/

-- The code

/*markdown
The takeaway
*/



/*markdown
### Jump To
**[Interview Master →](#interview-master)** <br>
**[HackerRank →](#hackerrank)**
*/