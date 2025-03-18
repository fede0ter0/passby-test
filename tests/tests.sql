-- This script tests the tables of the data model

-- FAST CHECK OF TABLES

--select * from brands limit 100;
--select * from places limit 100;
--select * from visits limit 100;
--select * from visits_daily limit 100;
--select * from visits_monthly_by_poi limit 100;
--select * from visits_weekly_by_brand limit 100;
--select * from visits_monthly_evolution_by_brand limit 100;
--select * from visits_copy limit 100;

/*
select * from visits_copy
where place_id in (
	select id as place_id from places
	where brand_id = (select id from brands where name = 'Sansom')
);
*/

-- CHECK FOR DUPLICATES

/*
select
id,
count(*) as dups
from brands
group by 1
having count(*) > 1
*/

/*
select
id,
count(*) as dups
from places
group by 1
having count(*) > 1
*/

/*
select
visit_date,
place_id,
count(*) as dups
from visits
group by 1,2
having count(*) > 1
*/

/*
select
visit_date,
place_id,
visit_day_of_month,
count(*) as dups
from visits_daily
group by 1,2,3
having count(*) > 1
*/

/*
select
place_id,
year_month,
count(*) as dups
from visits_monthly_by_poi
group by 1,2
having count(*) > 1
*/

/*
select
brand_id,
year_month,
week,
count(*) as dups
from visits_weekly_by_brand
group by 1,2,3
having count(*) > 1
*/

/*
select
brand_id,
year_month,
count(*) as dups
from visits_monthly_evolution_by_brand
group by 1,2
having count(*) > 1
*/

/*
select
visit_date,
place_id,
count(*) as dups
from visits_copy
group by 1,2
having count(*) > 1
*/

-- CHECK IF THERE IS A 1:1 CORRESPONDENCE BETWEEN ROWS IN places AND POIs

/*
select
count(distinct(id)) as places,
count(*) as _rows
from places
*/


-- CHECK IF EVERY MONTH HAS ITS CORRESPONDING NUMBER OF DAYS

/*
select
visit_date,
place_id,
count(*)
from visits_daily
group by 1,2
order by 1;
*/

-- CHECK FOR REFERENTIAL INTEGRITY

-- places --> brands

/*
select 
pl.id
from places pl
left join brands br on
pl.brand_id = br.id
where br.id is null
*/

-- visits --> places

/*
select
vi.place_id
from visits vi
left join places pl on
vi.place_id = pl.id
where pl.id is null;
*/