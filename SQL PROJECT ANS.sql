create database Assignment;
use Assignment;

create table sales (customer_id varchar(1), order_date date, product_id tinyint);

create table menu (product_id tinyint, product_name Varchar(20), price tinyint);

create table members (customer_id varchar(1), join_date date);

insert into sales (customer_id, order_date, product_id) values('A', '2021-01-01', '1'),('A', '2021-01-01', '2'),
('A', '2021-01-07', '2'),('A', '2021-01-10', '3'),('A', '2021-01-11', '3'),('A', '2021-01-11', '3'),('B', '2021-01-01', '2'),
('B', '2021-01-02', '2'),('B', '2021-01-04', '1'),('B', '2021-01-11', '1'),('B', '2021-01-16', '3'),('B', '2021-02-01', '3'),
('C', '2021-01-01', '3'),('C', '2021-01-07', '3');

insert into menu (product_id, product_name, price) values('1', 'sushi', '10'),('2', 'curry', '15'),('3', 'ramen', '12');

insert into members (customer_id, join_date) values('A', '2021-01-07'),('B', '2021-01-09');

-- 1. What is the total amount each customer spent at the restaurant? 
select s.customer_id, sum(price) from sales s
join menu m on s.product_id = m.product_id
group by s.customer_id;

 -- 2. How many days has each customer visited the restaurant? 
select customer_id, count(distinct order_date) as visited_days
from sales 
group by customer_id;

 -- 3. What was the first item from the menu purchased by each customer?
select s.customer_id, min(s.order_date), min(m.product_name) As first_purchased_menu from sales s
join menu m on s.product_id = m.product_id
group by s.customer_id;

 -- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select m.product_name, count(*) as total_purchase from sales s
join menu m on s.product_id = m.product_id
group by m.product_name ORDER BY total_purchase DESC LIMIT 1;

 --  5. Which item was the most popular for each customer?
select m.product_name, s.customer_id, max(s.product_id) from sales s 
join menu m on s.product_id = m.product_id
group by m.product_name, s.customer_id
order by max(s.product_id) desc limit 3;
 
  -- 6. Which item was purchased first by the customer after they became a member?
select s.customer_id, m1.product_name, s.order_date, m2.join_date from sales s 
join menu m1 on s.product_id = m1.product_id
join members m2 on s.customer_id = m2.customer_id
where s.order_date >= m2.join_date order by s.customer_id limit 1;

 -- 7. Which item was purchased just before the customer became a member?
select s.customer_id, m1.product_name, s.order_date, m2.join_date from sales s 
join menu m1 on s.product_id = m1.product_id
join members m2 on s.customer_id = m2.customer_id
where s.order_date < m2.join_date order by s.customer_id limit 1;

 -- 8. What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, count(s.product_id) AS total_items, SUM(m1.price) AS money_spent
FROM sales AS s
JOIN menu AS m1 ON m1.product_id = s.product_id
JOIN members AS m2 ON s.customer_id = m2.customer_id
WHERE s.order_date < m2.join_date
GROUP BY s.customer_id;

 -- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select s.customer_id, sum(case when m.product_name = 'sushi' then price * 20 else price * 10 end) as total_points
from sales s 
join menu m on s.product_id = m.product_id
group by s.customer_id;

-- 10. In the first week after a customer joins the program (including
-- their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT customer_id, SUM(total_points)
FROM (WITH points AS
(SELECT s.customer_id, (s.order_date - m2.join_date) AS first_week, m1.price, m1.product_name, s.order_date
FROM sales s
JOIN menu m1 ON s.product_id = m1.product_id
JOIN members AS m2 ON m2.customer_id = s.customer_id)
SELECT customer_id, CASE WHEN first_week BETWEEN 0 AND 7 THEN price * 20
WHEN (first_week > 7 OR first_week < 0) AND product_name = 'sushi' THEN price * 20 END AS total_points, order_date
FROM points
WHERE EXTRACT(MONTH FROM order_date) = 1) as t
GROUP BY customer_id;


