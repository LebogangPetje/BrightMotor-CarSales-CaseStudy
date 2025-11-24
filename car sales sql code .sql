---main code 
SELECT 
    sellingprice,
    state,
    color,
    interior,
---to add column to use for values     
1 AS value_column,
---car age
    (sale_year - year) AS vehicle_age,

CASE
   WHEN transmission IS NULL THEN 'unspecified'
   ELSE transmission 
END AS transmission_clean,

    
---case for make categoriess 
CASE 
    WHEN make IN ('Airstream', 'Buick', 'Cadillac', 'Chevrolet', 'Chrysler', 'Dodge', 'Fisker', 'Ford', 'GMC', 'Hummer', 'Jeep', 'Lincoln', 'Mercury', 'Oldsmobile', 'Plymouth', 'Pontiac', 'Ram', 'Saturn', 'Tesla') THEN 'United States'  
    WHEN make IN ('Acura', 'Honda', 'Infiniti', 'Isuzu', 'Lexus', 'Mazda', 'Mitsubishi', 'Nissan', 'Subaru', 'Suzuki', 'Toyota') THEN 'Japan'
    WHEN make IN ('Audi', 'BMW', 'Mercedes-Benz', 'Porsche', 'Volkswagen', 'Smart', 'MINI') THEN 'Germany'
    WHEN make IN ('Ferrari', 'FIAT', 'Lamborghini', 'Maserati') THEN 'Italy'
    WHEN make IN ('Aston Martin', 'Bentley', 'Jaguar', 'Land Rover', 'Lotus', 'Rolls-Royce') THEN 'United Kingdom'
    WHEN make IN ('Hyundai', 'Kia', 'Daewoo') THEN 'South Korea'
    WHEN make IN ('Saab', 'Volvo') THEN 'Sweden'
ELSE 'Other'
END AS country_category,

---case statement for car classification 
CASE
    WHEN make IN ('Acura', 'Aston Martin', 'Audi', 'Bentley', 'BMW', 'Cadillac', 'Ferrari', 'Infiniti', 'Jaguar', 'Land Rover', 'Lexus', 'Lincoln', 'Maserati', 'Mercedes-Benz', 'Porsche', 'Rolls-Royce') THEN 'Premium Brands'
    WHEN make IN ('Airstream', 'Buick', 'Chevrolet', 'Chrysler', 'Daewoo', 'Dodge', 'FIAT', 'Fisker', 'Ford', 'GMC', 'Honda', 'Hyundai', 'Isuzu', 'Jeep', 'Kia', 'Mazda', 'MINI', 'Mitsubishi', 'Nissan', 'Pontiac', 'Ram', 'Saab', 'Saturn', 'Scion', 'Smart', 'Subaru', 'Suzuki', 'Tesla', 'Toyota', 'Volkswagen', 'Volvo') THEN 'Mainstream Brands'
ELSE 'Other'
END AS car_classification,

---mmmr is the global wholesale price, can use this to check eith selling price is lower, higher or equal to market value 

CASE 
    WHEN sellingprice > mmr THEN 'above market'
    WHEN sellingprice < mmr THEN 'below market'
ELSE 'at market'
END AS marketprice_evaluation,

CASE 
    WHEN condition BETWEEN 40 AND 49 THEN 'excellent'
    WHEN condition BETWEEN 20 AND 39 THEN 'average'
ELSE 'poor'
END AS condition_bucket,

CASE 
  WHEN body IN ('Coupe', 'Genesis Coupe', 'G Coupe', 'G37 Coupe', 'Q60 Coupe', 'CTS Coupe', 'CTS-V Coupe', 'Elantra Coupe', 'Koup') THEN 'Coupe'
  WHEN body IN ('Sedan','G Sedan') THEN 'Sedan'
  WHEN body IN ('SUV') THEN 'suv'
  WHEN body IN ('Van', 'Transit Van', 'E-Series Van', 'Ram Van', 'Promaster Cargo Van', 'Cargo Van', 'Minivan') THEN 'Van'
  WHEN body IN ('Convertible', 'G Convertible', 'G37 Convertible', 'Q60 Convertible', 'GranTurismo Convertible', 'Beetle Convertible') THEN 'convertible'
  WHEN body IN ('Wagon', 'TSX Sport Wagon', 'CTS Wagon', 'Hatchback') THEN 'Hatchback'
  WHEN body IN ('Regular Cab', 'SuperCab', 'SuperCrew', 'Crew Cab', 'CrewMax Cab', 'Double Cab', 'Quad Cab', 'King Cab', 'Mega Cab', 'Access Cab', 'Xtracab', 'Extended Cab', 'Cab Plus', 'Cab Plus 4', 'Club Cab') THEN 'Cab'
  ELSE 'other'
  END AS body_type,

