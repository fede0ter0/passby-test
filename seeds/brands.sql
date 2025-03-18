COPY brands(id, name)
FROM '/Users/fedeotero/dev/passby/passby-test/data/brands.csv'
WITH (FORMAT csv, HEADER true);