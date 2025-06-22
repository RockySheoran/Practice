# SQL Interview Questions and Normalization Guide

## Overview
This repository is a comprehensive resource for SQL interview preparation, with a special focus on **database normalization** and its normal forms (1NF, 2NF, 3NF, BCNF, 4NF, 5NF). It includes detailed explanations, rules, and practical examples for each normal form, alongside a curated list of SQL interview questions with answers and example queries. The content is designed for beginners to advanced learners preparing for technical interviews or seeking to master SQL and database design.

## Table of Contents
- [Purpose](#purpose)
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
- Provide a detailed guide on database normalization, explaining each normal form with practical examples.
- Offer a comprehensive set of SQL interview questions with answers and example queries.
- Cover all major SQL topics, including basic syntax, joins, subqueries, window functions, and optimization.
- Serve as a practical resource for interview preparation and database design mastery.

## Database Normalization and Normal Forms

### What is Normalization?
Normalization is the process of organizing data in a relational database to eliminate redundancy, insertion, update, and deletion anomalies. It involves decomposing a table into smaller, well-structured tables that adhere to specific rules called normal forms. Each normal form builds on the previous one, ensuring data integrity and efficient storage.

### First Normal Form (1NF)
**Definition**: A table is in 1NF if:
- All attributes contain atomic (indivisible) values.
- There are no repeating groups or arrays in a single column.
- Each row is unique (typically enforced by a primary key).

**Purpose**: Eliminates repeating groups and ensures data is stored in a tabular format.

**Example**:
**Unnormalized Table** (violates 1NF):
```sql
CREATE TABLE unnormalized_orders (
    order_id INT,
    customer_name VARCHAR(50),
    products_ordered VARCHAR(100) -- e.g., "Laptop,Mouse,Keyboard"
);
INSERT INTO unnormalized_orders VALUES
(1, 'John Doe', 'Laptop,Mouse'),
(2, 'Jane Smith', 'Keyboard,Monitor');
```
**Problem**: The `products_ordered` column contains multiple values, making it hard to query individual products.

**1NF Table**:
```sql
CREATE TABLE orders (
    order_id INT,
    customer_name VARCHAR(50),
    product_ordered VARCHAR(50),
    PRIMARY KEY (order_id, product_ordered)
);
INSERT INTO orders VALUES
(1, 'John Doe', 'Laptop'),
(1, 'John Doe', 'Mouse'),
(2, 'Jane Smith', 'Keyboard'),
(2, 'Jane Smith', 'Monitor');
```
**Explanation**: Each product is stored in a separate row, ensuring atomic values and eliminating repeating groups.

### Second Normal Form (2NF)
**Definition**: A table is in 2NF if:
- It is in 1NF.
- All non-key attributes are fully functionally dependent on the entire primary key (no partial dependency).

**Purpose**: Removes partial dependencies, ensuring that non-key attributes depend on the whole primary key, not just part of it.

**Example**:
**Table in 1NF but not 2NF**:
```sql
CREATE TABLE order_details (
    order_id INT,
    product_id INT,
    customer_name VARCHAR(50), -- Depends only on order_id
    product_name VARCHAR(50), -- Depends only on product_id
    PRIMARY KEY (order_id, product_id)
);
INSERT INTO order_details VALUES
(1, 101, 'John Doe', 'Laptop'),
(1, 102, 'John Doe', 'Mouse');
```
**Problem**: `customer_name` depends only on `order_id`, and `product_name` depends only on `product_id`, causing partial dependencies.

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
INSERT INTO orders VALUES (1, 'John Doe');
INSERT INTO products VALUES (101, 'Laptop'), (102, 'Mouse');
INSERT INTO order_details VALUES (1, 101), (1, 102);
```
**Explanation**: Splitting into separate tables removes partial dependencies, as `customer_name` and `product_name` now depend on their respective primary keys.

### Third Normal Form (3NF)
**Definition**: A table is in 3NF if:
- It is in 2NF.
- There are no transitive dependencies (non-key attributes do not depend on other non-key attributes).

**Purpose**: Eliminates transitive dependencies to reduce redundancy and anomalies.

**Example**:
**Table in 2NF but not 3NF**:
```sql
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    dept_name VARCHAR(50) -- Depends on dept_id, not emp_id
);
INSERT INTO employees VALUES
(1, 'John Doe', 10, 'Sales'),
(2, 'Jane Smith', 10, 'Sales');
```
**Problem**: `dept_name` depends on `dept_id`, not directly on `emp_id`, creating a transitive dependency.

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
INSERT INTO employees VALUES (1, 'John Doe', 10), (2, 'Jane Smith', 10);
```
**Explanation**: Moving `dept_name` to a separate table eliminates the transitive dependency, reducing redundancy.