---weekday vs weekend 
CASE
   WHEN TRIM(UPPER(sale_day)) IN ('SAT','SUN') THEN 'Weekend'
   ELSE 'Weekday'
   END AS day_classification,

----season case statement 
CASE 
 WHEN sale_month IN (12, 1, 2) THEN 'Summer'
 WHEN sale_month IN (3, 4, 5) THEN 'Autumn'
 WHEN sale_month IN (6, 7, 8) THEN 'Winter'
 ELSE 'Spring'
 END AS season_category,

 ----time bucket 
 CASE
  WHEN sale_time BETWEEN '00:00:00' AND '05:59:59' THEN 'Early_morning'
  WHEN sale_time BETWEEN '06:00:00' AND '11:59:59' THEN 'late_morning'
  WHEN sale_time BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
  WHEN sale_time >= '18:00:00' THEN 'Night'
  END AS time_bucket,

 ---milage_bucket (odometer)
--min 1, max 999999, avg 68323 

CASE 
   WHEN odometer BETWEEN 0 AND 45000 THEN 'low'
   WHEN odometer BETWEEN 45001 AND 70000 THEN 'average'
   WHEN odometer BETWEEN 70001 AND 100000 THEN 'high'
   ELSE 'ultra high'
END AS milage_bucket,

---vehicle age bucket
CASE 
   WHEN vehicle_age BETWEEN 0 AND 3 THEN 'new-recent'
   WHEN vehicle_age BETWEEN 4 AND 7 THEN 'mid-age'
   WHEN vehicle_age BETWEEN 8 AND 12 THEN 'older'
ELSE 'very old'
END AS vehicle_age_category


FROM (
    SELECT 
        *,
        to_timestamp(trim(saledate), 'DY MON DD YYYY HH24:MI:SS') AS ts,
        EXTRACT(DAY FROM to_timestamp(trim(saledate), 'DY MON DD YYYY HH24:MI:SS')) AS sale_day,
        EXTRACT(MONTH FROM to_timestamp(trim(saledate), 'DY MON DD YYYY HH24:MI:SS')) AS sale_month,
        EXTRACT(YEAR FROM to_timestamp(trim(saledate), 'DY MON DD YYYY HH24:MI:SS')) AS sale_year,
        TO_CHAR(to_timestamp(trim(saledate), 'DY MON DD YYYY HH24:MI:SS'), 'HH24:MI:SS') AS sale_time,
        TO_CHAR(to_timestamp(trim(saledate), 'DY MON DD YYYY HH24:MI:SS'), 'DY') AS sale_dayname
    FROM car.public.sales
) s


GROUP BY
    transmission,
    state, 
    color, 
    year,
    sale_year,
    make,
    mmr, 
    condition, 
    body, 
    odometer,
    sale_day, 
    sale_month, 
    sale_year,
    sale_time, 
    transmission_clean,
    sale_dayname,
    sellingprice,
    interior     
    
ORDER BY
    sellingprice,
    state,
    color;


-----END OF MAIN CODE 




----UNDERSTANDING DATA 

SELECT *
FROM car.public.sales;

SELECT 1 AS value_column
from car.public.sales;


--RANGES:
---min 1,avg 30, max 49
SELECT MIN(CONDITION) AS min_condition
FROM car.public.sales;


---min 1, max 230000, avg 13611
SELECT min(sellingprice) as min_sellingprice
FROM car.public.sales;

---min 1982, max 2015, avg 2010
SELECT avg(year) as min_year
FROM car.public.sales;
 --min 1, max 999999, avg 68323  
SELECT avg(odometer) as min_odometer
FROM car.public.sales;

--- the mmr is a metric for indicating the wholesale price across the industry 
--- min 25, max 182000, avg 13769
SELECT avg(mmr) as min_mmr
FROM car.public.sales;


---distinct 

---97 diff cars 
select distinct make
from car.public.sales;

--- trim ke eng?
select distinct trim
from car.public.sales;

--- 87 body
select distinct body
from car.public.sales;

--- automatric, manual, change null to unspecified 
select distinct transmission 
from car.public.sales;

select distinct seller
from car.public.sales;




