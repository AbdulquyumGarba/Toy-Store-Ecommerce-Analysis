--Exploring the Table
select * from Product;

--Amount of Products sold
select 
	COUNT(product_id) Amount_Of_Product 
from Product;
--Calculating the latest and Oldest Product
select 
	*,
	lAG(product_name) over (order by created_at asc rows between 1 preceding and unbounded following) Preceding_Product
from product;

--How much the Products has sold since creation
select
	p.Product_name,
	SUM(O.price) Total_Revenue,
	SUM(O.cogs) Total_Cost_Of_Goods_Sold,
	SUM(O.price-O.cogs) Total_Profit_Made
from product p
inner join orders o 
using(Product_id)
group by 1
order by 2 desc;

--Refund Rate of Product
with AMO as (
	select
		p.product_id product_id,
		product_name product_name,
		COUNT(Order_id) Amount_Of_Orders
	from Product p
	inner join Orders O
	USING(Product_ID)
	group by 1
	order by 2 desc
),
 AMR as (
	select
		ors.product_ID product_id,
		COUNT(Oir.order_item_Refund_id) Amount_Of_Refunds
	from Orders Ors
	inner join Order_Item_Refund Oir
	USING(Order_ID)
	group by 1
	order by 2 desc
)
select 
	product_id,product_name,
	ROUND(((Amount_of_refunds::numeric)/Amount_Of_Orders)*100,2) Refund_Rate
from AMO
inner join AMR
using (product_id);

-- Percentage of times a product has been the Primary Item
select 
	p.product_name,
 	ROUND(AVG(case when OI.is_primary_Item=1 then 1 else 0 end)*100,0) "%Primary_Item "
from Order_Item OI
inner join product p
using(product_ID)
group by 1;
