select * from Order_Item_Refund;

1.Total Amount of refunds
2. Calculate AVG and Total refunds in a Year,Month,Day,Hour
3.Calculate the most refunded item/product
4.Calculate refund amount per Year,Month,Day,Hour
5.Calculate the average time between time of order and time of refund in order to predict how much time it takes to return an order

--Total Amount Of Refunds
select COUNT(Order_Item_refund_id) Total_Amount_Of_Refunds from Order_Item_Refund;

--Total Amount Of Refunds
select COUNT(Order_Item_refund_id) Total_Amount_Of_Refunds from Order_Item_Refund;

--Avg Refund Amount Per Year, Month,Day
select 
	TO_CHAR(created_at,'YYYY') "Year",
	AVG(refund_amount) Average_Refund_Amount 
from Order_Item_Refund
group by 1
order by 2 desc;

--Calculating Refund Rate/Product (RFP) 
with RFP as (
	select
		p.product_name Product,
		COUNT(oir.Order_Item_ID) Amount_Of_Refund
	from order_item_refund oir
	inner join order_item oi
	USING(Order_ID)
	inner join product p
	Using(Product_ID)
	group by 1
	order by 2 desc
)
select 
	*,
	CUME_DIST() over (order by Amount_Of_Refund) Distribution 
from RFP ;

--Average Predicted Amount of days for Refund
select
	EXTRACT(Days from AVG(O.created_at-oir.created_at)) Amount_Of_Refund
from order_item_refund oir
inner join orders o
USING(Order_ID);

--Calculating Year,Month,Day with the most refunds and Average Returns Per month
with Monthly_Refunds/*(Yearly/Daily/Hourly)*/ as (
		select 
		 	TO_CHAR(created_at,'Month'/*('YYYY','Day','HH24')*/),
			COUNT(order_item_refund_id ) Amount_Of_Refund
		from order_item_refund 
		group by 1
		order by 2 desc
)
select 
	ROUND(AVG(Amount_Of_Refund),0) AVg_Monthly_Refunds 
from Monthly_Refunds /*(Yearly/Daily/Hourly)*/;
