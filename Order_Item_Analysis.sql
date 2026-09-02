-- View the Table
select * from Order_Item;

--The average amount of Item per order
with AIPID as (select Order_ID,COUNT(Order_Item_ID) No_Of_Item
from Order_Item
group by 1
order by 2 desc)
select ROUND(AVG(No_of_Item)) from AIPID;

-- Percentage of Item Amount
select 
	AVG(case when No_of_Item=1 then 1 else 0 end)*100 One_Item,
	AVG(case when No_of_Item=2 then 1 else 0 end)*100 Two_Item
from (Select Order_ID,COUNT(Order_Item_ID) No_Of_Item
	  from Order_Item
	  group by 1
	  order by 2 desc);

-- Which product is ordered the most
select product_name,COUNT(Order_Item_Id) Amount_Of_Order
from order_Item oi
left join product 
using(product_id)
group by product_name
order by 2 desc
fetch first 1 row only;

-- Percentage of products that are the primary item in it's Order
select product_name,AVG(case when is_primary_item = 1 then 1 else 0 end)*100 percent_primary_item
from Order_Item
left join Product
USING(product_ID)
group by 1;

--What day, month, year is the highest ordered product ordered the most
select to_char(oi.created_at,'Day'),Count(Order_Item_Id)
from order_item oi
left join product p
USING(product_id)
where product_name = 'The Original Mr. Fuzzy'
group by 1;


--Which item is ordere the least
select product_name,COUNT(Order_Item_Id) Amount_Of_Order
from order_Item oi
left join product 
using(product_id)
group by product_name
order by 1
fetch first 1 row only;

--Which order item has the highest primary item count
with item_primary_count as (
	select product_name, 
	COUNT(is_primary_Item) Item_count
	from Order_item
	left join product
	using(product_id)
	where is_primary_item =1
	group by 1
	order by 2 desc
)
select product_name,
	   ROUND(Item_count/SUM(Item_count) over()*100) percentage
from item_primary_count;