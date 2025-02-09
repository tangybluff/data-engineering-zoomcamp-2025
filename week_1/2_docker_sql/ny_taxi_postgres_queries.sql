-- PostgresSQL

-- This is an older INNER JOIN query
SELECT
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	total_amount,
    CONCAT(zpu."Borough", ' | ', zpu."Zone") AS "pickup_loc",
    CONCAT(zdo."Borough", ' | ', zdo."Zone") AS "dropff_loc"
FROM
	yellow_taxi_trips t,
	zones zpu,
	zones zdo
WHERE
	t."PULocationID" = zpu."LocationID" AND
	t."DOLocationID" = zdo."LocationID"
LIMIT 100;


-- We write the same query but with a JOIN operator
SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    total_amount,
    CONCAT(zpu."Borough", ' | ', zpu."Zone") AS "pickup_loc",
    CONCAT(zdo."Borough", ' | ', zdo."Zone") AS "dropff_loc"
FROM 
    yellow_taxi_trips t
JOIN 
-- or INNER JOIN but it's less used, when writing JOIN postgreSQL undranstands implicitly that we want to use an INNER JOIN
    zones zpu ON t."PULocationID" = zpu."LocationID"
JOIN
    zones zdo ON t."DOLocationID" = zdo."LocationID"
LIMIT 100;


-- Checking for NULLS 
SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    total_amount,
    "PULocationID",
    "DOLocationID"
FROM 
    yellow_taxi_trips t
WHERE
    "PULocationID" IS NULL
    OR "DOLocationID" IS NULL
LIMIT 100;


-- Delete records to then demonstrate other kinds of JOINs
DELETE
FROM
    zones
WHERE
    "LocationID" = 142;


-- Script will check for whatever isn't present within our database
SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    total_amount,
    "PULocationID",
    "DOLocationID"
FROM 
    yellow_taxi_trips t
WHERE
--    "DOLocationID" NOT IN (SELECT "LocationID" from zones)
--    OR
    "PULocationID" NOT IN (SELECT "LocationID" from zones)
LIMIT 100;


-- Deleting a record
DELETE FROM zones WHERE "LocationID" = 142;


-- LEFT JOIN query
SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    total_amount,
    CONCAT(zpu."Borough", ' | ', zpu."Zone") AS "pickup_loc",
    CONCAT(zdo."Borough", ' | ', zdo."Zone") AS "dropff_loc"
FROM 
    yellow_taxi_trips t
LEFT JOIN 
    zones zpu ON t."PULocationID" = zpu."LocationID"
JOIN
    zones zdo ON t."DOLocationID" = zdo."LocationID"
LIMIT 100;


-- RIGHT JOIN query
SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    total_amount,
    CONCAT(zpu."Borough", ' | ', zpu."Zone") AS "pickup_loc",
    CONCAT(zdo."Borough", ' | ', zdo."Zone") AS "dropff_loc"
FROM 
    yellow_taxi_trips t
RIGHT JOIN 
    zones zpu ON t."PULocationID" = zpu."LocationID"
JOIN
    zones zdo ON t."DOLocationID" = zdo."LocationID"
LIMIT 100;


-- OUTER JOIN query 
SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    total_amount,
    CONCAT(zpu."Borough", ' | ', zpu."Zone") AS "pickup_loc",
    CONCAT(zdo."Borough", ' | ', zdo."Zone") AS "dropff_loc"
FROM 
    yellow_taxi_trips t
OUTER JOIN 
    zones zpu ON t."PULocationID" = zpu."LocationID"
JOIN
    zones zdo ON t."DOLocationID" = zdo."LocationID"
LIMIT 100;


-- GROUP BY to calculate trips per day
SELECT
    CAST(tpep_dropoff_datetime AS DATE) AS "day",
    COUNT(1)
FROM 
    yellow_taxi_trips t
GROUP BY
    CAST(tpep_dropoff_datetime AS DATE)
LIMIT 100;


-- Ordering by DAY
SELECT
    CAST(tpep_dropoff_datetime AS DATE) AS "day",
    COUNT(1)
FROM 
    yellow_taxi_trips t
GROUP BY
    CAST(tpep_dropoff_datetime AS DATE)
ORDER BY
    "day" ASC
LIMIT 100;

-- Ordering by COUNT
SELECT
    CAST(tpep_dropoff_datetime AS DATE) AS "day",
    COUNT(1) AS "count"
FROM 
    yellow_taxi_trips t
GROUP BY
    CAST(tpep_dropoff_datetime AS DATE)
ORDER BY
    "count" DESC
LIMIT 100;


-- Other types of aggregations
SELECT
    CAST(tpep_dropoff_datetime AS DATE) AS "day",
    COUNT(1) AS "count",
    MAX(total_amount) AS "total_amount",
    MAX(passenger_count) AS "passenger_count"
FROM 
    yellow_taxi_trips t
GROUP BY
    CAST(tpep_dropoff_datetime AS DATE)
ORDER BY
    "count" DESC
LIMIT 100;


-- Grouping by multiple fields
SELECT
    CAST(tpep_dropoff_datetime AS DATE) AS "day",
    "DOLocationID",
    COUNT(1) AS "count",
    MAX(total_amount) AS "total_amount",
    MAX(passenger_count) AS "passenger_count"
FROM 
    yellow_taxi_trips t
GROUP BY
    1, 2
ORDER BY
    "day" ASC, 
    "DOLocationID" ASC
LIMIT 100;

-- GROUP BY is the workhorse for all analytics usually accompanied by JOINs
