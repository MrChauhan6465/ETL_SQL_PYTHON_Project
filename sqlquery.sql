
--1)Find top 10 highest revenue generating products
select top 10 product_id,round(sum(sales_price),2) as sales
	from orders
	group by product_id
	order by sales desc

--2) Find top 5 highest sales products in each region 
with cte as (
select  region, product_id,round(sum(sales_price),2) as sales
	from orders
	group by region,product_id
	
)
select * from (
select *, ROW_NUMBER() over(partition by region order by sales desc) as rn  
from cte) A 
where rn<=5

--3) Find Month over month comparison for 2022 and 2023 sales -- jan 2022 vs jan 2023

with cte as (
select 
	  Year(order_date) as Order_year, MONTH(order_date) as Order_month , round(sum(sales_price),0) as sales
from orders
group by Year(order_date),MONTH(order_date)


)
select Order_month,sum(case when Order_year= 2022 then sales end )as'2022_sales',
		sum(case when Order_year=2023 then sales end )as '2023_sales'
from cte
group by Order_month;

--4) For each Category which month had highest sales 

with cte as (
select  category,format(order_date,'yyyy-MM') as order_year_month ,round(sum(sales_price),0) as sales
from orders
group by category, format(order_date,'yyyy-MM')

)
select * from (
select *,ROW_NUMBER() over(partition by category order by sales desc) as rn 
from  cte) a 

where rn=1;


--5) Which sub category had highest growth by profit in 2023 compare to 2022 

WITH cte AS (
    SELECT 
        sub_category, 
        YEAR(order_date) AS order_year, 
        SUM(profit) AS profit 
    FROM 
        orders
    GROUP BY 
        sub_category, YEAR(order_date)
)
SELECT 
    sub_category,
    current_year_profit,
    previous_year_profit,
    CASE 
        WHEN previous_year_profit <> 0 THEN ((current_year_profit - previous_year_profit) / previous_year_profit) * 100
        ELSE NULL
    END AS growth
FROM (
    SELECT 
        sub_category,
        SUM(CASE WHEN order_year = 2023 THEN profit END) AS current_year_profit,
        SUM(CASE WHEN order_year = 2022 THEN profit END) AS previous_year_profit
    FROM 
        cte
    GROUP BY 
        sub_category
) a;



