-- libraray management system
Create table books(
					isbn Varchar(20) primary key,	
					book_title Varchar(60),	
					category Varchar(20),
					rental_price Float,	
					status varchar(5),	
					author varchar(20),	
					publisher Varchar(30)
				)
Alter table books
alter column author type varchar(40);
create table branch(
					branch_id varchar(10) Primary key NOT NULL,	
					manager_id varchar(10),	
					branch_address varchar(20),	
					contact_no varchar(10)
					)

create table employees(
						emp_id varchar(6) primary key,	
						emp_name varchar (20),	
						position varchar(10),
						salary int,	
						branch_id varchar(5)
					)
DROP table IF exists members;
Create table members(
					member_id varchar(10) primary key,	
					member_name varchar(15),	
					member_address varchar(20),	
					reg_date DATE
					)							
create table return_status(
						return_id varchar(10) Primary key,	
						issued_id varchar(10),	
						return_book_name (65),	
						return_date DATE,	
						return_book_isbn varchar(20)
						);		
DROP table IF exists issued_status;
Create table issued_status(
							issued_id Varchar(10) Primary Key,
							issued_member_id varchar(10),	
							issued_book_name Varchar(65),	
							issued_date DATE,	
							issued_book_isbn varchar(20),	
							issued_emp_id varchar(10)
							)
Alter table issued_status
alter column issued_book_isbn Type varchar(25);
alter table issued_status
alter column issued_book_name type varchar(85);
-- Foreign key
alter table employees
Add constraint fk_branch
foreign key (branch_id)
References branch(branch_id);

alter table return_status
Add constraint fk_issued_status
foreign key (issued_id)
References issued_status(issued_id);

alter table return_status
Add constraint fk_return_books
foreign key (return_book_isbn)
References books(isbn);

alter table return_status
Add constraint fk_issued_status
foreign key (issued_id)
References issued_status(issued_id);

alter table issued_status
Add constraint fk_books
foreign key (issued_book_isbn)
References books(isbn);

alter table issued_status
Add constraint fk_members
foreign key (issued_member_id)
References members(member_id);

alter table issued_status
Add constraint fk_employees
foreign key (issued_emp_id)
References employees(emp_id);

