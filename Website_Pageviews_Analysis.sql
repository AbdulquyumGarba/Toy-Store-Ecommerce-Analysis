select * from Website_Pageviews;

--Calculating Amount of Pageview per hour
select 
	TO_CHAR(Created_at,'HH24') Hourly,
	COUNT(Website_pageview_id) Amount_Of_View 
from Website_Pageviews 
group by 1 
order by 1 asc;

--Querying the time when Pageview URL gets the highest Amount of Views e.g TPURL
with TPURL as(
select 
	TO_CHAR(Created_at,'HH24') Hourly,
	Pageview_URL URL,
	COUNT(Website_pageview_id) Amount_Of_View 
from Website_Pageviews 
group by 1,2 
order by  3 desc
),
MTPURL as(
select 
	URL,
	Hourly,
	Amount_Of_view,
	MAX(Amount_of_view) over (partition by URL order by Amount_of_View desc) Max_Views 
from TPURL 
)
select distinct(tl.URL),tl.Hourly,Max_Views
from TPURL tl
inner join
MTPURL mtl
on mtl.Max_views=tl.amount_of_view
order by 3 desc;
