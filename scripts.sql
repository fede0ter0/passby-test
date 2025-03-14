-- DROP TABLE if exists brands;

CREATE TABLE "public".brands (
	id UUID PRIMARY KEY,
	name VARCHAR(100)
);

COPY brands(id, name)
FROM '/Users/fedeotero/dev/passby/passby-test/data/brands.csv'
WITH (FORMAT csv, HEADER true);

-- select * from brands;

-------------------------------------
-- DROP TABLE if exists places;

CREATE TABLE "public".places (
	id UUID PRIMARY KEY,
	brand_id UUID NOT NULL,
	city_id INT NOT NULL,
	FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE SET NULL	
);

COPY places(id, brand_id, city_id)
FROM '/Users/fedeotero/dev/passby/passby-test/data/places.csv'
WITH (FORMAT csv, HEADER true);

-- select * from places;

-------------------------------------
-- DROP TABLE if exists visits;

CREATE TABLE "public".visits(
	visit_date DATE NOT NULL,
	place_id UUID NOT NULL,
	visits_arr TEXT NOT NULL,
	PRIMARY KEY (visit_date, place_id)
);

COPY visits(visit_date, place_id, visits_arr)
FROM '/Users/fedeotero/dev/passby/passby-test/data/visits.csv'
WITH (FORMAT csv, HEADER true);

ALTER TABLE visits ADD COLUMN visits INTEGER[];

UPDATE "public".visits
SET visits = string_to_array(trim(both '[]' from visits_arr), ',')::INTEGER[];

ALTER TABLE visits DROP COLUMN visits_arr;

-- select * from visits;

---------------------------------------
-- Task 1
-- DROP TABLE IF EXISTS visits_daily;
CREATE TABLE visits_daily AS
select
visit_date,
place_id,
visit as visits,
visit_day_of_month::INTEGER
from visits,
LATERAL unnest(visits)
WITH ORDINALITY as visit(visit,visit_day_of_month);

-- select * from visits_daily

-- Create a table of monthly visits per point of interest (POI)
-- drop table if exists visits_monthly_by_poi;
CREATE TABLE visits_monthly_by_poi AS
select
place_id,
visit_date as year_month,
sum(visit) as monthly_visits
from visits_daily
group by 1,2;

-- select * from visits_monthly_by_poi

-- Create a table of weekly visits per brand

-- previous check: see if each place has one or more than one brand in 'places'
select
count(distinct(id)) as places,
count(*) as _rows
from places

-- conclusion: each row corresponds to one POI (there are no two rows with the same POI) and
-- each POI corresponds to only one brand

-- drop table if exists visits_weekly_by_brand;
CREATE TABLE visits_weekly_by_brand AS
WITH
visits_weekly_by_brand as 
(
	select
	brand_id,
	visit_date as year_month,
	visit_day_of_month,
	(DIV(visit_day_of_month-1,7)+1) as week,
	visit
	from visits_daily vd
	inner join places pl on
	vd.place_id = pl.id
)
select
brand_id,
year_month,
week,
sum(visit) as weekly_visits
from visits_weekly_by_brand
group by 1,2,3;

-- select * from visits_weekly_by_brand
---------------------------------------
-- Task 2: Advanced SQL Operations
-- Create a table showing the percentage change in total visits to each brand in for fk_city = '2' 
-- from month to month throughout 2024

-- DROP TABLE visits_monthly_evolution_by_brand;
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

-- select * from visits_monthly_evolution_by_brand;

---------------------------------------
-- Task 3: Data Update Scenario
-- Create a copy of the visits table that correctly shows 0 visits to Sansom POIs on Sundays.

-- drop table if exists visits_copy;
CREATE TABLE visits_copy AS
SELECT * from visits;

UPDATE visits_copy
SET visits = (
	select ARRAY(
		select case when EXTRACT(DOW FROM visit_date + (ind::INTEGER - 1)) = 0 then 0 else visit
        end
        from unnest(visits) WITH ORDINALITY AS t(visit, ind)
    )
)
WHERE place_id in (
	select id as place_id from places
	where brand_id = (select id from brands where name = 'Sansom')
);

-- select * from visits_copy
-- where place_id in (
-- 	select id as place_id from places
-- 	where brand_id = (select id from brands where name = 'Sansom')
-- );
