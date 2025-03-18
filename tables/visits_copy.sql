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