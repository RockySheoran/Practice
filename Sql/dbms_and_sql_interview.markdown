```
# DBMS Comprehensive Guide and SQL Interview Questions

## Overview
This repository is a complete resource for mastering Database Management Systems (DBMS) and preparing for SQL interviews. It covers **all DBMS topics**, including a detailed section on **database normalization** with all normal forms (1NF, 2NF, 3NF, BCNF, 4NF, 5NF), and a comprehensive set of SQL interview questions with answers and example queries. Designed for beginners to advanced learners, it provides clear explanations, practical examples, and best practices for database design and querying.

## Table of Contents
- [Purpose](#purpose)
- [DBMS Topics Overview](#dbms-topics-overview)
- [Database Normalization and Normal Forms](#database-normalization-and-normal-forms)
  - [What is Normalization?](#what-is-normalization)
  - [First Normal Form (1NF)](#first-normal-form-1nf)
  - [Second Normal Form (2NF)](#second-normal-form-2nf)
  - [Third Normal Form (3NF)](#third-normal-form-3nf)
  - [Boyce-Codd Normal Form (BCNF)](#boyce-codd-normal-form-bcnf)
  - [Fourth Normal Form (4NF)](#fourth-normal-form-4nf)
  - [Fifth Normal Form (5NF)](#fifth-normal-form-5nf)
- [SQL Interview Questions and Answers](#sql-interview-questions-and-answers)
  - [Beginner-Level Questions](#beginner-level-questions)
  - [Intermediate-Level Questions](#intermediate-level-questions)
  - [Advanced-Level Questions](#advanced-level-questions)
- [How to Use This Repository](#how-to-use-this-repository)
- [Contributing](#contributing)
- [Resources](#resources)
- [License](#license)

## Purpose
This repository aims to:
- Provide a thorough understanding of all DBMS concepts, with a focus on normalization and database design.
- Offer a comprehensive set of SQL interview questions with detailed answers and example queries.
- Cover practical and theoretical aspects of DBMS, including data models, transactions, indexing, and query optimization.
- Serve as a one-stop resource for SQL interview preparation and DBMS mastery.

## DBMS Topics Overview
This repository covers the following DBMS topics:
1. **Introduction to DBMS**:
   - Definition, purpose, and advantages over file systems.
   - Components: Database, DBMS software, users, query processor.
2. **Data Models**:
   - Hierarchical, Network, Relational, Object-Oriented, NoSQL.
   - Entity-Relationship (ER) model and diagrams.
3. **Relational Model**:
   - Tables, tuples, attributes, keys (primary, foreign, candidate).
   - Relational algebra and constraints (domain, key, referential integrity).
4. **Normalization**:
   - Rules and normal forms to eliminate redundancy (detailed below).
5. **SQL (Structured Query Language)**:
   - DDL (CREATE, ALTER, DROP), DML (INSERT, SELECT, UPDATE, DELETE), DCL (GRANT, REVOKE), TCL (COMMIT, ROLLBACK).
   - Functions, joins, subqueries, window functions, CTEs.
6. **Transactions**:
   - ACID properties (Atomicity, Consistency, Isolation, Durability).
   - Concurrency control (locking, timestamps, MVCC).
7. **Indexing and Query Optimization**:
   - Types of indexes (clustered, non-clustered, B-tree).
   - Query execution plans (EXPLAIN, ANALYZE).
8. **Database Security**:
   - Authentication, authorization, encryption.
   - SQL injection prevention.
9. **Backup and Recovery**:
   - Types of backups (full, incremental).
   - Recovery techniques (log-based, shadow paging).
10. **Advanced Topics**:
    - Distributed databases and replication.
    - Data warehousing and OLAP.
    - NoSQL databases (key-value, document, graph).
11. **DBMS-Specific Features**:
    - Differences between MySQL, PostgreSQL, SQL Server, Oracle.
    - DBMS-specific functions and optimizations.

## Database Normalization and Normal Forms

### What is Normalization?
Normalization is the process of organizing data in a relational database to eliminate redundancy and anomalies (insertion, update, deletion) by decomposing tables into smaller, well-structured tables that adhere to specific rules called normal forms. Each normal form addresses specific types of dependencies and ensures data integrity.

### First Normal Form (1NF)
**Definition**: A table is in 1NF if:
- All attributes contain atomic (indivisible) values.
- There are no repeating groups or arrays in a column.
- Each row is unique (typically via a primary key).

**Purpose**: Ensures data is stored in a tabular format, eliminating repeating groups.

**Example**:
**Unnormalized Table** (violates 1NF):
```sql
CREATE TABLE unnormalized_orders (
    order_id INT,
    customer_name VARCHAR(50),
    products_ordered VARCHAR(100) -- e.g., "Laptop,Mouse"
);
INSERT INTO unnormalized_orders VALUES
(1, 'Alice', 'Laptop,Mouse'),
(2, 'Bob', 'Keyboard,Monitor');
```
**Problem**: `products_ordered` contains multiple values, making querying individual products difficult.

**1NF Table**:
```sql
CREATE TABLE orders (
    order_id INT,
    customer_name VARCHAR(50),
    product_ordered VARCHAR(50),
    PRIMARY KEY (order_id, product_ordered)
);
INSERT INTO orders VALUES
(1, 'Alice', 'Laptop'),
(1, 'Alice', 'Mouse'),
(2, 'Bob', 'Keyboard'),
(2, 'Bob', 'Monitor');
```
**Explanation**: Each product is in a separate row, ensuring atomic values and no repeating groups.

### Second Normal Form (2NF)
**Definition**: A table is in 2NF if:
- It is in 1NF.
- All non-key attributes are fully functionally dependent on the entire primary key (no partial dependency).

**Purpose**: Removes partial dependencies, ensuring non-key attributes depend on the whole primary key.

**Example**:
**Table in 1NF but not 2NF**:
```sql
CREATE TABLE order_details (
    order_id INT,
    product_id INT,
    customer_name VARCHAR(50), -- Depends on order_id
    product_name VARCHAR(50), -- Depends on product_id
    PRIMARY KEY (order_id, product_id)
);
INSERT INTO order_details VALUES
(1, 101, 'Alice', 'Laptop'),
(1, 102, 'Alice', 'Mouse');
```
**Problem**: `customer_name` depends only on `order_id`, and `product_name` depends only on `product_id`.

**2NF Tables**:
```sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(50)
);
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50)
);
CREATE TABLE order_details (
    order_id INT,
    product_id INT,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
INSERT INTO orders VALUES (1, 'Alice');
INSERT INTO products VALUES (101, 'Laptop'), (102, 'Mouse');
INSERT INTO order_details VALUES (1, 101), (1, 102);
```
**Explanation**: Splitting eliminates partial dependencies, as attributes depend on their respective primary keys.

### Third Normal Form (3NF)
**Definition**: A table is in 3NF if:
- It is in 2NF.
- There are no transitive dependencies (non-key attributes do not depend on other non-key attributes).

**Purpose**: Eliminates transitive dependencies to reduce redundancy.

**Example**:
**Table in 2NF but not 3NF**:
```sql
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    dept_name VARCHAR(50) -- Depends on dept_id
);
INSERT INTO employees VALUES
(1, 'Alice', 10, 'Sales'),
(2, 'Bob', 10, 'Sales');
```
**Problem**: `dept_name` depends on `dept_id`, not directly on `emp_id`.

**3NF Tables**:
```sql
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50)
);
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
INSERT INTO departments VALUES (10, 'Sales');
INSERT INTO employees VALUES (1, 'Alice', 10), (2, 'Bob', 10);
```
**Explanation**: Moving `dept_name` to a separate table eliminates transitive dependency.

### Boyce-Codd Normal Form (BCNF)
**Definition**: A table is in BCNF if:
- It is in 3NF.
- For every functional dependency (X → Y), X is a superkey.

**Purpose**: Addresses anomalies not handled by 3NF by ensuring all determinants are superkeys.

**Example**:
**Table in 3NF but not BCNF**:
```sql
CREATE TABLE course_assignments (
    student_id INT,
    course_id INT,
    instructor_id INT,
    instructor_name VARCHAR(50),
    PRIMARY KEY (student_id, course_id)
);
-- Dependency: instructor_id → instructor_name
INSERT INTO course_assignments VALUES
(1, 101, 201, 'Dr. Lee'),
(2, 101, 201, 'Dr. Lee');
```
**Problem**: `instructor_id → instructor_name` where `instructor_id` is not a superkey.

**BCNF Tables**:
```sql
CREATE TABLE instructors (
    instructor_id INT PRIMARY KEY,
    instructor_name VARCHAR(50)
);
CREATE TABLE course_assignments (
    student_id INT,
    course_id INT,
    instructor_id INT,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id)
);
INSERT INTO instructors VALUES (201, 'Dr. Lee');
INSERT INTO course_assignments VALUES (1, 101, 201), (2, 101, 201);
```
**Explanation**: Separating `instructor_name` ensures all dependencies involve superkeys.

### Fourth Normal Form (4NF)
**Definition**: A table is in 4NF if:
- It is in BCNF.
- There are no non-trivial multi-valued dependencies.

**Purpose**: Eliminates multi-valued dependencies where one attribute determines multiple independent attributes.

**Example**:
**Table in BCNF but not 4NF**:
```sql
CREATE TABLE student_activities (
    student_id INT,
    course VARCHAR(50),
    hobby VARCHAR(50),
    PRIMARY KEY (student_id, course, hobby)
);
INSERT INTO student_activities VALUES
(1, 'Math', 'Chess'),
(1, 'Math', 'Soccer'),
(1, 'Physics', 'Chess'),
(1, 'Physics', 'Soccer');
```
**Problem**: `student_id` determines multiple independent `course` and `hobby` values.

**4NF Tables**:
```sql
CREATE TABLE student_courses (
    student_id INT,
    course VARCHAR(50),
    PRIMARY KEY (student_id, course)
);
CREATE TABLE student_hobbies (
    student_id INT,
    hobby VARCHAR(50),
    PRIMARY KEY (student_id, hobby)
);
INSERT INTO student_courses VALUES (1, 'Math'), (1, 'Physics');
INSERT INTO student_hobbies VALUES (1, 'Chess'), (1, 'Soccer');
```
**Explanation**: Splitting eliminates multi-valued dependencies.

### Fifth Normal Form (5NF)
**Definition**: A table is in 5NF if:
- It is in 4NF.
- It cannot be decomposed into smaller tables without losing information (no non-trivial join dependencies).

**Purpose**: Minimizes redundancy by ensuring no unnecessary table decompositions.

**Example**:
**Table in 4NF but not 5NF**:
```sql
CREATE TABLE sales_agents (
    agent_id INT,
    product_id INT,
    region VARCHAR(50),
    PRIMARY KEY (agent_id, product_id, region)
);
INSERT INTO sales_agents VALUES
(1, 101, 'North'),
(1, 102, 'South'),
(2, 101, 'South');
```
**Problem**: Join dependency allows decomposition into smaller tables.

**5NF Tables**:
```sql
CREATE TABLE agent_products (
    agent_id INT,
    product_id INT,
    PRIMARY KEY (agent_id, product_id)
);
CREATE TABLE agent_regions (
    agent_id INT,
    region VARCHAR(50),
    PRIMARY KEY (agent_id, region)
);
CREATE TABLE product_regions (
    product_id INT,
    region VARCHAR(50),
    PRIMARY KEY (product_id, region)
);
INSERT INTO agent_products VALUES (1, 101), (1, 102), (2, 101);
INSERT INTO agent_regions VALUES (1, 'North'), (1, 'South'), (2, 'South');
INSERT INTO product_regions VALUES (101, 'North'), (101, 'South'), (102, 'South');
```
**Explanation**: Decomposition eliminates join dependency, ensuring no data loss.

## SQL Interview Questions and Answers
Below are SQL and DBMS interview questions, categorized by difficulty, with answers and example queries.

### Beginner-Level Questions

#### 1. What is a DBMS, and how does it differ from a file system?
**Answer**: A DBMS is software for managing databases, offering data integrity, security, and querying capabilities. File systems store data in files without structured relationships or advanced querying.
**Example**: MySQL (DBMS) vs. CSV files (file system).

#### 2. What is the difference between DELETE and TRUNCATE?
**Answer**:
- **DELETE**: Removes specific rows (DML, rollback possible).
- **TRUNCATE**: Removes all rows (DDL, no rollback).
**Example**:
```sql
DELETE FROM employees WHERE dept_id = 10;
TRUNCATE TABLE employees;
```

#### 3. What is a primary key?
**Answer**: A primary key uniquely identifies each record, ensuring no NULLs or duplicates.
**Example**:
```sql
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50)
);
```

#### 4. How do you retrieve unique records?
**Answer**: Use DISTINCT to eliminate duplicates.
**Example**:
```sql
SELECT DISTINCT dept_id
FROM employees;
```

#### 5. What are aggregate functions?
**Answer**: Functions like COUNT, SUM, AVG perform calculations on multiple rows.
**Example**:
```sql
SELECT dept_id, AVG(salary) as avg_salary
FROM employees
GROUP BY dept_id;
```

#### 6. What is the difference between WHERE and HAVING?
**Answer**:
- **WHERE**: Filters individual rows before grouping.
- **HAVING**: Filters groups after GROUP BY.
**Example**:
```sql
SELECT dept_id, COUNT(*)
FROM employees
WHERE salary > 50000
GROUP BY dept_id
HAVING COUNT(*) > 5;
```

#### 7. What is a foreign key?
**Answer**: A foreign key links two tables by referencing the primary key of another table.
**Example**:
```sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

