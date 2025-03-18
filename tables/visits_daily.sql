CREATE TABLE visits_daily AS
select
visit_date,
place_id,
visit as visits,
visit_day_of_month::INTEGER
from visits,
LATERAL unnest(visits)
WITH ORDINALITY as visit(visit,visit_day_of_month);