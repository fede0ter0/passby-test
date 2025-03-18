COPY visits(visit_date, place_id, visits_arr)
FROM '/Users/fedeotero/dev/passby/passby-test/data/visits.csv'
WITH (FORMAT csv, HEADER true);

ALTER TABLE visits ADD COLUMN visits INTEGER[];

UPDATE "public".visits
SET visits = string_to_array(trim(both '[]' from visits_arr), ',')::INTEGER[];

ALTER TABLE visits DROP COLUMN visits_arr;