# SQL Interview Preparation Repository

## Overview
This repository is a complete guide for SQL interview preparation, covering all essential SQL topics, functions, queries, and concepts. It includes detailed explanations and example queries for each topic to help beginners and advanced learners master SQL. The repository is ideal for preparing for technical interviews or enhancing SQL skills.

## Table of Contents
- [Purpose](#purpose)
- [Topics Covered with Examples](#topics-covered-with-examples)
- [How to Use This Repository](#how-to-use-this-repository)
- [Contributing](#contributing)
- [Resources](#resources)
- [License](#license)

## Purpose
This repository aims to provide a structured resource for SQL learning and interview preparation. It includes:
- Comprehensive coverage of SQL topics.
- Example queries for practical understanding.
- Common interview questions and solutions.
- Best practices for writing efficient SQL queries.

## Topics Covered with Examples
Below is a list of all SQL topics covered in this repository, each accompanied by a simple example query to illustrate the concept.

### 1. Basic SQL Concepts
**Description**: Covers SQL syntax, data types, and database/table creation.
**Example**:
```sql
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    hire_date DATE
);
```

### 2. Data Manipulation Language (DML)
**Description**: Includes INSERT, SELECT, UPDATE, and DELETE operations.
**Example**:
```sql
INSERT INTO employees (emp_id, emp_name, hire_date)
VALUES (1, 'John Doe', '2023-01-15');
SELECT * FROM employees WHERE emp_id = 1;
```

### 3. Data Definition Language (DDL)
**Description**: Involves CREATE, ALTER, DROP, and TRUNCATE commands.
**Example**:
```sql
ALTER TABLE employees
ADD COLUMN salary DECIMAL(10, 2);
```

### 4. Data Control Language (DCL)
**Description**: Manages permissions with GRANT and REVOKE.
**Example**:
```sql
GRANT SELECT ON employees TO user_role;
```

### 5. SQL Clauses
**Description**: Includes WHERE, ORDER BY, GROUP BY, HAVING, and DISTINCT.
**Example**:
```sql
SELECT department, COUNT(*) as emp_count
FROM employees
GROUP BY department
HAVING COUNT(*) > 5
ORDER BY emp_count DESC;
```

### 6. SQL Functions
**Description**: Covers aggregate, string, date, mathematical, and conditional functions.
**Example**:
```sql
SELECT emp_name, ROUND(salary, 2) as rounded_salary,
       UPPER(emp_name) as name_upper,
       DATEDIFF(CURDATE(), hire_date) as days_employed
FROM employees;
```

### 7. Joins
**Description**: Includes INNER, LEFT, RIGHT, FULL, and CROSS JOINs.
**Example**:
```sql
SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
```

### 8. Subqueries
**Description**: Covers single-row, multi-row, and correlated subqueries.
**Example**:
```sql
SELECT emp_name
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
```

### 9. Indexes
**Description**: Explains creating and managing indexes for performance.
**Example**:
```sql
CREATE INDEX idx_emp_name ON employees(emp_name);
```

### 10. Views
**Description**: Covers creating and managing views.
**Example**:
```sql
CREATE VIEW high_salary_employees AS
SELECT emp_name, salary
FROM employees
WHERE salary > 50000;
```

### 11. Stored Procedures
**Description**: Explains writing and executing stored procedures.
**Example**:
```sql
DELIMITER //
CREATE PROCEDURE GetEmployeeCount()
BEGIN
    SELECT COUNT(*) FROM employees;
END //
DELIMITER ;
CALL GetEmployeeCount();
```

### 12. Triggers
**Description**: Covers creating triggers for automatic actions.
**Example**:
```sql
CREATE TRIGGER after_salary_update
AFTER UPDATE ON employees
FOR EACH ROW
INSERT INTO salary_audit (emp_id, old_salary, new_salary)
VALUES (OLD.emp_id, OLD.salary, NEW.salary);
```

### 13. Transactions
**Description**: Manages transactions with COMMIT and ROLLBACK.
**Example**:
```sql
START TRANSACTION;
UPDATE employees SET salary = salary + 1000 WHERE emp_id = 1;
COMMIT;
```

### 14. Common Table Expressions (CTEs)
**Description**: Uses WITH clause for readable queries.
**Example**:
```sql
WITH dept_avg AS (
    SELECT dept_id, AVG(salary) as avg_salary
    FROM employees
    GROUP BY dept_id
)
SELECT e.emp_name, e.salary, d.avg_salary
FROM employees e
JOIN dept_avg d ON e.dept_id = d.dept_id;
```

### 15. Window Functions
**Description**: Includes ROW_NUMBER, RANK, and LAG/LEAD.
**Example**:
```sql
SELECT emp_name, salary,
       RANK() OVER (PARTITION BY dept_id ORDER BY salary DESC) as salary_rank
FROM employees;
```

### 16. Query Optimization
**Description**: Techniques for writing efficient queries.
**Example**:
```sql
EXPLAIN SELECT emp_name
FROM employees
WHERE emp_id = 1;
```

### 17. Database Design
**Description**: Covers normalization and ER diagrams.
**Example**:
```sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

### 18. Set Operations
**Description**: Includes UNION, INTERSECT, and EXCEPT.
**Example**:
```sql
SELECT emp_name FROM employees
UNION
SELECT emp_name FROM former_employees;
```

### 19. Pattern Matching
**Description**: Uses LIKE and REGEXP for string matching.
**Example**:
```sql
SELECT emp_name
FROM employees
WHERE emp_name LIKE 'J%';
```

### 20. Handling NULL Values
**Description**: Manages NULLs with IS NULL and COALESCE.
**Example**:
```sql
SELECT emp_name, COALESCE(salary, 0) as salary
FROM employees;
```

### 21. Temporary Tables
**Description**: Creates temporary tables for session-specific data.
**Example**:
```sql
CREATE TEMPORARY TABLE temp_employees
SELECT * FROM employees WHERE dept_id = 10;
```

### 22. SQL in Different DBMS
**Description**: Highlights DBMS-specific syntax (e.g., MySQL, PostgreSQL).
**Example**:
```sql
-- MySQL
SELECT * FROM employees LIMIT 10;
-- SQL Server
SELECT TOP 10 * FROM employees;
```

## How to Use This Repository
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/sql-interview-prep.git
   ```
2. **Explore Topics**:
   - Each topic has a dedicated folder (e.g., `joins`, `window-functions`).
   - Folders contain SQL scripts and markdown files with explanations.
3. **Run Example Queries**:
   - Use `.sql` files in your DBMS (e.g., MySQL, PostgreSQL).
   - Sample datasets are provided for practice.
4. **Practice Interview Questions**:
   - Navigate to the `interview-questions` folder for categorized questions.
   - Attempt questions before checking solutions.
5. **Review Explanations**:
   - Read `.md` files for detailed concept explanations.

## Contributing
Contributions are encouraged! To contribute:
1. Fork the repository.
2. Create a branch (`git checkout -b new-topic`).
3. Add new topics, examples, or questions.
4. Commit changes (`git commit -m "Add new topic example"`).
5. Push to your fork (`git push origin new-topic`).
6. Submit a pull request with a clear description.

Ensure:
- Queries are tested in a major DBMS.
- Examples are clear and concise.
- No copyrighted material is included.

## Resources
- **Documentation**:
  - [MySQL](https://dev.mysql.com/doc/)
  - [PostgreSQL](https://www.postgresql.org/docs/)
  - [SQL Server](https://docs.microsoft.com/en-us/sql/)
- **Practice Platforms**:
  - [LeetCode](https://leetcode.com/problemset/database/)
  - [HackerRank](https://www.hackerrank.com/domains/sql)
  - [SQLZoo](https://sqlzoo.net/)
- **Books**:
  - "SQL Queries for Mere Mortals" by John L. Viescas.
  - "SQL Cookbook" by Anthony Molinaro.

## License
This repository is licensed under the [MIT License](LICENSE). Use, modify, and share the content for educational purposes.