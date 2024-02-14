CREATE DATABASE ZOMATO;
USE ZOMATO;
CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

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
select * from users;

--WHAT IS TOTAL AMOUNT SPEND BY EACH  CUSTOMER ON ZOMATO?
select a.userid,SUM(b.price ) AS total_amt
from sales AS a inner join product AS b on a.product_id=b.product_id group by userid;

--how many days has each customer visited zomato?
select userid,count(distinct created_date) as visit_days from sales group by userid;

--what was the first item purchased by customer?
select * from (select *,RANK() over(partition by userid order by created_date) as rnk from sales) as a where rnk=1;

--what is the most purchased menu and how many times was it purchased by all customers?
 select userid,count(product_id) as cnt from sales where product_id=
 (select  top 1 product_id from sales group by product_id 
order by count(product_id) DESC)
 group by userid;

 --which item  was the most popular for each customer?

 WITH RankedSales AS (
    SELECT
        userid,
        product_id,
        COUNT(product_id) AS purchase_count,
        RANK() OVER (PARTITION BY userid ORDER BY COUNT(product_id) DESC) AS rank
    FROM
        sales
    GROUP BY
        userid,
        product_id
)

SELECT
    userid,
    product_id,
    purchase_count
FROM
    RankedSales
WHERE
    rank = 1;

--which item is purchased first by customer after they became a gold_member
select userid,product_id from (select *,rank()over (partition by userid order by created_date)as rnk from
(select 
a.userid,a.created_date,a.product_id,b.gold_signup_date
from sales as a 
join goldusers_signup as b 
on a.userid=b.userid and a.created_date>b.gold_signup_date)as c) as d
where rnk=1; 

--which item is purchased  just before customer became a gold_member?
select userid,created_date,product_id from (select *,rank()over (partition by userid order by created_date DESC)as rnk from
(select 
a.userid,a.created_date,a.product_id,b.gold_signup_date
from sales as a 
join goldusers_signup as b 
on a.userid=b.userid and a.created_date<=b.gold_signup_date)as c) as d
where rnk=1; 

--what is total number of orders and amount spent by each member before they beacome a gold member?
select userid,count(created_date) as order_purchased,sum(price) as total_Spent from
(select c.*,d.price from
(select 
a.userid,a.created_date,a.product_id,b.gold_signup_date
from sales as a 
join goldusers_signup as b 
on a.userid=b.userid and a.created_date<=b.gold_signup_date) as c inner join product d on c.product_id=d.product_id)e
group by userid;

--if buying  each product generates points for eg 5rs=2 zomato point and each product has different purchasing points for 
--eg for p1 5rs=1 zomato point, for p2 10rs=5 zomato point and p3 5rs=1 zomato point 
--calculate each point collected by each customers and for which product most points have been given till now?
select userid,sum(ttl_pt) as total_pts from 
(select e.*,amt/points as ttl_pt from
(select d.*,case when product_id=1 then 5 when product_id=2 then 2 when  product_id =3 then 1 else 0 end as points from
(select c.userid,c.product_id,sum(price) as amt  from 
(select a.*,b.price from sales as a join product as b on a.product_id=b.product_id)c group by userid,product_id)d)e)f group by userid;

/*In the first year after a customer joins the gold programs (including their join date)irrespective of what the customer has purchased 
they earn 5 zomato points for every 10 rs spent who earned more 1 or 3  and what was their pointw learning in their first year? */
select c.*,d.price*0.5 as total_Pts_earned from
(select 
a.userid,a.created_date,a.product_id,b.gold_signup_date
from sales as a 
join goldusers_signup as b 
on a.userid=b.userid and a.created_date>b.gold_signup_date and a.created_date<=DATEADD(year,1,b.gold_signup_date))c
inner join product d on c.product_id=d.product_id;

--rank all the transaction of customers
select * ,rank() over(partition by userid order by created_date)as rnk from sales;

--rank all the transaction for each member whenever they are zomato gold member for every non gold memeber transaction mark na
select e.*,case when rnk=0 then 'na' else rnk end as rnkk from
(select c.*,cast((case when gold_signup_date is null then 0 else rank() over(partition by userid order by created_date desc) end) as varchar) as rnk 
from
(select 
a.userid,a.created_date,a.product_id,b.gold_signup_date
from sales as a 
left join goldusers_signup as b 
on a.userid=b.userid and a.created_date>=b.gold_signup_date) as c)as e;

