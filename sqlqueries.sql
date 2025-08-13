CREATE DATABASE food_wastage;
use food_wastage;
CREATE TABLE providers_data (
    provider_id INT PRIMARY KEY,
    name VARCHAR(100),
    type VARCHAR(500),
    address VARCHAR(255),
    city VARCHAR(500),
    contact VARCHAR(500)
);
CREATE TABLE receivers (
    receiver_id INT PRIMARY KEY,
    name VARCHAR(100),
    type VARCHAR(50),
    city VARCHAR(50),
    contact VARCHAR(50)
);

CREATE TABLE food_listings (
    food_id INT PRIMARY KEY,
    food_name VARCHAR(100),
    quantity INT,
    expiry_date DATE,
    provider_id INT,
    provider_type VARCHAR(50),
    location VARCHAR(50),
    food_type VARCHAR(50),
    meal_type VARCHAR(50),
    FOREIGN KEY (provider_id) REFERENCES providers(provider_id)
);

CREATE TABLE claims (
    claim_id INT PRIMARY KEY,
    food_id INT,
    receiver_id INT,
    status VARCHAR(20),
    timestamp DATETIME,
    FOREIGN KEY (food_id) REFERENCES food_listings(food_id),
    FOREIGN KEY (receiver_id) REFERENCES receivers(receiver_id)
);

select * from providers;
RENAME TABLE providers TO providers_data;




LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/providers_data.csv'
INTO TABLE providers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 1. How many food providers are there in each city?
SELECT city, COUNT(*) AS total_providers
FROM providers_data
GROUP BY city
ORDER BY total_providers DESC;

-- 2.  How many food receivers are there in each city?
SELECT city, COUNT(*) AS total_receivers
FROM receivers_data
GROUP BY city
ORDER BY total_receivers DESC;

-- 3. Which type of food provider contributes the most food listings?
SELECT provider_type, COUNT(*) AS total_listings
FROM food_listings_data
GROUP BY provider_type
ORDER BY total_listings DESC;

-- 4. Contact information of food providers in a specific city
SELECT name, contact,city
FROM providers_data;

-- 5. Which receivers have claimed the most food?
SELECT r.name, COUNT(c.claim_id) AS total_claims
FROM claims_data c
JOIN receivers_data r ON c.receiver_id = r.receiver_id
GROUP BY r.name
ORDER BY total_claims DESC;


-- 6. Total quantity of food available from all providers
SELECT SUM(quantity) AS total_food_quantity
FROM food_listings_data;


-- 7. Which city has the highest number of food listings?
SELECT location , COUNT(*) AS total_listings
FROM food_listings_data
GROUP BY location
ORDER BY total_listings DESC
LIMIT 1;


-- 8. Most commonly available food types
SELECT Food_Type, COUNT(*) AS type_count
FROM food_listings_data
GROUP BY food_type
ORDER BY type_count DESC
LIMIT 1;

-- 9. How many food claims have been made for each food item?
SELECT f.food_name, COUNT(c.claim_id) AS total_claims
FROM claims_data c
JOIN food_listings_data f ON c.food_id = f.food_id
GROUP BY f.food_name
ORDER BY total_claims DESC
LIMIT 7;


-- 10. Which provider has had the highest number of successful (Completed) food claims?
SELECT p.name, COUNT(c.claim_id) AS successful_claims
FROM claims_data c
JOIN food_listings_data f ON c.food_id = f.food_id
JOIN providers_data p ON f.provider_id = p.provider_id
WHERE c.status = 'Completed'
GROUP BY p.name
ORDER BY successful_claims DESC
LIMIT 1;


-- 11. Percentage of claims by status (Completed, Pending, Cancelled)
SELECT status,
       ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM claims_data)), 2) AS percentage
FROM claims_data
GROUP BY status;


-- 12. Average quantity of food claimed per receiver
SELECT r.name, ROUND(AVG(f.quantity), 2) AS avg_quantity_claimed
FROM claims_data c
JOIN receivers_data r ON c.receiver_id = r.receiver_id
JOIN food_listings_data f ON c.food_id = f.food_id
GROUP BY r.name
ORDER BY avg_quantity_claimed DESC;


-- 13. Which meal type is claimed the most?
SELECT f.meal_type, COUNT(c.claim_id) AS total_claims
FROM claims_data c
JOIN food_listings_data f ON c.food_id = f.food_id
GROUP BY f.meal_type
ORDER BY total_claims DESC;


-- 14. Total quantity of food donated by each provider
SELECT p.name, SUM(f.quantity) AS total_quantity_donated
FROM food_listings_data f
JOIN providers_data p ON f.provider_id = p.provider_id
GROUP BY p.name
ORDER BY total_quantity_donated DESC;

-- 15. Top 5 cities with highest demand (most claims)
SELECT f.location AS city, COUNT(c.claim_id) AS total_claims
FROM claims_data c
JOIN food_listings_data f ON c.food_id = f.food_id
GROUP BY f.location
ORDER BY total_claims DESC
LIMIT 5;