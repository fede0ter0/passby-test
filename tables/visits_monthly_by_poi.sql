CREATE TABLE visits_monthly_by_poi AS
select
place_id,
visit_date as year_month,
sum(visits) as monthly_visits
from visits_daily
group by 1,2;