#### 8. How do you handle NULL values?
**Answer**: Use IS NULL, COALESCE, or NULLIF to manage NULLs.
**Example**:
```sql
SELECT emp_name, COALESCE(salary, 0) as salary
FROM employees
WHERE bonus IS NULL;
```

#### 9. What is an ER diagram?
**Answer**: An ER diagram visually represents entities, attributes, and relationships in a database.
**Example**: Entities (Customer, Order) with relationships (places).

#### 10. What is a transaction?
**Answer**: A transaction is a sequence of operations that follows ACID properties.
**Example**:
```sql
START TRANSACTION;
UPDATE employees SET salary = salary + 1000;
COMMIT;
```

### Intermediate-Level Questions

#### 11. What are the types of JOINs?
**Answer**:
- INNER, LEFT, RIGHT, FULL, CROSS JOINs.
**Example**:
```sql
SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
```

#### 12. What is a self-join?
**Answer**: A table joined with itself to compare rows.
**Example**:
```sql
SELECT e1.emp_name, e2.emp_name as manager
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.emp_id;
```

#### 13. How do you find duplicate records?
**Answer**: Use GROUP BY and HAVING.
**Example**:
```sql
SELECT email, COUNT(*)
FROM employees
GROUP BY email
HAVING COUNT(*) > 1;
```

