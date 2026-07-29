 create table Product 
 (Product_ID INT not null,Created_at TIMESTAMP not null,Product_Name VARCHAR(50),
 primary key(Product_ID));
 
create table Website_Session
(Website_Session_ID INT not NULL,Created_at TIMESTAMP not NULL,
User_ID INT not null,Is_Repeat_Session smallint ,Utm_Source VARCHAR(30),
Utm_Campaign VARCHAR(30),Utm_Content VARCHAR(30),Device_Type VARCHAR(30),
Http_Referer VARCHAR(100),primary key(Website_Session_ID));

create table Orders 
(Order_ID INT not NULL,Created_at TIMESTAMP not NULL, Website_Session_ID INT not NULL,
 User_ID INT not NULL,Product_ID INT not NULL,Items_Purchased INT,Price NUMERIC(5,2),
 Cogs NUMERIC(4,2),
 primary key(Order_ID),
 foreign key(Website_Session_ID) references Website_session(Website_Session_ID) on delete CASCADE,
 foreign key(Product_ID) references Product(Product_ID) on delete cascade);

create table Order_Item
(Order_Item_ID INT not null,Created_At TIMESTAMP not null,Order_Id INT,
Product_ID INT not null,Is_Primary_Item smallint,Price NUmeric(5,2),
Cogs NUMERIC(4,2),
primary key(Order_Item_ID),
foreign key(Product_ID) references Product(Product_ID) on delete CASCADE,
foreign key(Order_ID) references "Order"(Order_ID) on delete cascade);


create table Order_Item_Refund
(Order_Item_Refund_ID INT not null,Created_At TIMESTAMP not null ,Order_Item_ID INT,
Order_ID INT not NULL,Refund_Amount DOUBLE precision,
primary key (Order_Item_Refund_ID),
foreign key (Order_Item_ID) references Order_Item(Order_Item_ID) on delete CASCADE,
foreign key (Order_ID) references "Order"(Order_ID)on delete CASCADE);

create table Website_Pageviews
(Website_Pageview_ID INT not NULL,Created_At TIMESTAMP not NULL,Website_Session_ID INT not NULL,Pageview_Url VARCHAR(50),
primary key(Website_Pageview_ID),
foreign key(Website_Session_ID)references Website_Session(Website_Session_ID) on delete CASCADE);
