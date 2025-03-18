CREATE TABLE "public".places (
	id UUID PRIMARY KEY,
	brand_id UUID NOT NULL,
	city_id INT NOT NULL,
	FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE SET NULL	
);