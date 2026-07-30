select * from Order_Item_Refund;

1.Total Amount of refunds
2. Calculate AVG and Total refunds in a Year,Month,Day,Hour
3.Calculate the most refunded item/product
4.Calculate refund amount per Year,Month,Day,Hour
5.Calculate the average time between time of order and time of refund in order to predict how much time it takes to return an order

--Total Amount Of Refunds
select COUNT(Order_Item_refund_id) Total_Amount_Of_Refunds from Order_Item_Refund;

with TB as (select TO_CHAR(created_at,'Day') "Year",
	   COUNT(Order_Item_refund_id) Total_Amount_Of_Refunds 
from Order_Item_Refund
group by 1
order by 2 desc)
select *,CUME_DIST() over (order by Total_Amount_Of_Refunds  desc),
sum(Total_Amount_Of_Refunds) over (order by Total_Amount_Of_Refunds range between 16 preceding and current row),
last_value(Total_Amount_Of_Refunds) over (order by Total_Amount_Of_Refunds ),
Total_Amount_Of_Refunds- lead(Total_Amount_Of_Refunds) over(order by Total_Amount_Of_Refunds),
ntile(6) over(),nth_value("Year",2) over(rows between 1 preceding and UNBOUNDED FOLLOWING ) from TB;

CREATE TABLE sales(
	year SMALLINT CHECK(year > 0),
	group_id INT NOT NULL,
	amount DECIMAL(10,2) NOT NULL,
	PRIMARY KEY(year,group_id)
);

INSERT INTO
	sales(year, group_id, amount)
VALUES
	(2018,1,1474),
	(2018,2,1787),
	(2018,3,1760),
	(2019,1,1915),
	(2019,2,1911),
	(2019,3,1118),
	(2020,1,1646),
	(2020,2,1975),
	(2020,3,1516);


with salesp as (select year,SUM(amount) amount from sales
group by 1
order by 1)
select 
	year,
	amount,
	lead(amount) over (order by year asc) next_year_sales,
	lead(amount) over (order by year asc)-amount variance 
from salesp;