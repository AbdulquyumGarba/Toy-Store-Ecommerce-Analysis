--Calculating website_session,Amount_of_orders,YOY_website_performance per Year/Month/Day/Hour, and also correlation with website_sessions and orders
with AWS as(
	select 
		TO_CHAR(ws.created_at,'YYYY') "Year",
		COUNT(ws.website_session_id ) Amount_Website_Session,
		COUNT(O.Order_ID) Amount_Of_Orders
	from website_session ws
	left join Orders O
	USING(Website_Session_ID)
	group by 1
	order by 2 desc
)
select 
	"Year",
	Amount_Website_Session,
	Amount_Of_Orders,
	Amount_Website_Session-LAG(amount_website_session ) over (order by "Year" asc) YOY_Website_Performance
	from AWS;

--Calculating Amount of website session and orders per user to check if there is any correlation
with UWS as (
select 
	ws.User_ID, 
	COUNT(website_Session_ID) Amount_Website_Session,
	COUNT(Order_ID) Amount_Of_Orders
from Website_Session ws
left join orders o 
USING(Website_Session_ID)
group by 1
order by 2 desc
)
select 
	distinct(Amount_Website_Session),
	LPAD('*',ROUND( (AVG(Amount_Of_Orders) over (Partition by Amount_Website_Session)*100) ,2) ::INT,'*') Avg_Orders 
from UWS 
order by 2 desc;

--Calculating repeated sessions and Amount of Orders
with IPS  as (
select website_Session_ID,is_repeat_session,
	COUNT(case when is_repeat_session=1 then 1 else 0 end) over (partition by is_repeat_session) Count_Of_Session
from website_session ws 
order by 2 desc
)
select 
	distinct(is_repeat_session),
	Count_Of_Session,
	COUNT(Order_ID) Amount_Of_Orders
from IPS
inner join orders o using(Website_Session_ID)
group by 1,2;

--Calculating the Year/Month/Day/Hour with the most Repeated Orders
select 
	TO_CHAR(ws.created_at,'YYYY') Order_Year,-- replace 'YYYY' with these ('Month'/'Day'/'HH24') to be able to drill down across time
	COUNT(ws.website_session_id ) Amount_Of_Session,
	COUNT(O.Order_ID) Amount_Of_Orders
from Website_Session ws
LEFT join orders o 
USING(Website_Session_ID)
where is_repeat_session =1 --replace with 0 if you want to see ones with non-repeated sessions
group by 1
order by 1 asc;

--Calculating website session per refunds
with WSRF as (
select 
	ws.User_ID, 
	COUNT(website_Session_ID) Amount_Website_Session,
	COUNT(oir.Order_Item_Refund_ID) Amount_Of_Refunds
from Website_Session ws
LEFT join orders
USING(website_Session_ID)
INNER join Order_Item_Refund oir
USING(Order_ID)
group by 1
order by 2 
)
select DISTINCT(Amount_Website_Session), AVG(Amount_Of_Refunds) Avg_Amount_Of_Refunds
from WSRF
group by 1;

--Amount of Users and Orders per UTM Source that has a no repeated session
select 
	ws.utm_source,
	COUNT(ws.Website_Session_ID) Amount_Of_Users,
	COUNT(o.Order_ID) Amount_Of_Orders,
	COUNT(oir.Order_Item_Refund_ID) Amount_Of_refunds
from website_Session ws
LEFT join Orders O
USING(Website_Session_ID)
left join order_item_refund oir 
USING(Order_ID)
where is_repeat_session =0 --ADD 1 if u want to see info on users with repeated sessions
group by 1
order by 2 desc;

--Amount of users and Orders per UTM source that has repeated session
select 
	ws.utm_source,
	COUNT(ws.Website_Session_ID) Amount_Of_Users,
	COUNT(o.Order_ID) Amount_Of_Orders,
	COUNT(oir.order_item_refund_id ) Amount_Of_Refunds
from website_Session ws
LEFT join Orders O
USING(Website_Session_ID)
left join order_item_refund oir 
using (Order_ID)
where is_repeat_session =1 --ADD 0 if u want to see info on users with repeated sessions
group by 1
order by 2 desc;

--Amount of traffic per UTM_Source
with TFPUTM as (
select
	TO_CHAR(created_at,'Day') Days,
	Utm_source,
	COUNT(website_Session_ID) Amount_Of_Traffic
from website_Session
group by 1,2
order by 2,3 desc
),
 --For selecting  Max Traffic per UTM_Source 
	MTFPUTM as (
 select 
 	Days,
 	utm_source,
 	Amount_Of_Traffic,
 	MAX(Amount_of_traffic) over (partition by utm_source ) Max_Traffic 
 from TFPUTM
 )
 --For Calculating the days with the highest amoun of traffic for each UTM_Source
 select 
	 Days,
	 utm_source,
	 Amount_Of_Traffic Highest_amount_of_traffic
from  TFPUTM 
where Amount_Of_Traffic in (select DISTINCT(Max_Traffic) from MTFPUTM ) ;

--Calcualting Campaigns by Website visits,Calculating the source for highest campaign visit,
create temp table CWV as 
select 
	utm_campaign,
	utm_source,
	COUNT(Website_Session_ID) Amount_Of_Visit 
from website_session
group by 1,2
order by 2 desc;
--Calculating the source for highest campaign visit
select 
	*
from CWV 
where Amount_Of_Visit =(select MAX(Amount_Of_visit) from CWV);
--Calculating source for the lowest campaign visit
select 
	*
from CWV 
where Amount_Of_Visit =(select MIN(Amount_Of_visit) from CWV);
--Grouping campaigns by website session and also Year/Month/Day/Time
with CWV as (
select 
	TO_CHAR(created_at,'HH24:00') Visit_Time,
	Utm_campaign,
	COUNT(Website_Session_ID) Amount_Of_Visit
from website_Session
group by 1,2
),
	MCWV as (
select *,MAX(Amount_Of_Visit) over (partition by Visit_Time) Max_Visit_Time from CWV order by 3 desc
)
--Highest Amount_Of_Visit by Time
select * from MCWV limit 23;

--Grouping Campaigns by Device_Type
select 
	utm_campaign,
	ROUND(AVG(case when device_type ='desktop' then 1 else 0 end)*100,2)  Desktop_Percentage,
	ROUND(AVG(case when device_type ='mobile' then 1 else 0 end)*100,2) Mobile_Percentage 
from Website_Session group by 1;


