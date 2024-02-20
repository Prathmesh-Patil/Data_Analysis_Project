create database Pizza_sales

use Pizza_sales;

select * from pizza_sale;

select round(sum(total_price),0) as Total_Revenue from pizza_sale;

select round((sum(total_price)/count(distinct order_id)),2) as Avg_Order_Value from pizza_sale;

select sum(quantity) as Total_Pizza_Sold from pizza_sale;

select count(distinct(order_id)) as Total_Orders from pizza_sale;

select cast(cast(sum(quantity) as decimal(10,2))/cast(count(distinct(order_id)) as decimal(10,2)) as decimal(10,2))  as  Avg_Pizza_Per_Order  from  pizza_sale;

select  datename(DW, order_date) as order_day, count(distinct order_id) as total_orders 
from pizza_sale
group by  datename(DW, order_date);

select datename(MONTH,order_date) as Month_Name,count(distinct order_id) as Total_orders
from pizza_sale
group by datename(month,order_date)
order by Total_orders DESC;

select pizza_category,sum(total_price) as Total_sales ,sum(total_price)*100/(select sum(total_price) from pizza_sale) as PCT
from pizza_sale
--where month(order_date)=1
group by pizza_category

select pizza_size,round(sum(total_price),2) as Total_sales ,round(sum(total_price)*100/(select sum(total_price) from pizza_sale),2) as PCT
from pizza_sale
--where month(order_date)=1
group by pizza_size
order by PCT desc

select pizza_name ,round(sum(total_price),2) as individual_pizza_revenue from pizza_sale
group by pizza_name
order by 2 desc;


select pizza_name ,round(sum(quantity),2) as total_quantity from pizza_sale
group by pizza_name
order by 2 desc;


select pizza_name ,count(distinct order_id) as total_orders from pizza_sale
group by pizza_name
order by 2 asc;