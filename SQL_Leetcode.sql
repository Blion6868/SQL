--Employees who make more than manager
SELECT name AS Employee
FROM Employee e
WHERE salary > (SELECT salary FROM Employee WHERE id=e.managerId);

--Customers who never ordered
SELECT name AS Customers
FROM Customers 
WHERE ID NOT IN
(SELECT customerID FROM Orders)

--Write a solution to find all dates' IDs with higher temperatures compared to its previous dates (yesterday)
SELECT w1.id
FROM Weather w1, Weather w2
WHERE DATEDIFF(w1.recordDate, w2.recordDate) = 1 AND w1.temperature > w2.temperature

--Player with min first_login
SELECT player_id, min(event_date) as first_login
FROM Activity
GROUP BY player_id;

--Write a solution to find id, movie, desc, and rating for movies with odd ids and not boring
SELECT id, movie, description, rating
FROM Cinema
WHERE mod(id, 2) <> 0 AND description != "boring"
GROUP BY movie
ORDER BY rating DESC

--Write a solution to find the average selling price for each product. average_price should be rounded to 2 decimal places
SELECT p.product_id, ifnull(round(sum(price*units)/sum(units),2),0) AS average_price 
FROM prices p 
LEFT JOIN unitssold u 
ON p.product_id=u.product_id 
AND u.purchase_date between 
p.start_date AND p.end_date 
GROUP BY product_id;

--Write a solution to find the rank of the scores
SELECT score, dense_rank() OVER(ORDER BY score DESC) AS "rank"
FROM Scores

--Write a solution to find the number of times each student attended each exam. Return the result table ordered by student_id and subject_name. The result format is in the following example
SELECT s.student_id, s.student_name, sub.subject_name, COUNT(e.student_id) as attended_exams
FROM Students s
CROSS JOIN Subjects sub
LEFT JOIN Examinations e ON s.student_id = e.student_id
AND sub.subject_name = e.subject_name
GROUP BY s.student_id, s.student_name, sub.subject_name
ORDER BY s.student_id, sub.subject_name

--Write an SQL query to find for each month and country, the number of transactions and their total amount, the number of approved transactions and their total amount
SELECT
date_format(trans_date, '%Y-%m') AS month, 
country, 
count(id) AS trans_count, 
sum(case when state = 'approved' then 1 else 0 end) AS approved_count, 
sum(amount) AS trans_total_amount, 
sum(case when state = 'approved' then amount else 0 end) AS approved_total_amount
FROM transactions
GROUP BY 
date_format(trans_date, '%Y-%m'), country;

--Write a solution to find the percentage of immediate orders in the first orders of all customers, rounded to 2 decimal places
SELECT round(avg(order_date = customer_pref_delivery_date)*100, 2) AS immediate_percentage
FROM Delivery
WHERE (customer_id, order_date) IN (SELECT customer_id, min(order_date) 
FROM Delivery
GROUP BY customer_id
);


--Write a solution to report the IDs of all the employees with missing information. The information of an employee is missing if
--Return the result table ordered by employee_id in ascending order
SELECT employee_id 
FROM Employees
WHERE employee_id NOT IN (SELECT employee_id FROM Salaries)
UNION
SELECT employee_id
FROM Salaries 
WHERE employee_id NOT IN (SELECT employee_id FROM Employees)
ORDER BY employee_id;

--The cancellation rate is computed by dividing the number of canceled (by client or driver) requests with unbanned users by the total number of requests with unbanned users on that day. Write a solution to find the cancellation rate of requests with unbanned users (both client and driver must not be banned) each day between "2013-10-01" and "2013-10-03". Round Cancellation Rate to two decimal points
SELECT request_at day
        ,round(sum(case when status = 'cancelled_by_driver' OR status = 'cancelled_by_client' then 1 else 0 END)
         / (count(id) * 1.00),2) 'Cancellation Rate'
  FROM Trips t 
 WHERE request_at between '2013-10-01' and '2013-10-03'
   AND client_id IN (SELECT users_id FROM Users WHERE banned = 'No')
   AND driver_id IN  (SELECT users_id  FROM Users WHERE banned = 'No')
GROUP BY request_at;

--Write a solution to report the products that were only sold in the first quarter of 2019. That is, between 2019-01-01 and 2019-03-31 inclusive
SELECT product_id, product_name 
FROM product
WHERE product_id IN 
    (SELECT DISTINCT product_id 
     FROM sales
     GROUP BY product_id 
     HAVING MIN(sale_date)>= '2019-01-01' 
     AND  MAX(sale_date) <= '2019-03-31')


