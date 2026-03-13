--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO BOOKS(isbn,	book_title,	category, rental_price,	status,	author,	publisher)
Values('978-1-60129-456-2','To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')
SELECT * FROM Books;
				

--Task 2: Update an Existing Member's Address
SELECT * FROM members;

UPDATE members
SET member_address='152 Pine St'
WHERE member_id= 'C118';

--Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
SELECT * FROM issued_status

DELETE FROM issued_status
WHERE issued_id='IS121'

--Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id='E101';


--Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT * FROM issued_status
SELECT issued_emp_id, count(issued_id) FROM issued_status
Group by issued_emp_id
Having count(issued_id) >1


--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE TABLE bok_counts
AS
SELECT b.book_title, count(ist.issued_id) FROM books b
join
issued_status ist
on b.isbn=ist.issued_book_isbn
Group by b.book_title;


--4. Data Analysis & Findings
--The following SQL queries were used to address specific questions:

--Task 7. Retrieve All Books in a Specific Category:
SELECT * FROM BOOKS
WHERE category='Classic'

--Task 8: Find Total Rental Income by Category:


SELECT b.category, SUM(b.rental_price) FROM books b
join
issued_status ist
on b.isbn=ist.issued_book_isbn
Group by b.category
Order by b.category
s
--List Members Who Registered in the Last 180 Days:
SELECT * FROM members
Where reg_date=Current_Date - interval '180 days'; 

--List Employees with Their Branch Manager's Name and their branch details:
SELECT e.*,b.manager_id,e1.emp_name as manager FROM employees e
inner join 
branch b
on 
b.branch_id=e.branch_id
join employees e1
on 
b.manager_id=e1.emp_id

--Create a Table of Books with Rental Price Above a Certain Threshold:
Create table books_rental
AS
SELECT * FROM books
WHERE rental_price > 5

SELECT * FROM books_rental

--Retrieve the List of Books Not Yet Returned

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

--Advanced SQL Operations
Task 13: Identify Members with Overdue Books

Write a query to identify members who have overdue books 
(assume a 30-day return period). Display the member's_id, member's name,
book title, issue date, and days overdue.

--Join issued_status+members+books+return_status
--filter return_date = null
-- Overdue date is greater than 30

SELECT ist.issued_member_id, m.member_name, b.book_title, ist.issued_date, 
(Current_date - ist.issued_date) as over_due
FROM issued_status ist
Join 
members m
ON ist.issued_member_id = member_id
Join
books b
ON
ist.issued_book_isbn=b.isbn
Left join
return_status rs
ON 
ist.issued_id=rs.issued_id
WHERE rs.return_date is Null
	  And (current_date- issued_date)>30
ORDER BY 1; 

Task 14: Update Book Status on Return
Write a query to update the status of books in 
the books table to "Yes" when they are returned (based on entries in the return_status table).

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



Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
--each branch(branch)
-- number of books issued(issued_status), number of books returned(return_status), total revenue(books)
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


Task 16: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
--employees
--issued-Status
--branch
--LIMIT 3
--employee name, number of books issued, their branch

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
LIMIT 5


--Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 

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

Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.


--Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
--Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
--The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
--The procedure should first check if the book is available (status = 'yes'). 
--If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
--If the book is not available (status = 'no'), 
--the procedure should return an error message indicating that the book is currently not available.



--Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

--Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
--The table should include: The number of overdue books. 
--The total fines, with each day's fine calculated at $0.50. 
--The number of books issued by each member. 
--The resulting table should show: Member ID Number of overdue books Total fines

--books, issued_status, 
CREATE TABLE 
AS
SELECT * member_id,