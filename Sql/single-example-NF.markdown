# Database Normalization with Single Table Example and SQL Interview Questions

## Overview
This repository provides a detailed guide to **database normalization**, demonstrating how a single unnormalized table can be transformed through all normal forms (1NF, 2NF, 3NF, BCNF, 4NF, 5NF) with clear SQL examples and explanations. It also includes a comprehensive set of **SQL interview questions** with answers, covering key DBMS topics to aid in interview preparation. The content is designed for beginners to advanced learners seeking to master database design and SQL.

## Table of Contents
- [Purpose](#purpose)
- [Database Normalization with Single Table Example](#database-normalization-with-single-table-example)
  - [What is Normalization?](#what-is-normalization)
  - [Starting Unnormalized Table](#starting-unnormalized-table)
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
- Demonstrate database normalization using a single table example, progressing through all normal forms.
- Provide clear SQL code and explanations for each normalization step.
- Offer a comprehensive set of SQL interview questions with answers, covering DBMS concepts.
- Serve as a practical resource for database design and SQL interview preparation.

## Database Normalization with Single Table Example

### What is Normalization?
Normalization is the process of organizing data in a relational database to eliminate redundancy and anomalies (insertion, update, deletion) by decomposing tables into smaller, well-structured tables that adhere to normal forms. Each normal form addresses specific types of dependencies, ensuring data integrity and efficient storage.

### Starting Unnormalized Table
We begin with an unnormalized table representing a **school's course enrollment system**, which includes student, course, instructor, and hobby information. This table contains multiple issues, such as non-atomic values, partial dependencies, and multi-valued dependencies.

**Unnormalized Table**:
```sql
CREATE TABLE school_enrollment (
    student_id INT,
    student_name VARCHAR(50),
    courses VARCHAR(100), -- e.g., "Math,Physics"
    instructor_ids VARCHAR(50), -- e.g., "201,202"
    instructor_names VARCHAR(100), -- e.g., "Dr. Lee,Dr. Smith"
    department VARCHAR(50), -- e.g., "Science"
    hobbies VARCHAR(100) -- e.g., "Chess,Soccer"
);
INSERT INTO school_enrollment VALUES
(1, 'Alice', 'Math,Physics', '201,202', 'Dr. Lee,Dr. Smith', 'Science', 'Chess,Soccer'),
(2, 'Bob', 'Math', '201', 'Dr. Lee', 'Science', 'Soccer');
```
**Issues**:
- Non-atomic values (e.g., `courses`, `instructor_ids`, `hobbies`).
- Redundant data (e.g., `department` repeated for courses).
- Potential anomalies (e.g., updating `instructor_names` requires multiple changes).

### First Normal Form (1NF)
**Definition**: A table is in 1NF if:
- All attributes contain atomic (indivisible) values.
- There are no repeating groups or arrays.
- Each row is unique (typically via a primary key).

**Transformation**: Split non-atomic columns into separate rows, ensuring each value is indivisible. Add a composite primary key (`student_id`, `course`, `instructor_id`, `hobby`).

**1NF Table**:
```sql
CREATE TABLE school_enrollment_1nf (
    student_id INT,
    student_name VARCHAR(50),
    course VARCHAR(50),
    instructor_id INT,
    instructor_name VARCHAR(50),
    department VARCHAR(50),
    hobby VARCHAR(50),
    PRIMARY KEY (student_id, course, instructor_id, hobby)
);
INSERT INTO school_enrollment_1nf VALUES
(1, 'Alice', 'Math', 201, 'Dr. Lee', 'Science', 'Chess'),
(1, 'Alice', 'Math', 201, 'Dr. Lee', 'Science', 'Soccer'),
(1, 'Alice', 'Physics', 202, 'Dr. Smith', 'Science', 'Chess'),
(1, 'Alice', 'Physics', 202, 'Dr. Smith', 'Science', 'Soccer'),
(2, 'Bob', 'Math', 201, 'Dr. Lee', 'Science', 'Soccer');
```
**Explanation**: 
- `courses`, `instructor_ids`, `instructor_names`, and `hobbies` are split into atomic values.
- Each combination of student, course, instructor, and hobby forms a unique row.
- Achieves 1NF by ensuring atomicity and uniqueness.

### Second Normal Form (2NF)
**Definition**: A table is in 2NF if:
- It is in 1NF.
- All non-key attributes are fully functionally dependent on the entire primary key (no partial dependency).

**Issue in 1NF**: The primary key is (`student_id`, `course`, `instructor_id`, `hobby`), but:
- `student_name` depends only on `student_id`.
- `instructor_name` depends only on `instructor_id`.
- `department` depends only on `course`.

**Transformation**: Split the table into separate tables to remove partial dependencies.

**2NF Tables**:
```sql
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50)
);
CREATE TABLE instructors (
    instructor_id INT PRIMARY KEY,
    instructor_name VARCHAR(50)
);
CREATE TABLE courses (
    course VARCHAR(50) PRIMARY KEY,
    department VARCHAR(50)
);
CREATE TABLE enrollment_2nf (
    student_id INT,
    course VARCHAR(50),
    instructor_id INT,
    hobby VARCHAR(50),
    PRIMARY KEY (student_id, course, instructor_id, hobby),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id),
    FOREIGN KEY (course) REFERENCES courses(course)
);
INSERT INTO students VALUES
(1, 'Alice'),
(2, 'Bob');
INSERT INTO instructors VALUES
(201, 'Dr. Lee'),
(202, 'Dr. Smith');
INSERT INTO courses VALUES
('Math', 'Science'),
('Physics', 'Science');
INSERT INTO enrollment_2nf VALUES
(1, 'Math', 201, 'Chess'),
(1, 'Math', 201, 'Soccer'),
(1, 'Physics', 202, 'Chess'),
(1, 'Physics', 202, 'Soccer'),
(2, 'Math', 201, 'Soccer');
```
**Explanation**: 
- Non-key attributes (`student_name`, `instructor_name`, `department`) are moved to separate tables.
- `enrollment_2nf` retains relationships, ensuring full dependency on the primary key.
- Eliminates partial dependencies, achieving 2NF.

### Third Normal Form (3NF)
**Definition**: A table is in 3NF if:
- It is in 2NF.
- There are no transitive dependencies (non-key attributes do not depend on other non-key attributes).

**Issue in 2NF**: The `enrollment_2nf` table has no transitive dependencies, as `hobby` is part of the primary key. The other tables (`students`, `instructors`, `courses`) are already in 3NF, as they have no non-key attributes depending on other non-key attributes.

**Transformation**: No changes are needed, as the 2NF tables are already in 3NF. For clarity, we verify:
- `students`: `student_name` depends only on `student_id`.
- `instructors`: `instructor_name` depends only on `instructor_id`.
- `courses`: `department` depends only on `course`.
- `enrollment_2nf`: All attributes are part of the primary key or directly dependent.

**3NF Tables**: Same as 2NF tables (no changes required).

**Explanation**: The schema is already in 3NF, as there are no transitive dependencies.

### Boyce-Codd Normal Form (BCNF)
**Definition**: A table is in BCNF if:
- It is in 3NF.
- For every functional dependency (X → Y), X is a superkey.

**Issue in 3NF**: In `enrollment_2nf`, assume a functional dependency: `instructor_id → course` (e.g., each instructor teaches only one specific course). This violates BCNF because `instructor_id` is not a superkey.

**Transformation**: Split `enrollment_2nf` to address the dependency.

**BCNF Tables**:
```sql
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50)
);
CREATE TABLE instructors (
    instructor_id INT PRIMARY KEY,
    instructor_name VARCHAR(50)
);
CREATE TABLE courses (
    course VARCHAR(50) PRIMARY KEY,
    department VARCHAR(50)
);
CREATE TABLE instructor_courses (
    instructor_id INT,
    course VARCHAR(50),
    PRIMARY KEY (instructor_id),
    FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id),
    FOREIGN KEY (course) REFERENCES courses(course)
);
CREATE TABLE enrollment_bcnf (
    student_id INT,
    instructor_id INT,
    hobby VARCHAR(50),
    PRIMARY KEY (student_id, instructor_id, hobby),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (instructor_id) REFERENCES instructor_courses(instructor_id)
);
INSERT INTO students VALUES
(1, 'Alice'),
(2, 'Bob');
INSERT INTO instructors VALUES
(201, 'Dr. Lee'),
(202, 'Dr. Smith');
INSERT INTO courses VALUES
('Math', 'Science'),
('Physics', 'Science');
INSERT INTO instructor_courses VALUES
(201, 'Math'),
(202, 'Physics');
INSERT INTO enrollment_bcnf VALUES
(1, 201, 'Chess'),
(1, 201, 'Soccer'),
(1, 202, 'Chess'),
(1, 202, 'Soccer'),
(2, 201, 'Soccer');
```
**Explanation**:
- `instructor_courses` captures the dependency `instructor_id → course`.
- `enrollment_bcnf` links students, instructors, and hobbies, referencing `instructor_courses`.
- All functional dependencies now involve superkeys, achieving BCNF.

### Fourth Normal Form (4NF)
**Definition**: A table is in 4NF if:
- It is in BCNF.
- There are no non-trivial multi-valued dependencies.

**Issue in BCNF**: In `enrollment_bcnf`, `student_id` determines multiple independent values for `instructor_id` and `hobby` (a multi-valued dependency).

**Transformation**: Split `enrollment_bcnf` into separate tables for each independent relationship.

**4NF Tables**:
```sql
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50)
);
CREATE TABLE instructors (
    instructor_id INT PRIMARY KEY,
    instructor_name VARCHAR(50)
);
CREATE TABLE courses (
    course VARCHAR(50) PRIMARY KEY,
    department VARCHAR(50)
);
CREATE TABLE instructor_courses (
    instructor_id INT,
    course VARCHAR(50),
    PRIMARY KEY (instructor_id),
    FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id),
    FOREIGN KEY (course) REFERENCES courses(course)
);
CREATE TABLE student_instructors (
    student_id INT,
    instructor_id INT,
    PRIMARY KEY (student_id, instructor_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (instructor_id) REFERENCES instructor_courses(instructor_id)
);
CREATE TABLE student_hobbies (
    student_id INT,
    hobby VARCHAR(50),
    PRIMARY KEY (student_id, hobby),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);
INSERT INTO students VALUES
(1, 'Alice'),
(2, 'Bob');
INSERT INTO instructors VALUES
(201, 'Dr. Lee'),
(202, 'Dr. Smith');
INSERT INTO courses VALUES
('Math', 'Science'),
('Physics', 'Science');
INSERT INTO instructor_courses VALUES
(201, 'Math'),
(202, 'Physics');
INSERT INTO student_instructors VALUES
(1, 201),
(1, 202),
(2, 201);
INSERT INTO student_hobbies VALUES
(1, 'Chess'),
(1, 'Soccer'),
(2, 'Soccer');
```
**Explanation**:
- `student_instructors` captures the relationship between students and instructors.
- `student_hobbies` captures student hobbies independently.
- Eliminates multi-valued dependencies, achieving 4NF.

### Fifth Normal Form (5NF)
**Definition**: A table is in 5NF if:
- It is in 4NF.
- It cannot be decomposed into smaller tables without losing information (no non-trivial join dependencies).

**Issue in 4NF**: Suppose `student_instructors` has a join dependency: a student enrolls with an instructor only if the instructor teaches a course and the student is enrolled in that course. This suggests a relationship among `student_id`, `instructor_id`, and `course`.

**Transformation**: Decompose to eliminate the join dependency.

**5NF Tables**:
```sql
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50)
);
CREATE TABLE instructors (
    instructor_id INT PRIMARY KEY,
    instructor_name VARCHAR(50)
);
CREATE TABLE courses (
    course VARCHAR(50) PRIMARY KEY,
    department VARCHAR(50)
);
CREATE TABLE instructor_courses (
    instructor_id INT,
    course VARCHAR(50),
    PRIMARY KEY (instructor_id, course),
    FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id),
    FOREIGN KEY (course) REFERENCES courses(course)
);
CREATE TABLE student_courses (
    student_id INT,
    course VARCHAR(50),
    PRIMARY KEY (student_id, course),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course) REFERENCES courses(course)
);
CREATE TABLE student_hobbies (
    student_id INT,
    hobby VARCHAR(50),
    PRIMARY KEY (student_id, hobby),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);
INSERT INTO students VALUES
(1, 'Alice'),
(2, 'Bob');
INSERT INTO instructors VALUES
(201, 'Dr. Lee'),
(202, 'Dr. Smith');
INSERT INTO courses VALUES
('Math', 'Science'),
('Physics', 'Science');
INSERT INTO instructor_courses VALUES
(201, 'Math'),
(202, 'Physics');
INSERT INTO student_courses VALUES
(1, 'Math'),
(1, 'Physics'),
(2, 'Math');
INSERT INTO student_hobbies VALUES
(1, 'Chess'),
(1, 'Soccer'),
(2, 'Soccer');
```
**Explanation**:
- `student_courses` links students to courses.
- `instructor_courses` links instructors to courses.
- Joining these tables with `students` and `instructors` reconstructs the enrollment data without loss.
- Eliminates join dependencies, achieving 5NF.

## SQL Interview Questions and Answers
Below are SQL and DBMS interview questions, categorized by difficulty, with answers and example queries.

### Beginner-Level Questions

#### 1. What is a DBMS?
**Answer**: A DBMS is software for managing databases, ensuring data integrity, security, and querying capabilities.
**Example**: MySQL, PostgreSQL.

#### 2. What is the difference between DELETE and TRUNCATE?
**Answer**:
- **DELETE**: Removes specific rows (DML, rollback possible).
- **TRUNCATE**: Removes all rows (DDL, no rollback).
**Example**:
```sql
DELETE FROM students WHERE student_id = 1;
TRUNCATE TABLE students;
```

#### 3. What is a primary key?
**Answer**: A unique identifier for each record, ensuring no NULLs or duplicates.
**Example**:
```sql
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(50)
);
```

#### 4. How do you retrieve unique records?
**Answer**: Use DISTINCT to eliminate duplicates.
**Example**:
```sql
SELECT DISTINCT department
FROM courses;
```

#### 5. What are aggregate functions?
**Answer**: Functions like COUNT, SUM, AVG perform calculations on rows.
**Example**:
```sql
SELECT COUNT(*) as student_count
FROM students;
```

### Intermediate-Level Questions

#### 6. What are the types of JOINs?
**Answer**: INNER, LEFT, RIGHT, FULL, CROSS.
**Example**:
```sql
SELECT s.student_name, c.course
FROM students s
INNER JOIN student_courses sc ON s.student_id = sc.student_id
INNER JOIN courses c ON sc.course = c.course;
```

#### 7. What is a subquery?
**Answer**: A query nested within another query.
**Example**:
```sql
SELECT student_name
FROM students
WHERE student_id IN (SELECT student_id FROM student_courses WHERE course = 'Math');
```

#### 8. What is an index?
**Answer**: Speeds up data retrieval but slows updates.
**Example**:
```sql
CREATE INDEX idx_student_name ON students(student_name);
```

#### 9. What is a view?
**Answer**: A virtual table based on a query.
**Example**:
```sql
CREATE VIEW math_students AS
SELECT s.student_name, sc.course
FROM students s
JOIN student_courses sc ON s.student_id = sc.student_id
WHERE sc.course = 'Math';
```

#### 10. What is a transaction?
**Answer**: A sequence of operations following ACID properties.
**Example**:
```sql
START TRANSACTION;
INSERT INTO students VALUES (3, 'Charlie');
COMMIT;
```

### Advanced-Level Questions

#### 11. What is a correlated subquery?
**Answer**: Depends on the outer query, executed per row.
**Example**:
```sql
SELECT student_name
FROM students s
WHERE EXISTS (
    SELECT 1
    FROM student_courses sc
    WHERE sc.student_id = s.student_id AND sc.course = 'Math'
);
```

#### 12. What are window functions?
**Answer**: Perform calculations across rows without collapsing them.
**Example**:
```sql
SELECT student_name,
       ROW_NUMBER() OVER (ORDER BY student_id) as rank
FROM students;
```

#### 13. How do you optimize a query?
**Answer**: Use indexes, avoid SELECT *, analyze with EXPLAIN.
**Example**:
```sql
EXPLAIN SELECT student_name
FROM students
WHERE student_id = 1;
```

#### 14. What is a recursive CTE?
**Answer**: Queries hierarchical data by referencing itself.
**Example**:
```sql
WITH RECURSIVE course_prerequisites AS (
    SELECT course, prerequisite
    FROM course_dependencies
    WHERE prerequisite IS NULL
    UNION ALL
    SELECT cd.course, cd.prerequisite
    FROM course_dependencies cd
    JOIN course_prerequisites cp ON cd.prerequisite = cp.course
)
SELECT course
FROM course_prerequisites;
```

#### 15. What is MVCC?
**Answer**: Multi-Version Concurrency Control manages concurrent transactions.
**Example**: PostgreSQL uses MVCC for snapshot isolation.

## How to Use This Repository
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/normalization-single-table.git
   ```
2. **Explore Normalization**:
   - `normalization` folder: `.sql` files for each normal form.
   - Markdown files provide step-by-step explanations.
3. **Practice Questions**:
   - `interview-questions` folder: Categorized questions and solutions.
   - Use `datasets` folder for sample data.
4. **Run Queries**:
   - Execute `.sql` files in your DBMS (e.g., MySQL, PostgreSQL).
   - Test with provided datasets.
5. **Review Explanations**:
   - Read `.md` files for insights.

## Contributing
Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a branch (`git checkout -b add-example`).
3. Add content (normalization steps, questions).
4. Commit changes (`git commit -m "Add 5NF example"`).
5. Push to your fork (`git push origin add-example`).
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
  - "SQL Performance Explained" by Winand.

## License
This repository is licensed under the [MIT License](LICENSE). Use, modify, and share for educational purposes.