# DATABASES

# 1 - SUMMARY
Analyze restaurant distribution and coverage in a specific area using spatial data and visualization techniques. Gain insights into restaurant density, neighborhood boundaries, and overall coverage.

# 2 - ENTITIES
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

# 3 - STEPS
1. Create a new online repository on GitHub.com;
2. Clore the newly created repository using GitHub Desktop;
3. Insert representative files for the project at the right path (.SQL files);
4. Execute push & commit via GitHub Desktop.
