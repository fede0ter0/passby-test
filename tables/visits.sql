CREATE TABLE "public".visits(
	visit_date DATE NOT NULL,
	place_id UUID NOT NULL,
	visits_arr TEXT NOT NULL,
	PRIMARY KEY (visit_date, place_id)
);