#### 14. What is an index, and why is it used?
**Answer**: An index speeds up data retrieval but slows updates.
**Example**:
```sql
CREATE INDEX idx_salary ON employees(salary);
```

#### 15. What is a view?
**Answer**: A virtual table based on a query.
**Example**:
```sql
CREATE VIEW high_salary_employees AS
SELECT emp_name, salary
FROM employees
WHERE salary > 60000;
```

#### 16. What is the difference between UNION and UNION ALL?
**Answer**:
- **UNION**: Removes duplicates.
- **UNION ALL**: Includes duplicates.
**Example**:
```sql
SELECT emp_name FROM employees
UNION
SELECT emp_name FROM former_employees;
```

#### 17. What is a stored procedure?
**Answer**: A precompiled set of SQL statements.
**Example**:
```sql
DELIMITER //
CREATE PROCEDURE GetEmpCount()
BEGIN
    SELECT COUNT(*) FROM employees;
END //
DELIMITER ;
CALL GetEmpCount();
```

#### 18. What is concurrency control?
**Answer**: Manages simultaneous transactions to prevent conflicts (e.g., locking, MVCC).
**Example**: MySQL’s InnoDB uses row-level locking.

#### 19. How do you limit rows in a query?
**Answer**: Use LIMIT (MySQL) or TOP (SQL Server).
**Example**:
```sql
SELECT emp_name
FROM employees
LIMIT 10;
```

