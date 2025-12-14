CREATE DATABASE customer_behavior;
USE customer_behavior;
CREATE TABLE product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price INT
);
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    signup_date DATE
);
CREATE TABLE user_name (
    user_id INT,
    user_name VARCHAR(100),
    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
CREATE TABLE goldusers_signup (
    user_id INT,
    gold_signup_date DATE,
    PRIMARY KEY (user_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
CREATE TABLE sales (
    user_id INT,
    product_id INT,
    created_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id)
);

INSERT INTO users (user_id, signup_date) VALUES
(1, '2014-09-02'),
(2, '2015-01-15'),
(3, '2014-04-11'),
(4, '2016-02-03'),
(5, '2017-01-08'),
(6, '2015-08-10'),
(7, '2016-05-12'),
(8, '2016-05-12'),
(9, '2014-09-02'),
(10,'2014-09-02');
INSERT INTO user_name (user_id, user_name) VALUES
(1, 'Ramesh'),
(2, 'Suresh'),
(3, 'Mahesh'),
(4, 'Naresh'),
(5, 'Rajesh'),
(6, 'Ganesh'),
(7, 'Lokesh'),
(8, 'Mukesh'),
(9, 'Dinesh'),
(10,'Hitesh');

INSERT INTO product (product_id, product_name, price) VALUES
(1, 'Dal Makhani', 150),
(2, 'Butter Chicken', 340),
(3, 'Paneer Butter Masala', 280),
(4, 'Chicken Biryani', 250),
(5, 'Mutton Biryani', 450),
(6, 'Fish Curry', 300),
(7, 'Veg Thali', 180),
(8, 'Chicken Thali', 220),
(9, 'Chole Bhature', 120),
(10,'Masala Dosa', 100),
(11,'Mango Lassi', 80);

INSERT INTO goldusers_signup (user_id, gold_signup_date) VALUES
(1, '2017-09-22'),
(3, '2017-04-21'),
(5, '2018-01-15'),
(7, '2019-06-01'),
(9, '2018-10-12');
INSERT INTO sales (user_id, product_id, created_date) VALUES
(1,2,'2017-01-01'),
(1,3,'2017-01-05'),
(1,2,'2017-01-10'),
(2,1,'2016-02-12'),
(2,4,'2016-03-15'),
(3,2,'2017-04-01'),
(3,5,'2017-04-12'),
(3,2,'2017-04-25'),
(4,6,'2016-06-10'),
(4,7,'2016-06-15'),
(5,5,'2018-02-10'),
(5,2,'2018-02-14'),
(6,9,'2016-08-20'),
(6,10,'2016-09-01'),
(7,3,'2019-06-10'),
(7,3,'2019-06-15'),
(8,11,'2016-07-01'),
(9,1,'2018-11-01'),
(9,2,'2018-11-10'),
(10,8,'2015-10-20');

SELECT * FROM users;
SELECT * FROM user_name;
SELECT * FROM product;
SELECT * FROM goldusers_signup;
SELECT * FROM sales;

SELECT p.product_name,
       SUM(p.price) AS total_revenue
FROM sales s
JOIN product p ON s.product_id = p.product_id
GROUP BY p.product_name;
SELECT p.product_name,
       SUM(p.price) AS revenue
FROM sales s
JOIN product p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 3;

SELECT COUNT(DISTINCT user_id) AS gold_users
FROM goldusers_signup;

SELECT s.user_id,
       SUM(p.price) AS revenue
FROM sales s
JOIN product p ON s.product_id = p.product_id
JOIN goldusers_signup g ON s.user_id = g.user_id
GROUP BY s.user_id;

SELECT SUM(p.price) AS total_gold_revenue
FROM sales s
JOIN product p ON s.product_id = p.product_id
JOIN goldusers_signup g ON s.user_id = g.user_id;

SELECT g.user_id,
       DATEDIFF(CURDATE(), g.gold_signup_date) AS days_as_gold
FROM goldusers_signup g;

SELECT p.product_name,
       COUNT(*) AS order_count
FROM sales s
JOIN product p ON s.product_id = p.product_id
JOIN goldusers_signup g ON s.user_id = g.user_id
GROUP BY p.product_name
ORDER BY order_count DESC
LIMIT 1;

SELECT YEAR(s.created_date) AS year,
       SUM(p.price) AS revenue
FROM sales s
JOIN product p ON s.product_id = p.product_id
GROUP BY YEAR(s.created_date);

SELECT YEAR(s.created_date) AS year,
       SUM(p.price) AS revenue
FROM sales s
JOIN product p ON s.product_id = p.product_id
GROUP BY year
ORDER BY year;


SELECT 
(SELECT COUNT(*) FROM goldusers_signup) * 100.0 /
(SELECT COUNT(*) FROM users) AS gold_signup_percentage;

SELECT s.user_id,
       COUNT(*) AS total_orders
FROM sales s
JOIN goldusers_signup g ON s.user_id = g.user_id
GROUP BY s.user_id;

SELECT s.user_id,
       SUM(p.price) AS total_spent
FROM sales s
JOIN product p ON s.product_id = p.product_id
GROUP BY s.user_id;

SELECT user_id,
       COUNT(*) AS visit_count
FROM sales
GROUP BY user_id;

SELECT s.user_id,
       p.product_name,
       s.created_date
FROM sales s
JOIN product p ON s.product_id = p.product_id
WHERE (s.user_id, s.created_date) IN (
  SELECT user_id, MIN(created_date)
  FROM sales
  GROUP BY user_id
);

SELECT p.product_name,
       COUNT(*) AS total_orders
FROM sales s
JOIN product p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_orders DESC
LIMIT 1;

SELECT user_id, product_name
FROM (
  SELECT s.user_id,
         p.product_name,
         COUNT(*) AS cnt,
         RANK() OVER(PARTITION BY s.user_id ORDER BY COUNT(*) DESC) rnk
  FROM sales s
  JOIN product p ON s.product_id = p.product_id
  GROUP BY s.user_id, p.product_name
) t
WHERE rnk = 1;

SELECT s.user_id,
       p.product_name
FROM sales s
JOIN goldusers_signup g ON s.user_id = g.user_id
JOIN product p ON s.product_id = p.product_id
WHERE s.created_date >= g.gold_signup_date
AND s.created_date = (
   SELECT MIN(created_date)
   FROM sales
   WHERE user_id = s.user_id
   AND created_date >= g.gold_signup_date
);

SELECT s.user_id,
       p.product_name
FROM sales s
JOIN goldusers_signup g ON s.user_id = g.user_id
JOIN product p ON s.product_id = p.product_id
WHERE s.created_date < g.gold_signup_date;

SELECT s.user_id,
       COUNT(*) AS orders,
       SUM(p.price) AS total_spent
FROM sales s
JOIN goldusers_signup g ON s.user_id = g.user_id
JOIN product p ON s.product_id = p.product_id
WHERE s.created_date < g.gold_signup_date
GROUP BY s.user_id;

SELECT s.user_id,
       s.created_date,
       p.product_name,
       CASE 
         WHEN g.user_id IS NOT NULL 
         THEN RANK() OVER(PARTITION BY s.user_id ORDER BY s.created_date)
         ELSE 'NA'
       END AS transaction_rank
FROM sales s
LEFT JOIN goldusers_signup g ON s.user_id = g.user_id
JOIN product p ON s.product_id = p.product_id;














