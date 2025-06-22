# SQL Interview Questions and Answers Repository

## Overview
This repository is a comprehensive resource for SQL interview preparation, featuring a wide range of SQL interview questions with detailed answers and example queries. It covers all essential SQL topics, from basic concepts to advanced techniques, making it suitable for beginners, intermediate learners, and advanced professionals preparing for technical interviews.

## Table of Contents
- [Purpose](#purpose)
- [SQL Interview Questions and Answers](#sql-interview-questions-and-answers)
  - [Beginner-Level Questions](#beginner-level-questions)
  - [Intermediate-Level Questions](#intermediate-level-questions)
  - [Advanced-Level Questions](#advanced-level-questions)
- [How to Use This Repository](#how-to-use-this-repository)
- [Contributing](#contributing)
- [Resources](#resources)
- [License](#license)

## Purpose
The goal of this repository is to provide a one-stop resource for SQL interview preparation. It includes:
- A comprehensive set of SQL interview questions with clear, concise answers.
- Example queries to demonstrate solutions.
- Coverage of all major SQL topics, including basic syntax, joins, subqueries, window functions, and query optimization.
- Tips for writing efficient and maintainable SQL code.

## SQL Interview Questions and Answers
Below are categorized SQL interview questions with answers and example queries. The questions are divided into beginner, intermediate, and advanced levels to cater to different skill levels.

### Beginner-Level Questions

#### 1. What is SQL, and what are its main components?
**Answer**: SQL (Structured Query Language) is a standard language for managing and manipulating relational databases. Its main components are:
- **DDL (Data Definition Language)**: Defines database structures (e.g., CREATE, ALTER, DROP).
- **DML (Data Manipulation Language)**: Manipulates data (e.g., INSERT, SELECT, UPDATE, DELETE).
- **DCL (Data Control Language)**: Manages permissions (e.g., GRANT, REVOKE).
- **TCL (Transaction Control Language)**: Manages transactions (e.g., COMMIT, ROLLBACK).

#### 2. How do you retrieve all records from a table?
**Answer**: Use the SELECT statement with an asterisk (*) to retrieve all columns and rows from a table.
**Example**:
```sql
SELECT * FROM employees;
```

#### 3. How do you filter records using a condition?
**Answer**: Use the WHERE clause to filter records based on a condition.
**Example**:
```sql
SELECT emp_name, salary
FROM employees
WHERE salary > 50000;
```

#### 4. What is the difference between DELETE and TRUNCATE?
**Answer**:
- **DELETE**: Removes specific rows based on a condition and can be rolled back. It is a DML command.
- **TRUNCATE**: Removes all rows from a table without logging individual deletions and cannot be rolled back. It is a DDL command.
**Example**:
```sql
DELETE FROM employees WHERE dept_id = 10;
TRUNCATE TABLE employees;
```

#### 5. How do you sort query results?
**Answer**: Use the ORDER BY clause to sort results in ascending (ASC) or descending (DESC) order.
**Example**:
```sql
SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;
```

#### 6. What is a primary key?
**Answer**: A primary key is a unique identifier for each record in a table. It enforces uniqueness and cannot contain NULL values.
**Example**:
```sql
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50)
);
```

#### 7. How do you remove duplicate rows from query results?
**Answer**: Use the DISTINCT keyword to eliminate duplicate rows.
**Example**:
```sql
SELECT DISTINCT dept_id
FROM employees;
```

#### 8. What are aggregate functions in SQL?
**Answer**: Aggregate functions perform calculations on a set of values and return a single value (e.g., COUNT, SUM, AVG, MAX, MIN).
**Example**:
```sql
SELECT COUNT(*) as total_employees, AVG(salary) as avg_salary
FROM employees;
```

#### 9. How do you handle NULL values in SQL?
**Answer**: Use IS NULL or IS NOT NULL to check for NULL values, and functions like COALESCE or NULLIF to handle them.
**Example**:
```sql
SELECT emp_name, COALESCE(salary, 0) as salary
FROM employees
WHERE bonus IS NULL;
```

#### 10. What is the difference between WHERE and HAVING?
**Answer**:
- **WHERE**: Filters individual rows before grouping.
- **HAVING**: Filters groups after a GROUP BY clause is applied.
**Example**:
```sql
SELECT dept_id, COUNT(*) as emp_count
FROM employees
WHERE salary > 40000
GROUP BY dept_id
HAVING COUNT(*) > 5;
```

### Intermediate-Level Questions

#### 11. What are the different types of JOINs in SQL?
**Answer**: JOINs combine rows from two or more tables based on a related column:
- **INNER JOIN**: Returns matching rows from both tables.
- **LEFT JOIN**: Returns all rows from the left table and matching rows from the right table.
- **RIGHT JOIN**: Returns all rows from the right table and matching rows from the left table.
- **FULL JOIN**: Returns all rows from both tables, with NULLs for non-matching rows.
**Example**:
```sql
SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
```

#### 12. How do you write a subquery?
**Answer**: A subquery is a query nested within another query, often used in the WHERE or SELECT clause.
**Example**:
```sql
SELECT emp_name
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
```

#### 13. What is a self-join, and when is it used?
**Answer**: A self-join is a join where a table is joined with itself, often used to compare rows within the same table.
**Example**:
```sql
SELECT e1.emp_name as employee, e2.emp_name as manager
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.emp_id;
```

#### 14. How do you find duplicate records in a table?
**Answer**: Use GROUP BY and HAVING to identify rows with duplicate values.
**Example**:
```sql
SELECT email, COUNT(*) as count
FROM employees
GROUP BY email
HAVING COUNT(*) > 1;
```

#### 15. What is the difference between UNION and UNION ALL?
**Answer**:
- **UNION**: Combines distinct rows from multiple queries, removing duplicates.
- **UNION ALL**: Combines all rows, including duplicates, and is faster.
**Example**:
```sql
SELECT emp_name FROM employees
UNION
SELECT emp_name FROM former_employees;
```

#### 16. How do you create an index, and why is it important?
**Answer**: An index improves query performance by allowing faster data retrieval. Use CREATE INDEX to create one.
**Example**:
```sql
CREATE INDEX idx_salary ON employees(salary);
```

#### 17. What is a view, and how do you create one?
**Answer**: A view is a virtual table based on a query, used to simplify complex queries or restrict data access.
**Example**:
```sql
CREATE VIEW high_salary_employees AS
SELECT emp_name, salary
FROM employees
WHERE salary > 60000;
```

#### 18. How do you use string functions in SQL?
**Answer**: String functions manipulate text data (e.g., CONCAT, SUBSTRING, UPPER).
**Example**:
```sql
SELECT CONCAT(emp_name, ' - ', dept_id) as emp_info,
       UPPER(emp_name) as name_upper
FROM employees;
```

#### 19. What is a stored procedure, and how do you create one?
**Answer**: A stored procedure is a precompiled set of SQL statements that can be executed with a single call.
**Example**:
```sql
DELIMITER //
CREATE PROCEDURE IncreaseSalary(IN empID INT, IN increment DECIMAL(10,2))
BEGIN
    UPDATE employees
    SET salary = salary + increment
    WHERE emp_id = empID;
END //
DELIMITER ;
CALL IncreaseSalary(1, 5000);
```

#### 20. How do you limit the number of rows returned by a query?
**Answer**: Use LIMIT (MySQL/PostgreSQL) or TOP (SQL Server) to restrict the number of rows.
**Example**:
```sql
SELECT emp_name, salary
FROM employees
LIMIT 10;
```

### Advanced-Level Questions

#### 21. What is a correlated subquery, and how does it differ from a regular subquery?
**Answer**: A correlated subquery depends on the outer query and is executed for each row of the outer query, unlike a regular subquery, which runs independently.
**Example**:
```sql
SELECT emp_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM salary_history sh
    WHERE sh.emp_id = e.emp_id AND sh.salary > 70000
);
```

#### 22. How do you find the nth highest salary in a table?
**Answer**: Use a subquery with LIMIT and OFFSET or a window function like DENSE_RANK.
**Example**:
```sql
SELECT emp_name, salary
FROM (
    SELECT emp_name, salary, DENSE_RANK() OVER (ORDER BY salary DESC) as rnk
    FROM employees
) ranked
WHERE rnk = 2; -- For 2nd highest salary
```

#### 23. What are window functions, and how do you use them?
**Answer**: Window functions perform calculations across a set of rows related to the current row, without collapsing rows like aggregate functions.
**Example**:
```sql
SELECT emp_name, salary,
       ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) as rank_in_dept
FROM employees;
```

#### 24. How do you pivot data in SQL?
**Answer**: Pivoting transforms rows into columns. Some DBMS support PIVOT; otherwise, use CASE statements.
**Example**:
```sql
SELECT dept_id,
       SUM(CASE WHEN year = 2023 THEN sales ELSE 0 END) as sales_2023,
       SUM(CASE WHEN year = 2024 THEN sales ELSE 0 END) as sales_2024
FROM sales_data
GROUP BY dept_id;
```

#### 25. What is a Common Table Expression (CTE), and when is it used?
**Answer**: A CTE is a temporary result set defined using the WITH clause, improving query readability and supporting recursion.
**Example**:
```sql
WITH dept_avg AS (
    SELECT dept_id, AVG(salary) as avg_salary
    FROM employees
    GROUP BY dept_id
)
SELECT e.emp_name, e.salary, d.avg_salary
FROM employees e
JOIN dept_avg d ON e.dept_id = d.dept_id
WHERE e.salary > d.avg_salary;
```

#### 26. How do you optimize a slow SQL query?
**Answer**: Optimization techniques include:
- Adding indexes on frequently queried columns.
- Avoiding SELECT * and selecting only needed columns.
- Using EXPLAIN to analyze query execution plans.
- Simplifying joins and subqueries.
**Example**:
```sql
EXPLAIN SELECT emp_name
FROM employees
WHERE salary > 50000;
```

#### 27. What is a trigger, and how do you create one?
**Answer**: A trigger is a special type of stored procedure that automatically executes in response to certain events (e.g., INSERT, UPDATE).
**Example**:
```sql
CREATE TRIGGER audit_salary_update
AFTER UPDATE ON employees
FOR EACH ROW
INSERT INTO salary_audit (emp_id, old_salary, new_salary, change_date)
VALUES (OLD.emp_id, OLD.salary, NEW.salary, NOW());
```

#### 28. What are transactions, and how do you manage them?
**Answer**: A transaction is a sequence of operations performed as a single unit, following ACID properties. Use COMMIT, ROLLBACK, and SAVEPOINT to manage them.
**Example**:
```sql
START TRANSACTION;
UPDATE employees SET salary = salary + 1000 WHERE emp_id = 1;
SAVEPOINT sp1;
UPDATE employees SET salary = salary + 2000 WHERE emp_id = 2;
ROLLBACK TO sp1;
COMMIT;
```

#### 29. How do you handle hierarchical data using recursive queries?
**Answer**: Use recursive CTEs to query hierarchical data, such as organizational charts.
**Example**:
```sql
WITH RECURSIVE emp_hierarchy AS (
    SELECT emp_id, emp_name, manager_id, 1 as level
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.emp_id, e.emp_name, e.manager_id, eh.level + 1
    FROM employees e
    JOIN emp_hierarchy eh ON e.manager_id = eh.emp_id
)
SELECT emp_name, level
FROM emp_hierarchy;
```

#### 30. What is normalization, and why is it important?
**Answer**: Normalization is the process of organizing data to eliminate redundancy and improve integrity, typically through forms like 1NF, 2NF, and 3NF.
**Example**:
```sql
-- 1NF: Ensuring atomic values
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_ids VARCHAR(100) -- Violates 1NF
);
-- Normalized
CREATE TABLE order_details (
    order_id INT,
    product_id INT,
    PRIMARY KEY (order_id, product_id)
);
```

#### 31. How do you find the top 3 departments by average salary?
**Answer**: Use GROUP BY to calculate averages and LIMIT to get the top 3.
**Example**:
```sql
SELECT dept_id, AVG(salary) as avg_salary
FROM employees
GROUP BY dept_id
ORDER BY avg_salary DESC
LIMIT 3;
```

#### 32. What is the difference between clustered and non-clustered indexes?
**Answer**:
- **Clustered Index**: Determines the physical order of data in a table (one per table).
- **Non-Clustered Index**: A separate structure with pointers to the data (multiple per table).
**Example**:
```sql
CREATE CLUSTERED INDEX idx_emp_id ON employees(emp_id);
CREATE NONCLUSTERED INDEX idx_salary ON employees(salary);
```

#### 33. How do you handle pattern matching in SQL?
**Answer**: Use LIKE for simple patterns and REGEXP (in some DBMS) for complex patterns.
**Example**:
```sql
SELECT emp_name
FROM employees
WHERE emp_name LIKE 'A%';
```

#### 34. What are temporary tables, and when are they used?
**Answer**: Temporary tables store data for a session or transaction, useful for intermediate results.
**Example**:
```sql
CREATE TEMPORARY TABLE temp_high_salary
SELECT emp_name, salary
FROM employees
WHERE salary > 60000;
```

#### 35. How do you calculate a running total in SQL?
**Answer**: Use a window function like SUM with OVER to calculate running totals.
**Example**:
```sql
SELECT emp_name, salary,
       SUM(salary) OVER (ORDER BY emp_id) as running_total
FROM employees;
```

## How to Use This Repository
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/sql-interview-questions.git
   ```
2. **Navigate to Folders**:
   - The `questions` folder contains `.sql` files with queries and `.md` files with explanations.
   - The `datasets` folder includes sample data for practice.
3. **Practice Queries**:
   - Run `.sql` files in your preferred DBMS (e.g., MySQL, PostgreSQL, SQL Server).
   - Use provided datasets to test queries.
4. **Review Answers**:
   - Read markdown files for detailed explanations and context.
5. **Solve Questions**:
   - Attempt questions independently before checking answers.
   - Use the categorized sections to focus on specific skill levels.

## Contributing
Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a new branch (`git checkout -b add-question`).
3. Add new questions, answers, or examples.
4. Commit changes (`git commit -m "Add new interview question"`).
5. Push to your fork (`git push origin add-question`).
6. Open a pull request with a clear description.

Please ensure:
- Queries are tested in at least one major DBMS.
- Answers are accurate and concise.
- No copyrighted content is included.

## Resources
- **Official Documentation**:
  - [MySQL Documentation](https://dev.mysql.com/doc/)
  - [PostgreSQL Documentation](https://www.postgresql.org/docs/)
  - [SQL Server Documentation](https://docs.microsoft.com/en-us/sql/)
  - [Oracle SQL Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/)
- **Practice Platforms**:
  - [LeetCode SQL](https://leetcode.com/problemset/database/)
  - [HackerRank SQL](https://www.hackerrank.com/domains/sql)
  - [SQLZoo](https://sqlzoo.net/)
- **Books**:
  - "SQL in 10 Minutes, Sams Teach Yourself" by Ben Forta.
  - "SQL Performance Explained" by Markus Winand.

## License
This repository is licensed under the [MIT License](LICENSE). Feel free to use, modify, and distribute the content for educational purposes.