# SQL Interview Questions and Concepts Repository

## Overview
This repository is a comprehensive resource for SQL (Structured Query Language) interview preparation. It covers essential SQL concepts, functions, queries, and advanced topics commonly asked in technical interviews. Whether you're a beginner or an experienced professional, this repository provides detailed explanations, examples, and practice questions to help you master SQL.

## Table of Contents
- [Purpose](#purpose)
- [Topics Covered](#topics-covered)
- [How to Use This Repository](#how-to-use-this-repository)
- [Contributing](#contributing)
- [Resources](#resources)
- [License](#license)

## Purpose
The goal of this repository is to serve as a one-stop guide for SQL interview preparation. It includes:
- Common SQL interview questions with solutions.
- Detailed explanations of SQL functions and clauses.
- Example queries for various scenarios.
- Advanced SQL topics for experienced candidates.
- Tips and best practices for writing efficient SQL queries.

## Topics Covered
This repository covers a wide range of SQL topics, including but not limited to:

### 1. Basic SQL Concepts
- SQL syntax and structure.
- Data types (e.g., INT, VARCHAR, DATE).
- Creating and managing databases (CREATE, DROP, ALTER).
- Table operations (CREATE TABLE, ALTER TABLE, DROP TABLE).
- Primary keys, foreign keys, and constraints (UNIQUE, NOT NULL, CHECK).

### 2. Data Manipulation Language (DML)
- INSERT: Adding data to tables.
- SELECT: Retrieving data from tables.
- UPDATE: Modifying existing data.
- DELETE: Removing data from tables.

### 3. Data Definition Language (DDL)
- CREATE: Defining database structures.
- ALTER: Modifying database structures.
- DROP: Deleting database objects.
- TRUNCATE: Removing all data from a table.

### 4. Data Control Language (DCL)
- GRANT: Assigning permissions.
- REVOKE: Removing permissions.

### 5. SQL Clauses
- WHERE: Filtering data.
- ORDER BY: Sorting results.
- GROUP BY: Aggregating data.
- HAVING: Filtering grouped data.
- DISTINCT: Removing duplicates.

### 6. SQL Functions
- **Aggregate Functions**:
  - COUNT, SUM, AVG, MAX, MIN.
- **String Functions**:
  - CONCAT, SUBSTRING, LENGTH, UPPER, LOWER, TRIM.
- **Date Functions**:
  - NOW, DATEADD, DATEDIFF, DATE_FORMAT, EXTRACT.
- **Mathematical Functions**:
  - ROUND, CEIL, FLOOR, ABS, MOD.
- **Conditional Functions**:
  - CASE, COALESCE, NULLIF.

### 7. Joins
- INNER JOIN: Matching rows from both tables.
- LEFT JOIN (LEFT OUTER JOIN): All rows from the left table.
- RIGHT JOIN (RIGHT OUTER JOIN): All rows from the right table.
- FULL JOIN (FULL OUTER JOIN): All rows from both tables.
- CROSS JOIN: Cartesian product of two tables.
- Self Join: Joining a table with itself.

### 8. Subqueries
- Single-row subqueries.
- Multi-row subqueries.
- Correlated subqueries.
- Nested subqueries.

### 9. Advanced SQL Concepts
- **Indexes**:
  - Types (Clustered, Non-Clustered).
  - Creating and managing indexes.
- **Views**:
  - Creating, updating, and dropping views.
- **Stored Procedures**:
  - Writing and executing stored procedures.
- **Triggers**:
  - Creating and managing triggers.
- **Transactions**:
  - COMMIT, ROLLBACK, SAVEPOINT.
  - ACID properties.
- **Common Table Expressions (CTEs)**:
  - WITH clause and recursive CTEs.
- **Window Functions**:
  - ROW_NUMBER, RANK, DENSE_RANK, NTILE.
  - PARTITION BY, OVER clause.
  - LAG, LEAD, FIRST_VALUE, LAST_VALUE.

### 10. Query Optimization
- Writing efficient queries.
- Using EXPLAIN/ANALYZE to understand query execution plans.
- Avoiding common pitfalls (e.g., SELECT *, unnecessary joins).
- Indexing strategies for performance.

### 11. SQL Interview Questions
- **Beginner Level**:
  - Write a query to fetch all records from a table.
  - How to filter records based on multiple conditions?
- **Intermediate Level**:
  - Write a query to find duplicate records in a table.
  - How to calculate running totals using window functions?
- **Advanced Level**:
  - Write a query to find the second-highest salary.
  - How to pivot data in SQL without using PIVOT?

### 12. Database Design
- Normalization (1NF, 2NF, 3NF, BCNF).
- Denormalization for performance.
- Entity-Relationship (ER) diagrams.
- Handling many-to-many relationships.

### 13. SQL in Different DBMS
- Differences between MySQL, PostgreSQL, SQL Server, Oracle.
- DBMS-specific functions and features.
- Handling limits (e.g., TOP in SQL Server, LIMIT in MySQL/PostgreSQL).

### 14. Miscellaneous
- Handling NULL values.
- Pattern matching (LIKE, REGEXP).
- Set operations (UNION, UNION ALL, INTERSECT, EXCEPT).
- Temporary tables and table variables.
- Error handling in SQL.

## How to Use This Repository
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/sql-interview-questions.git
   ```
2. **Navigate to Folders**:
   - Each topic has its own folder (e.g., `basic-sql`, `joins`, `window-functions`).
   - Folders contain SQL scripts, example queries, and explanations.
3. **Practice Queries**:
   - Use the provided `.sql` files to run queries in your preferred DBMS (e.g., MySQL, PostgreSQL).
   - Example datasets are included for practice.
4. **Review Explanations**:
   - Read markdown files (`.md`) for detailed explanations of concepts and solutions.
5. **Solve Interview Questions**:
   - Check the `interview-questions` folder for categorized questions (beginner, intermediate, advanced).
   - Try solving them before checking the provided solutions.

## Contributing
Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Add or update SQL content (queries, explanations, questions).
4. Commit changes (`git commit -m "Add new content"`).
5. Push to your fork (`git push origin feature-branch`).
6. Open a pull request with a clear description of changes.

Please ensure:
- Queries are tested and work in at least one major DBMS.
- Explanations are clear and concise.
- No copyrighted content is included.

## Resources
- **Official Documentation**:
  - [MySQL Documentation](https://dev.mysql.com/doc/)
  - [PostgreSQL Documentation](https://www.postgresql.org/docs/)
  - [SQL Server Documentation](https://docs.microsoft.com/en-us/sql/)
  - [Oracle SQL Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/)
- **Online Practice Platforms**:
  - [LeetCode SQL](https://leetcode.com/problemset/database/)
  - [HackerRank SQL](https://www.hackerrank.com/domains/sql)
  - [SQLZoo](https://sqlzoo.net/)
- **Books**:
  - "SQL in 10 Minutes, Sams Teach Yourself" by Ben Forta.
  - "SQL Performance Explained" by Markus Winand.

## License
This repository is licensed under the [MIT License](LICENSE). Feel free to use, modify, and distribute the content for educational purposes.