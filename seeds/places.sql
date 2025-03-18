COPY places(id, brand_id, city_id)
FROM '/Users/fedeotero/dev/passby/passby-test/data/places.csv'
WITH (FORMAT csv, HEADER true);