### Boyce-Codd Normal Form (BCNF)
**Definition**: A table is in BCNF if:
- It is in 3NF.
- For every functional dependency (X → Y), X is a superkey.

**Purpose**: Strengthens 3NF by ensuring all determinants are superkeys, addressing certain anomalies not handled by 3NF.

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
-- Functional dependency: instructor_id → instructor_name
INSERT INTO course_assignments VALUES
(1, 101, 201, 'Dr. Smith'),
(2, 101, 201, 'Dr. Smith');
```
**Problem**: `instructor_id → instructor_name` is a functional dependency where `instructor_id` is not a superkey.

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
INSERT INTO instructors VALUES (201, 'Dr. Smith');
INSERT INTO course_assignments VALUES (1, 101, 201), (2, 101, 201);
```
**Explanation**: Moving `instructor_name` to a separate table ensures all functional dependencies involve superkeys.

### Fourth Normal Form (4NF)
**Definition**: A table is in 4NF if:
- It is in BCNF.
- There are no non-trivial multi-valued dependencies.

**Purpose**: Eliminates multi-valued dependencies, where one attribute determines multiple independent attributes.

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
**Problem**: `student_id` determines multiple independent `course` and `hobby` values, creating a multi-valued dependency.

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
**Explanation**: Splitting into two tables eliminates the multi-valued dependency, as courses and hobbies are independent.

### Fifth Normal Form (5NF)
**Definition**: A table is in 5NF (or Project-Join Normal Form) if:
- It is in 4NF.
- It cannot be further decomposed into smaller tables without losing information (no join dependency exists unless it is trivial).

**Purpose**: Ensures the table cannot be split into smaller tables that can be rejoined to produce the original data, minimizing redundancy.

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
**Problem**: The table has a join dependency, as it can be decomposed into smaller tables (agent-product, agent-region, product-region) and rejoined without loss.

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
**Explanation**: Decomposing into three tables eliminates the join dependency, ensuring no loss of information when rejoined.

## SQL Interview Questions and Answers
Below is a curated list of SQL interview questions, categorized by difficulty, with answers and example queries. These complement the normalization section by covering other essential SQL topics.

### Beginner-Level Questions

#### 1. What is the difference between DELETE and TRUNCATE?
**Answer**:
- **DELETE**: Removes specific rows based on a condition (DML, can be rolled back).
- **TRUNCATE**: Removes all rows without logging individual deletions (DDL, cannot be rolled back).
**Example**:
```sql
DELETE FROM employees WHERE dept_id = 10;
TRUNCATE TABLE employees;
```

#### 2. How do you retrieve unique records from a table?
**Answer**: Use DISTINCT to eliminate duplicate rows.
**Example**:
```sql
SELECT DISTINCT dept_id
FROM employees;
```

#### 3. What is a primary key, and why is it important?
**Answer**: A primary key uniquely identifies each record in a table, ensuring uniqueness and non-null values.
**Example**:
```sql
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50)
);
```

#### 4. How do you filter data using multiple conditions?
**Answer**: Use the WHERE clause with AND, OR, and NOT operators.
**Example**:
```sql
SELECT emp_name, salary
FROM employees
WHERE dept_id = 10 AND salary > 50000;
```

#### 5. What are aggregate functions?
**Answer**: Aggregate functions (e.g., COUNT, SUM, AVG) perform calculations on a set of rows.
**Example**:
```sql
SELECT dept_id, AVG(salary) as avg_salary
FROM employees
GROUP BY dept_id;
```

### Intermediate-Level Questions

