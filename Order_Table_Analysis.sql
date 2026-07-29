-- Explore the Orders Table
select * from Orders;

--Count the Total Orders
select COUNT(*) from Orders;

--Amount of orders by year,month,day,Hour 
select 
	TO_CHAR(created_at,'HH24'/*('Month'/'Day'/'YYYY'/'Q')*/) as "Year",
	COUNT(*) "Amount_Of_Orders" 
from Orders
group by 1
order by 2 desc;
 
--Calculating the Average Difference between the start of Website_Session and Time Order was Placed
select RPAD(EXTRACT(month from AVG(AGE(od.created_at,ws.created_at)))::TEXt,7,' month') Average_Time_Difference 
from Orders od 
inner join Website_Session ws 
USING(Website_Session_ID);

--Percentage of Orders that are below and Above Average Price
with TD as(
	select od.created_at Order_Time,
		    ws.created_at Website_session,
	        od.Price Price
	from Orders od 
	inner join Website_Session ws 
	USING(Website_Session_ID)
),
AVG_price as(
	select AVG(Price) AVG 
	from TD
)
select ROUND(AVG(case when Price >(select avg(price)from TD) then 1 else 0 end)*100,2) "Orders Above Avg",
	   ROUND(AVG(case when Price <(select avg(price)from TD) then 1 else 0 end)*100,2)"Orders Below Avg"from TD; 

--WHich Device People Place Order on Most
select RPAD(Round(AVG(case when ws.device_type ='desktop' then 1 else 0 end )*100,1)::VARCHAR,5,'%') "Desktop",
	   RPAD(Round(AVG(case when ws.device_type='mobile' then 1 else 0 end)*100,1)::VARCHAR,5,'%') "Mobile" 
from Orders od 
inner join Website_Session ws 
USING(Website_Session_ID);

--Percent of orders that has repeating session or not
select RPAD(Round(AVG(case when ws.is_repeat_session = 1 then 1 else 0 end )*100,0)::VARCHAR,3,'%')"Repeat",
	   RPAD(Round(AVG(case when ws.is_repeat_session = 0 then 1 else 0 end)*100,0)::VARCHAR,3,'%') "No Repeat" 
from Orders od 
inner join Website_Session ws 
USING(Website_Session_ID);

--Percentage Of Users that placed 1,Greater than 1,Less than 1
 with Amount_Of_Order_User as(
select User_id,
	   COUNT(*) Amount_Of_Order
from orders od 
group by 1
order by 2 desc
)
select ROUND(AVG(case when Amount_Of_Order > 1 then 1 else 0 end)*100,2)  "Greater_Avg_Items_Purchased",  
	   ROUND(AVG(case when Amount_Of_Order = 1 then 1 else 0 end)*100,2)  "Equal_Avg_Items_Purchased",
	   ROUND(AVG(case when Amount_Of_Order < 1 then 1 else 0 end)*100,2)  "Less_Avg_Items_Purchased" from Amount_Of_Order_User;

--Every Order Has only One product 'Boooooooooring'
select user_id,
	   ARRAY_AGG(p.product_name) 
from Orders s 
inner join Product p 
USING(Product_id)
group by 1
order by 1 desc;

-- Order Percentage of Product
select RPAD((ROUND(AVG(case when P.Product_name ='The Original Mr. Fuzzy' then 1 else 0 end)*100)::VARCHAR),3,'%')"The Original Mr. Fuzzy", 
	   RPAD((ROUND(AVG(case when P.Product_name ='The Forever Love Bear' then 1 else 0 end)*100)::VARCHAR),3,'%')"The Forever Love Bear",
	   RPAD((ROUND(AVG(case when P.Product_name ='The Birthday Sugar Panda' then 1 else 0 end)*100,1)::VARCHAR),4,'%')"The Birthday Sugar Panda",
	   RPAD((ROUND(AVG(case when P.Product_name ='The Hudson River Mini bear' then 1 else 0 end)*100,1)::VARCHAR),4,'%')"The Hudson River Mini bear"
from Orders O 
inner join  Product P 
USING(Product_id)
order by 2 desc;

--Products Purchased by Year,Month,Day,Hour
with Profitable_Product_by_Year as (
	select TO_CHAR(o.created_at,'YYYY') Sales_Year /*(Month/Day/Hour)*/,
	p.product_name Product_Name,COUNT(*) Total_Purchases
	from orders o
	inner join Product p
	USING(product_id)
	group by 1,2
),
Ranked_Value as (
	select Sales_Year,Product_Name,
	rank() over (partition by Sales_Year order by Total_Purchases desc) "Most_Profitable"
	from Profitable_Product_by_Year
)
select * 
from Ranked_value
where "Most_Profitable"=1
order by 3;

--Average Amount of Items Purchased 
select SUM(O.items_purchased ) Avg_Items_Purchased
from Orders O;

--Amount of Items Greater and Lesser the Avg_Items_Purchased
select SUM(case when Items_purchased >(select AVG(items_purchased) from Orders) then 1 else 0 end) "Greater_Avg_Items_Purchased",
	   SUM(case when Items_purchased <(select AVG(items_purchased )from Orders) then 1 else 0 end) "Less_Avg_Items_Purchased" from Orders;
--Website Session VS amount_Of Orders
select TO_CHAR(ws.Created_at,'HH24')Time_Of_Day,
	    COUNT(O.Order_ID) Amount_Of_Orders,LPAD('*',TRUNC(COUNT(O.Order_ID)/100)::INT,'*') "Chart"
from Orders O 
inner join Website_Session Ws
using(Website_Session_ID)
group by 1
order by 1;

--Most Expensive and Cheap Product.(Note:Prodcts dont have Specific Price)
select distinct(P.Product_id),
	    P.Product_name,AVG(O.Price) over (partition by p.product_name ) Avg_Price 
from Product P
inner join Orders O 
using (Product_id)
order by 3 desc;

--Most Expensive and Cheap Order
select distinct(O.Order_id),
	    P.Product_name,AVG(O.Price) over (partition by p.product_name) Avg_Price from Product P
inner join Orders O 
using (Product_id)
order by 3 desc;

--Calculating the average Profit Margin 
select ROUND(AVG(price-cogs),2) Avg_Profit_Margin from Orders;
