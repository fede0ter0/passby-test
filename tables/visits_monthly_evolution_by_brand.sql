CREATE TABLE visits_monthly_evolution_by_brand AS
WITH
visits_monthly_by_brand as 
(
	select
	vw.brand_id,
	year_month,
	sum(weekly_visits) as monthly_visits
	from visits_weekly_by_brand vw
	inner join places pl on 
	vw.brand_id = pl.brand_id
	where city_id = 2
	group by 1,2
),
visits_monthly_by_brand_comparison as
(
	select
	brand_id,
	year_month,
	monthly_visits,
	LAG(monthly_visits) OVER (PARTITION BY brand_id order by year_month) as previous_visits
	from visits_monthly_by_brand
)
select
brand_id,
year_month,
monthly_visits,
case 
when year_month = '2024-01-01' then null
else (((monthly_visits - previous_visits) / previous_visits) * 100)
end as pct_change_visits
from visits_monthly_by_brand_comparison;