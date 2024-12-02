-- Data Analysis of Library Management System-------------------------------

-- step 1: Data import and cleaning---------------------------------
-- import data from Excel csv files and clean data for analysis-------------
-- identify the primary keys of each of the tables--------------------------
-- add foreign key constraints to the data----------------------------------

alter table issued_status
add constraint fk_members
foreign key (issued_member_id)
references members(member_id);

alter table issued_status
add constraint fk_books
foreign key (issued_book_isbn)
references books(isbn);

alter table issued_status
add constraint fk_employees
foreign key (issued_emp_id)
references employees(emp_id);

alter table employees
add constraint fk_branch
foreign key (branch_id)
references branch(branch_id);

-- step 2: Data Analysis of Library Management System ----------------------------
-- Q1. Update Alice Johnson's address to 345 Melton Street
update members
set member_address =  '345 Melton Street'
where member_id = 'C101';
select * from members;

-- Q2. Delete the record with member_id 'C119'
delete from members
where member_id = 'C119';
select * from  members;

-- Q3. Select all books issued by emp_id 'E101'
select issued_book_name from issued_status
where issued_emp_id = 'E101';

-- Q4. find employees who have more than 3 books issued... use group by function
select ist.issued_emp_id, e.emp_name, count(*) as total_issued
from issued_status ist
join employees e
on ist.issued_emp_id = e.emp_id
group by issued_emp_id
having total_issued >3
order by 3 desc;

-- Q5. create summary tables; use ctas to generate new tables based on query results; each book and total_books_issued_
create table  no_of_books_issued as (
select 
b.isbn,
b.book_title,
count(ist.issued_id) as no_issued
from books as b
join
issued_status as ist
on b.isbn = ist.issued_book_isbn
group by 1
order by no_issued desc);
select * from no_of_books_issued;

-- Q6. Retrieve All Books in a Specific Category: Classic, Fiction, etc
select * from books
where category = 'Children';

-- Q7. Find Total Rental Income by Category as wekk as the number of times books were issued under each category:
select 
b.category,
sum(b.rental_price) as total_rental_price,
count(*) as no_of_times_issued
from books as b
join issued_status as ist
on ist.issued_book_isbn = b.isbn
group by 1;

-- Q8. List Members Who Registered in the Last 180 Days:
SELECT *
FROM members
WHERE reg_date >= CURDATE() - INTERVAL 180 DAY;

-- Q9. List Employees with Their details and their Branch Manager's Name : 
select e1.*,
e2.emp_name as manager
from employees e1
join branch b
	on e1.branch_id = b.branch_id
join employees e2
	on e2.emp_id = b.manager_id;

-- Q10. Create a Table of Books with Rental Price Above $7.0
create table rental_above_7 as 
select * from books
where rental_price > 7;
select * from rental_above_7;

-- Q11. Retrieve the List of Books Not Yet Returned
select distinct ist.issued_book_name
from issued_status as ist
left join return_status as rs
on ist.issued_id = rs.issued_id
where rs.return_id is null;

-- Q12. Identify Members with Overdue Books. 
-- Write a query to identify members who have overdue books
-- Display the member's_id, member's name, book title, issue date, and days overdue of over 2 months,ie 60 days.(use current date as 2024-06-01)
select m.member_id,
m.member_name,
b.book_title,
ist.issued_date,
datediff('2024-06-01', ist.issued_date) as days_overdue
from members m
join issued_status ist
on m.member_id = ist.issued_member_id
join books b
on b.isbn = ist.issued_book_isbn
left join return_status rs
on rs.issued_id = ist.issued_id
where return_date is null
and datediff('2024-06-01', ist.issued_date) > 60
order by 5;

-- Q13: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued,
-- the number of books returned, and the total revenue generated from book rentals.
create table branch_report 
as 
select 
br.branch_id,
count(ist.issued_id) as total_issued,
count(rs.return_id) as total_returned,
sum(b.rental_price) as total_revenue
from books b
join issued_status ist
on b.isbn= ist.issued_book_isbn
join employees e
on e.emp_id= ist.issued_emp_id
join branch br
on br.branch_id = e.branch_id
left join return_status rs
on rs.issued_id = ist.issued_id
group by br.branch_id
order by 1;
select * from branch_report;

-- Q14: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
-- containing members who have issued at least one book in the last 110 days(use '2024-06-01' as current date)
create table active_members as 
select * from members
where member_id
in (select distinct issued_member_id 
		from issued_status 
		where issued_date >= '2024-06-01' - interval 110 day);
select * from active_members;

-- Q15: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. 
-- Display the employee name, number of books processed, and their branch.
select
e.emp_name,
b.branch_address,
count(ist.issued_book_name) as total_processed
from employees e
join issued_status ist
on ist.issued_emp_id = e.emp_id
join branch b
on b.branch_id = e.branch_id
group by 1,2
order by 3 desc
limit 3;

-- Q16: Write a query to identify members who have issued books more than once
-- Display the member name, book title, and the number of times they've issued books.
select 
m.member_name,
b.book_title,
count(ist.issued_member_id)  as total_issued
from members m
join issued_status ist
on m.member_id = ist.issued_member_id
join books b 
on b.isbn = ist.issued_book_isbn
group by 1,2
having count(ist.issued_member_id) > 1;

-- Q17. write a query to find the employees and their positions earning from 55000 and above and also show their managers.
select e1.*, e2.emp_name as manager
from employees e1
join branch brr
on brr.branch_id = e1.branch_id
join employees e2
on e2.emp_id = brr.manager_id
group by e1.emp_id
having salary >= 55000
order by salary desc;

-- Q19. write a query to find out the top 3 categories that have the lowest price ?
select category, sum(rental_price) as total_price_per_category
from books
group by category
order by sum(rental_price) 
limit 3;

-- Q20. what is the category and return status of the following books: 'Where the Wild Things Are', 'Sapiens: A Brief History of Humankind',
-- 'Dune', and '1491: New Revelations of the Americas Before Columbus'
select book_title, category, status as Returned
from books
where book_title = 'Where the Wild Things Are'
	or book_title = 'Sapiens: A Brief History of Humankind' 
	or book_title = 'Dune'
	or book_title =  '1491: New Revelations of the Americas Before Columbus';
    
-- Q21. The number of books issued to each member. 
; select m.member_name,
 count(issued_date) as no_issued
 from members m
 join issued_status ist
 on ist.issued_member_id = m.member_id
 group by m.member_name;
 
-- Q22. Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 60 days(Use 2024-06-01 as current date)
-- The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50.
create table members_days_with_books as
select m.member_id,
m.member_name,
ist.issued_book_name,
ist.issued_date,
datediff('2024-06-01', ist.issued_date) as days_with_books
from members m 
join issued_status ist
on ist.issued_member_id = m.member_id
group by m.member_id,
m.member_name,
ist.issued_book_name,
ist.issued_date
having datediff('2024-06-01', ist.issued_date) > 60;
select * from members_days_with_books;
create table fine_for_late_return as 
 select *,
(days_with_books - 60) as days_overdue,
((days_with_books - 60) * 0.50) as  fine
from
members_days_with_books
order by 6 desc;
select * from fine_for_late_return;

