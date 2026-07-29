/*Order Table Objectives
1. Total Amount of Order By Year,Month,Day,Hour
2. Group Orders by website Sessions e.g (Join website table to know the difference between When the website sessin started to when Order was placed)
	a. Group Orders by Device Category which Category is used for placing the most orders.
	b. Which Order has the most Repating websute session
3. Group User by Amount of Order Placed, Which User has the most Orders?, Which User Has the lowest Order,Dig deep into their Website session
	a. What is the avg website_session for a user,Is here a correlation between Website session and Orders.
4. What is the mpost Recurring Product in the Order, and what is the least recurring.
	a. Group Product by Order_time(Created_at), what pattern can you find.
	b. What is the most Paired Product
	c. Group Products purchased by Year,Month,Day,Hour, is there a relationship?
5. What is the avg amount of items purchased?, 
	a. what is the Maximum and Minimum amount of Item purchased(show a break down of the order items) and group by Year,Month,Day,Hour
	b. Does Number of items correlate with Website session? e.g Morning is always busier or not.
	c. Does Number of Products Correlate with when the Order was placed.e.g Does Certain time pull in more items?
6. What is the most expensive and cheap Product?
	a. How frequently are they purchased By Year,Month,Day,Hour
	b. What are they paired the most with
	c. which order had the hghest and lowest price
		i. what was the items purchased in there
		ii. what is the average price for every order
		iii. 
7. Avg profit margin per order
	a. Group profit margin By Year,Month,Day,hour*/
select * from Orders;

select COUNT(*) from Orders;
<h1> --Amount of orders by year,month,day,Hour </h1>
select 
	TO_CHAR(created_at,'HH24'/*('Month'/'Day'/'YYYY'/'Q')*/) as "Year",
	COUNT(*) "Amount_Of_Orders" 
from Orders
group by 1
order by 2 desc;
 ## --Calculating the Average Difference between the start of Website_Session and Time Order was Placed
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
