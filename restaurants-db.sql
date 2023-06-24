-- Create a table to store restaurant information
CREATE TABLE restaurante (
    id SERIAL PRIMARY KEY, -- Unique identifier for each restaurant
    nume TEXT, -- Name of the restaurant
    adresa TEXT, -- Address of the restaurant
    strada TEXT, -- Street of the restaurant
    specialitate TEXT, -- Specialty of the restaurant
    telefon TEXT, -- Phone number of the restaurant
    nr_recenzii INTEGER, -- Number of reviews for the restaurant
    nota FLOAT, -- Average review rating for the restaurant
    url_recenzii TEXT, -- URL for restaurant reviews
    url_google_maps TEXT, -- URL for Google Maps location
    latitudine FLOAT, -- Latitude coordinate of the restaurant location
    longitudine FLOAT, -- Longitude coordinate of the restaurant location
    website TEXT, -- Website URL of the restaurant
    geom GEOMETRY(Point, 4326) -- Geometry column to store the restaurant location as a point
);

-- Select all rows from the "restaurante" table as a check measure
SELECT * FROM restaurante;

-- Select all rows from the "restaurante" table and order them by name in ascending order
SELECT * FROM restaurante
ORDER BY nume ASC;

-- Copy data from a CSV file into the "restaurante" table
COPY restaurante(nume, adresa, strada, specialitate, telefon, nr_recenzii, nota, url_recenzii, url_google_maps, latitudine, longitudine, website)
FROM 'C:\Users\AD\Desktop\RESTAURANTS.csv'
DELIMITER ',' CSV HEADER;

-- Update the "geom" column in the "restaurante" table with point geometries
UPDATE restaurante
SET geom = ST_SetSRID(ST_MakePoint(longitudine, latitudine), 4326);

-- Delete rows from the "restaurante" table based on specific names
DELETE FROM restaurante
WHERE nume IN ('Duna', 'Old Kitchen', 'Gulyas house', 'Casa Ungurească', 'Kürtőskalács Colac Unguresc', 'Restaurant Miska', 'Csarda-Sasu', 'Jelen Haz', 'Edesia Bazosu-Nou', 'La Plaja Noua', 'Restaurant Lirami', 'Restaurant Nedeia');

--FUNCTIA 1 - DISTANCE ANALYSIS - START
-- Create a new table to store line geometries and distance values
-- UVT: 21.231577087739772, 45.74714993190031
-- Catedrala: 45.751104777326, 21.224414393004697

CREATE TABLE distance_lines AS
SELECT
    nume,
    ST_MakeLine(
        ST_SetSRID(ST_MakePoint(21.231577087739772, 45.74714993190031), 4326),
        geom
    ) AS line_geom,
    ST_Distance(
        ST_SetSRID(ST_MakePoint(21.231577087739772, 45.74714993190031), 4326)::geography,
        ST_SetSRID(ST_MakePoint(longitudine, latitudine), 4326)::geography
    ) AS distance
FROM
    restaurante;
	
-- Optional: Drop the distance_lines table to recompute
DROP TABLE IF EXISTS distance_lines;

--FUNCTIA 1 - DISTANCE ANALYSIS - STOP

--FUNCTIA 2 - HEATMAP - START
-- Step 1: Aggregate the points and calculate the count for each grid cell
-- The grid cells are created by snapping the points to a grid size of 0.001 (adjust as needed)
SELECT ST_SetSRID(ST_Collect(geom), 4326) AS geom, COUNT(*) AS count INTO heatmap_data FROM restaurante GROUP BY ST_SnapToGrid(geom, 0.001);

-- Step 2: Union the buffered geometries and calculate the intensity for each cell
-- The buffer size of 0.01 (1km) or 0.005 (500m) determines the radius of influence for each cell (adjust as needed)
SELECT ST_Union(ST_Buffer(geom, 0.005)) AS geom, MAX(count) AS max_count INTO heatmap_data_union FROM heatmap_data;

-- Optional: Drop the heatmap_data_union table to recomupute
DROP TABLE IF EXISTS heatmap_data_union;

-- Step 4: Drop the heatmap_data & heatmap_points table
DROP TABLE IF EXISTS heatmap_data;
DROP TABLE IF EXISTS heatmap_points;
--FUNCTIA 2 - HEATMAP - STOP

--FUNCTIA 3 - CENTRAL RESTAURANTS - START
-- Create a new table to store the filtered restaurants within the polygon
CREATE TABLE central_zone_restaurants AS
    SELECT *
    FROM restaurante
    WHERE ST_Within(geom, ST_GeomFromText('POLYGON((21.224727449229587 45.75724026946334, 21.22522815375583 45.75425490741152, 21.231676621139247 45.753302098669415, 21.23240491863196 45.758806991316575, 21.227944096489082 45.75957975008471, 21.224727449229587 45.75724026946334))', 4326));

-- Create a spatial index for improved query performance (optional)
CREATE INDEX idx_central_zone_restaurants_geom ON central_zone_restaurants USING gist(geom);
--FUNCTIA 3 - CENTRAL RESTAURANTS - STOP

--FUNCTIA 4 - POLY & COVERED SURFACE FROM RESTAURANTS - START
-- Create a polygon by calculating the convex hull of the points
CREATE TABLE restaurant_polygon AS
SELECT ST_ConvexHull(ST_Collect(geom)) AS geom
FROM restaurante;

-- Add a column to store the surface area in hectares
ALTER TABLE restaurant_polygon ADD COLUMN surface_area double precision;

-- Update the surface area column with the calculated value
UPDATE restaurant_polygon
SET surface_area = ST_Area(geom::geography) / 10000.0; -- Divide by 10000 to convert square meters to hectares
--FUNCTIA 4 - POLY & COVERED SURFACE FROM RESTAURANTS - STOP


--FUNCTIA 5 - RESTARURANTS IN NEIGHBORHOODS - START
--FUNCTIA 5 - RESTARURANTS IN NEIGHBORHOODS - STOP