#### 20. What is a trigger?
**Answer**: A procedure that executes automatically on events.
**Example**:
```sql
CREATE TRIGGER salary_audit
AFTER UPDATE ON employees
FOR EACH ROW
INSERT INTO audit_log (emp_id, old_salary, new_salary)
VALUES (OLD.emp_id, OLD.salary, NEW.salary);
```

### Advanced-Level Questions

#### 21. What is a correlated subquery?
**Answer**: A subquery that depends on the outer query.
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

#### 22. How do you find the nth highest salary?
**Answer**: Use DENSE_RANK or LIMIT/OFFSET.
**Example**:
```sql
SELECT emp_name, salary
FROM (
    SELECT emp_name, salary, DENSE_RANK() OVER (ORDER BY salary DESC) as rnk
    FROM employees
) ranked
WHERE rnk = 2;
```

#### 23. What are window functions?
**Answer**: Perform calculations across a set of rows without collapsing them.
**Example**:
```sql
SELECT emp_name, salary,
       ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) as rank
FROM employees;
```

#### 24. How do you pivot data?
**Answer**: Use CASE or PIVOT (if supported).
**Example**:
```sql
SELECT dept_id,
       SUM(CASE WHEN year = 2023 THEN sales ELSE 0 END) as sales_2023,
       SUM(CASE WHEN year = 2024 THEN sales ELSE 0 END) as sales_2024
FROM sales_data
GROUP BY dept_id;
```

