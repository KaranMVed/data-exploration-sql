
drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2016'),
(2,'01-15-2016'),
(3,'04-11-2016');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);



drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users


--1. Total amount of money spend by each user 
select a.userid,sum(b.price) total_amount
from sales a inner join product b on a.product_id= b.product_id
group by a.userid

--2. how may days haseach customer visited this foodordering website
select Userid,count(distinct created_date) Total_days 
from sales 
group by userid


--3. First Product Purchased By Each Customer
select* from
(select * ,rank() over(partition by userid order by created_date) rnk from sales) a
where rnk=1
 
 -- 4. most purchsed product and how many times purchased by all cust 
 select userid, count(product_id) cnt from sales WHERE product_id =
(Select top 1 product_id 
 from  sales
 group by product_id 
 order by count(product_id) desc)
 group by userid


 -- 5. which is the fav product of each cust
 
 SELECT * FROM
 (SELECT *, RANK() OVER (PARTITION BY userid ORDER BY CNT_PURCHASED DESC) AS rnk
FROM 
(
  SELECT userid, product_id, COUNT(product_id) AS CNT_PURCHASED
  FROM sales 
  GROUP BY userid, product_id
) A)B
WHERE rnk=1

-- 6. WHAT WAS THE FIRST ITEM TO PURCHASED BY THE PERSON AFTER BECOMING GOLD MEMEBER
select* from	
(select c.*, rank() over(partition by userid order by created_date) rnk from
(select a.userid, a.created_date, a.product_id, b.gold_signup_date
from sales a inner join goldusers_signup b on a.userid =b.userid 
and created_date>= gold_signup_date) c) d where rnk= 1

-- 6.1  ITEAM WAS PURCHASED BEFORE GOLD MEMEBERSHIP 
select* from	
(select c.*, rank() over(partition by userid order by created_date DESC) rnk from
(select a.userid, a.created_date, a.product_id, b.gold_signup_date
from sales a inner join goldusers_signup b on a.userid =b.userid 
and created_date<= gold_signup_date) c)D WHERE rnk=1


-- 7 .total order and amount for each member before becoming member
select userid, sum(price) total_amount_spent , count(created_date)order_purchased from 
(select c.*, d.price from 
(select a.userid, a.created_date, a.product_id, b.gold_signup_date
from sales a inner join goldusers_signup b on a.userid =b.userid 
and created_date<= gold_signup_date) c inner join product d on c.product_id=d.product_id)e
group by userid--,product_id




-- 8 if for each purchase user will get website point  eg 5rs= 2 points and each product have diff points system as productid 1 as 5rs=1 point pr2 10rs= 5 points pr3 same as pr1
-- so how much points does each cust have in  their wallet after buying product till last date?

(select e.*,amt/points total_points from 
(select d.*,case when product_id =1 then 5 when product_id=2 then 2 when product_id= 3 then 1 else 0 end as points from 
(select c.userid, c.product_id, sum(price) amt from 
(select a.*,b.price from sales a inner join product b on a.product_id= b.product_id)c
group by userid,product_id)d)e)

----------total collected points-------------------------------

select userid, sum (total_points) as collected_points from 
(select e.*,amt/points total_points from 
(select d.*,case when product_id =1 then 5 when product_id=2 then 2 when product_id= 3 then 1 else 0 end as points from 
(select c.userid, c.product_id, sum(price) amt from 
(select a.*,b.price from sales a inner join product b on a.product_id= b.product_id)c
group by userid,product_id)d)e)k group by userid	


-- 9 in the first one year after a cust joins the gold program irrespective of what the cust has purchased they earn 1pooints = 2rs so which gold member earned more 
-- and whats the point earning in their first year ?
select c.*,d.price from 
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a inner join 
goldusers_signup b on a.userid=b.userid and created_date>=gold_signup_date and created_date<=DATEADD(YEAR,1,gold_signup_date))c inner join product d on c.product_id=d.product_id ;
--
--so if 1 points = 2rs then 0.1= 1 rs
select c.*,d.price*0.5 as chasback  from 
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a inner join 
goldusers_signup b on a.userid=b.userid and created_date>=gold_signup_date and created_date<=DATEADD(YEAR,1,gold_signup_date))c inner join product d on c.product_id=d.product_id ;

