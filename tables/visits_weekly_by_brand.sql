CREATE TABLE visits_weekly_by_brand AS
WITH
visits_weekly_by_brand as 
(
	select
	brand_id,
	visit_date as year_month,
	visit_day_of_month,
	(DIV(visit_day_of_month-1,7)+1) as week,
	visits
	from visits_daily vd
	inner join places pl on
	vd.place_id = pl.id
)
select
brand_id,
year_month,
week,
sum(visits) as weekly_visits
from visits_weekly_by_brand
group by 1,2,3;