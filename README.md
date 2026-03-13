
## Library Management System – SQL Project

## Project Overview

This project demonstrates the use of SQL for managing and analyzing a Library Management System database. It includes operations for managing books, members, employees, book issuance, and returns. The project also performs data analysis, reporting, and automation using stored procedures.

The main objective of this project is to apply SQL concepts such as CRUD operations, joins, aggregations, stored procedures, and reporting queries to simulate real-world library operations.


## Project Structure

### 1. Database Setup

- **Database Creation**: Created a database named `library_management_system_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(20),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(6) PRIMARY KEY,
            emp_name VARCHAR(20),
            position VARCHAR(10),
            salary DECIMAL(10,2),
            branch_id VARCHAR(5),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(15),
            member_address VARCHAR(20),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(25) PRIMARY KEY,
            book_title VARCHAR(60),
            category VARCHAR(20),
            rental_price DECIMAL(10,2),
            status VARCHAR(5),
            author VARCHAR(30),
            publisher VARCHAR(40)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(10),
            issued_book_name VARCHAR(85),
            issued_date DATE,
            issued_book_isbn VARCHAR(25),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(10),
            return_book_name VARCHAR(65),
            return_date DATE,
            return_book_isbn VARCHAR(20),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

```
The data is uploaded to the columns. 

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```
**Task 2: Update an Existing Member's Address**

```sql
SELECT * FROM members;

UPDATE members
SET member_address='152 Pine St'
WHERE member_id= 'C118';

```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
SELECT * FROM issued_status

DELETE FROM issued_status
WHERE issued_id='IS121'
```

```

**Task 4: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_count 
AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status as ist
JOIN 
	books as b
ON 
	ist.issued_book_isbn = b.isbn
GROUP BY 
	b.isbn, b.book_title;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 1. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

 **Task 2: Find Total Rental Income by Category**:

```sql
SELECT b.category, SUM(b.rental_price) FROM books b
join
issued_status ist
on 
	b.isbn=ist.issued_book_isbn
Group by b.category
Order by b.category
```

 **Task 3: List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT e.*,b.manager_id,e1.emp_name as manager 
FROM 
	employees e
inner join 
	branch b
on 
	b.branch_id=e.branch_id
join 
	employees e1
on 
	b.manager_id=e1.emp_id

```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
Create table books_rental
AS
SELECT * 
FROM books
WHERE rental_price > 5
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT * FRom issued_status

SELECT * FROM return_status

ALTER TABLE return_status
DROP CONSTRAINT fk_return_books;

SELECT * FROM issued_status ist
Left join
return_status rs
on 
ist.issued_id=rs.issued_id
where rs.return_id IS NULL
```

## Advanced SQL Operations

**Task 1: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT ist.issued_member_id, m.member_name, b.book_title, ist.issued_date, 
(Current_date - ist.issued_date) as over_due
FROM 
	issued_status ist
Join 
	members m
ON 
	ist.issued_member_id = member_id
Join
	books b
ON
	ist.issued_book_isbn=b.isbn
Left join
	return_status rs
ON 
	ist.issued_id=rs.issued_id
WHERE 
	rs.return_date is Null
	  And (current_date- issued_date)>30
ORDER BY 1; 
```


**Task 2: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

ALTER TABLE Books
ALTER COLUMN isbn TYPE VARCHAR(25);

-- Sotred Procedures
SELECT * from return_status
SELECT * FROM books
WHERE book_title= 'Animal Farm'
SELECT * FROM issued_status

DROP PROCEDURE add_return_records
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id varchar(10), p_issued_id Varchar(10))
LANGUAGE plpgsql -- programming language pgsql
AS $$

DECLARE
v_isbn varchar(25);

BEGIN
INSERT INTO return_status(return_id,issued_id, return_date)
Values
(p_return_id, p_issued_id, CURRENT_DATE); 

SELECT issued_book_isbn
 INTO v_isbn
 FROM issued_status
 Where issued_id=p_issued_id;

Update books
SET status= 'yes'
Where isbn=v_isbn;

END;
$$

CALL add_return_records('RS140','IS140');


```

**Task 3: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
SELECT * FROM branch -- branch id
SELECT * FROM issued_status --emp_id, issued_id,isbn
SELECT * FROM return_status --issued_id
SELECT * FROM books --isbn
SELECT * FROM employees --(emp_id, branch_id)

DROP TABLE revenue_total

CREATE TABLE revenue_total
AS
SELECT br.branch_id, br.manager_id, COUNT(ist.issued_id) AS number_of_books_issued,
		COUNT(rs.return_id) AS number_of_books_returned,
		SUM(bk.rental_price)

FROM issued_status ist
JOIN
	employees e
ON
	 e.emp_id =ist.issued_emp_id
JOIN
	branch br
ON
	e.branch_id = br.branch_id
JOIN 
	books bk
ON
	ist.issued_book_isbn = bk.isbn
LEFT JOIN
	return_status rs
ON 
	ist.issued_id = rs.issued_id

GROUP BY 1,2;

SELECT * FROM revenue_total;
```


**Task 4: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT * FROM employees
SELECT * FROM issued_status
SELECT * FROM branch

SELECT e.emp_name, count(ist.issued_id) as number_of_books_issued,br.branch_id
FROM issued_status ist
JOIN
employees e
ON ist.issued_emp_id = e.emp_id
JOIN
branch br
ON e.branch_id = br.branch_id
GROUP BY 1,3
Order by count(ist.issued_id)DESC
LIMIT 3
```

**Task 5: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

SELECT * FROM books
SELECT * FROM issued_status

CREATE OR REPLACE PROCEDURE books_issued(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(10), p_issued_book_isbn VARCHAR(25),p_issued_emp_id VARCHAR(10))
Language plpgsql
AS $$

DECLARE
-- all the variable
	v_status VARCHAR(10);

BEGIN

--all codes
--check if book is available

SELECT status 
	INTO 
	v_status
FROM books
WHERE isbn = p_issued_book_isbn;

IF 
v_status = 'yes' THEN
INSERT INTO issued_status (issued_id, issued_member_id,issued_date, issued_book_isbn, issued_emp_id)

Values(p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

Update books
SET status= 'no'
Where isbn=p_issued_book_isbn;

RAISE NOTICE 'book records added successfully';

ELSE
RAISE NOTICE 'The book is currently unavailable';

END IF;

END;
$$

SELECT * FROM books
SELECT * FROM issued_status

CALL books_issued('IS160', 'C108', '978-0-375-41398-8', 'E104');

```



## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project showcases the use of SQL to design and manage a Library Management System. It covers database creation, data manipulation, and advanced querying techniques, providing practical experience in data management, analysis, and reporting.

** Author: Betcy Karukamalil Joy**
