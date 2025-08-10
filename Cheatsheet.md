# SQL & Python Cheat Sheet

This is a quick reference for common SQL and Python tasks, useful for tech screeners.

## SQL Database manipulation basics

##### Creating data
Creates a table and lets you set table name, column names, and datatypes for columns.
CREATE TABLE table_name (
  column1 datatype,
  column2 datatype,
  column3 datatype
);

##### Inserting data
Adds columns or rows into a table
INSERT INTO table_name (column1, column2) VALUES (value1, value2);

##### Updating data
Changes values in a table matching a condition
UPDATE table_name SET column1 = value WHERE condition;

##### Deleting data
Deletes rows from a table matching a condition
DELETE FROM table_name WHERE condition;

## Indexing

### Creating Indexes
Indexes can be created by calling the CREATE command with INDEX. 
Adding the UNIQUE parameter will enforce all values in the index be non-repeating.
CREATE UNIQUE INDEX index_name
ON table_name (value);
Multiple columns can be indexed together in parentheses, separated by commas.
CREATE INDEX index_name
ON table_name (value1, value2);

### Removing Indexes
Indexes can be removed using a drop command, though the syntax varies.
MS Access:

DROP INDEX index_name ON table_name;
SQL Server:

DROP INDEX table_name.index_name;
DB2/Oracle:

DROP INDEX index_name;
MySQL:

ALTER TABLE table_name
DROP INDEX index_name;

----------------------------------------
PYTHON BASICS
----------------------------------------



----------------------------------------
TIPS
----------------------------------------

- In SQL, always watch for SQL injection if using user input.
- In Python, use list comprehensions for concise loops.
- Use parameterized queries in SQL to avoid injection.
- Use virtual environments in Python for dependency management.

----------------------------------------
*/