#### 6. What are the types of JOINs in SQL?
**Answer**: 
- **INNER JOIN**: Matches rows from both tables.
- **LEFT JOIN**: All rows from the left table, with matching rows from the right.
- **RIGHT JOIN**: All rows from the right table, with matching rows from the left.
- **FULL JOIN**: All rows from both tables.
**Example**:
```sql
SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
```

#### 7. How do you find duplicate records?
**Answer**: Use GROUP BY and HAVING to identify duplicates.
**Example**:
```sql
SELECT email, COUNT(*) as count
FROM employees
GROUP BY email
HAVING COUNT(*) > 1;
```

#### 8. What is a subquery?
**Answer**: A subquery is a query nested within another query, often used in WHERE or SELECT.
**Example**:
```sql
SELECT emp_name
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
```

#### 9. How do you create a view?
**Answer**: A view is a virtual table created from a query.
**Example**:
```sql
CREATE VIEW high_salary_employees AS
SELECT emp_name, salary
FROM employees
WHERE salary > 60000;
```

#### 10. What is the difference between UNION and UNION ALL?
**Answer**:
- **UNION**: Removes duplicates.
- **UNION ALL**: Includes duplicates, faster.
**Example**:
```sql
SELECT emp_name FROM employees
UNION ALL
SELECT emp_name FROM former_employees;
```

### Advanced-Level Questions

#### 11. What is a correlated subquery?
**Answer**: A correlated subquery depends on the outer query and executes for each row.
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

#### 12. How do you find the nth highest salary?
**Answer**: Use DENSE_RANK or LIMIT with OFFSET.
**Example**:
```sql
SELECT emp_name, salary
FROM (
    SELECT emp_name, salary, DENSE_RANK() OVER (ORDER BY salary DESC) as rnk
    FROM employees
) ranked
WHERE rnk = 2;
```

#### 13. What are window functions?
**Answer**: Window functions perform calculations across a set of rows without collapsing them.
**Example**:
```sql
SELECT emp_name, salary,
       ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) as rank
FROM employees;
```

#### 14. How do you optimize a query?
**Answer**: Use indexes, avoid SELECT *, simplify joins, and analyze with EXPLAIN.
**Example**:
```sql
CREATE INDEX idx_salary ON employees(salary);
EXPLAIN SELECT emp_name FROM employees WHERE salary > 50000;
```

#### 15. What is a recursive CTE?
**Answer**: A recursive CTE queries hierarchical data by referencing itself.
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

## How to Use This Repository
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/sql-normalization-interview.git
   ```
2. **Explore Normalization**:
   - The `normalization` folder contains `.sql` files with examples for each normal form.
   - Markdown files provide detailed explanations.
3. **Practice Interview Questions**:
   - The `interview-questions` folder contains categorized questions and solutions.
   - Use sample datasets in the `datasets` folder to test queries.
4. **Run Queries**:
   - Execute `.sql` files in your DBMS (e.g., MySQL, PostgreSQL).
   - Verify results using provided datasets.
5. **Review Explanations**:
   - Read `.md` files for in-depth understanding of normalization and SQL concepts.

## Contributing
Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a branch (`git checkout -b add-normalization-example`).
3. Add new questions, normalization examples, or clarifications.
4. Commit changes (`git commit -m "Add 5NF example"`).
5. Push to your fork (`git push origin add-normalization-example`).
6. Submit a pull request with a clear description.

Ensure:
- Queries are tested in a major DBMS.
- Examples are accurate and clear.
- No copyrighted content is included.

## Resources
- **Official Documentation**:
  - [MySQL](https://dev.mysql.com/doc/)
  - [PostgreSQL](https://www.postgresql.org/docs/)
  - [SQL Server](https://docs.microsoft.com/en-us/sql/)
- **Practice Platforms**:
  - [LeetCode SQL](https://leetcode.com/problemset/database/)
  - [HackerRank SQL](https://www.hackerrank.com/domains/sql)
  - [SQLZoo](https://sqlzoo.net/)
- **Books**:
  - "Database System Concepts" by Abraham Silberschatz.
  - "SQL Performance Explained" by Markus Winand.

## License
This repository is licensed under the [MIT License](LICENSE). Use, modify, and share for educational purposes.