#### 25. What is a recursive CTE?
**Answer**: A CTE that references itself for hierarchical data.
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

#### 26. What is query optimization?
**Answer**: Techniques to improve query performance (e.g., indexing, EXPLAIN).
**Example**:
```sql
EXPLAIN SELECT emp_name
FROM employees
WHERE salary > 50000;
```

#### 27. What is the difference between clustered and non-clustered indexes?
**Answer**:
- **Clustered**: Defines data storage order (one per table).
- **Non-Clustered**: Separate structure with pointers.
**Example**:
```sql
CREATE CLUSTERED INDEX idx_emp_id ON employees(emp_id);
CREATE NONCLUSTERED INDEX idx_salary ON employees(salary);
```

#### 28. What is MVCC?
**Answer**: Multi-Version Concurrency Control manages concurrent transactions by maintaining data versions.
**Example**: PostgreSQL uses MVCC for snapshot isolation.

#### 29. How do you calculate a running total?
**Answer**: Use a window function like SUM OVER.
**Example**:
```sql
SELECT emp_name, salary,
       SUM(salary) OVER (ORDER BY emp_id) as running_total
FROM employees;
```

#### 30. What is a distributed database?
**Answer**: A database spread across multiple locations, with replication or partitioning.
**Example**: Google Spanner uses distributed architecture.

## How to Use This Repository
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/dbms-interview-guide.git
   ```
2. **Explore Topics**:
   - `normalization` folder: `.sql` files for each normal form.
   - `dbms-topics` folder: Explanations for other DBMS concepts.
   - `interview-questions` folder: Questions and solutions.
3. **Run Queries**:
   - Use `.sql` files in your DBMS (e.g., MySQL, PostgreSQL).
   - Test with sample datasets in the `datasets` folder.
4. **Review Explanations**:
   - Read `.md` files for detailed insights.
5. **Practice Questions**:
   - Attempt questions before checking answers.

## Contributing
Contributions are encouraged! To contribute:
1. Fork the repository.
2. Create a branch (`git checkout -b add-topic`).
3. Add content (questions, examples, explanations).
4. Commit changes (`git commit -m "Add distributed DB example"`).
5. Push to your fork (`git push origin add-topic`).
6. Submit a pull request.

Ensure:
- Queries are tested.
- Explanations are clear.
- No copyrighted material.

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
  - "Database System Concepts" by Silberschatz.
  - "SQL Queries for Mere Mortals" by Viescas.

## License
This repository is licensed under the [MIT License](LICENSE). Use, modify, and share for educational purposes.
```