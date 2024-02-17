create database portfolioDB
use portfolioDB;
SELECT * FROM sales_data_sample;
exec sp_help 'sales_data_sample';

--WHICH PRODUCT GENERATES HIGHEST REVENUE
SELECT PRODUCTLINE,SUM(SALES) AS REVENUE 
FROM sales_data_sample
GROUP BY PRODUCTLINE
ORDER BY 2 DESC;

--WHICH YEAR REVENUE IS HIGHEST
SELECT YEAR_ID,ROUND(SUM(SALES),0) AS REVENUE 
FROM sales_data_sample
GROUP BY YEAR_ID
ORDER BY 2 DESC;

--WHAT TYPES OF DEALS GENERATAES MORE REVENUE
SELECT DEALSIZE,ROUND(SUM(SALES),0) AS REVENUE 
FROM sales_data_sample
GROUP BY DEALSIZE
ORDER BY 2 DESC;

--WHAT WAS THE BEST MONTH FOR SALES IN SPECIFIC YEAR?HOW MUCH WAS EARNED THAT MONTH?

SELECT month_id, round(total_sales,0) as total_sales, year_id,order_count
FROM (
    SELECT month_id, SUM(sales) as total_sales, year_id,COUNT(ordernumber) as order_count, RANK() OVER (PARTITION BY year_id ORDER BY SUM(sales) DESC) as sales_rank
    FROM sales_data_sample
    GROUP BY year_id, month_id
) ranked_sales
WHERE sales_rank = 1;

--who is our best customer?(this would be best answer with RFM)

DROP TABLE IF EXISTS #rfm
;with rfm as 
(select customername ,sum(sales) as monetaryValue,avg(sales) as avgMonetaryvalue,count(ordernumber) as frequency,max(orderdate) as last_order_date
,(select max(orderdate) from sales_data_sample) as max_order_date,
DATEDIFF(dd,max(orderdate),(select max(orderdate) from sales_data_sample)) as Recency
from sales_data_sample
group by CUSTOMERNAME),
rfm_calc as(
select r.*,
      NTILE(4) over(order  by Recency) rfm_recency,
      NTILE(4) over(order  by frequency) rfm_frequency,
      NTILE(4) over(order  by monetaryValue) rfm_monetary
from rfm r)
select 
	c.*, rfm_recency+ rfm_frequency+ rfm_monetary as rfm_cell,
	cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetary  as varchar)rfm_cell_string
into #rfm
from rfm_calc c

select CUSTOMERNAME , rfm_recency, rfm_frequency, rfm_monetary,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322,232,243) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432,412,421,423,312) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment

from #rfm


--What products are most often sold together? 
--select * from [dbo].[sales_data_sample] where ORDERNUMBER =  10411

select distinct OrderNumber, stuff(

	(select ',' + PRODUCTCODE
	from [dbo].[sales_data_sample] p
	where ORDERNUMBER in 
		(

			select ORDERNUMBER
			from (
				select ORDERNUMBER, count(*) rn
				FROM [PortfolioDB].[dbo].[sales_data_sample]
				where STATUS = 'Shipped'
				group by ORDERNUMBER
			)m
			where rn = 3
		)
		and p.ORDERNUMBER = s.ORDERNUMBER
		for xml path (''))

		, 1, 1, '') ProductCodes

from [dbo].[sales_data_sample] s
order by 2 desc


--What city has the highest number of sales in a specific country
select city, sum (sales) Revenue
from [portfolioDB].[dbo].[sales_data_sample]
where country = 'UK'
group by city
order by 2 desc



---What is the best product in United States?
select country, YEAR_ID, PRODUCTLINE, sum(sales) Revenue
from [portfolioDB].[dbo].[sales_data_sample]
where country = 'USA'
group by  country, YEAR_ID, PRODUCTLINE
order by 4 desc