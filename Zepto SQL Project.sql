DROP TABLE IF EXISTS zepto;

CREATE TABLE zepto (
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,	
quantity INTEGER
);

INSERT INTO zepto (category, name, mrp, discountPercent, availableQuantity, discountedSellingPrice, weightInGms, outOfStock, quantity)
SELECT category, name, mrp, discountPercent, availableQuantity, discountedSellingPrice, weightInGms, 
	CASE
		WHEN outOfStock = 'TRUE' THEN 1
        WHEN outOfStock = 'FALSE' THEN 0
        ELSE NULL
	END,
quantity
FROM zepto_v2;

-- Data Exploration

-- count of rows
SELECT COUNT(*) FROM zepto;

-- sample data
SELECT * FROM zepto
LIMIT 10;

-- null values
SELECT * FROM zepto
WHERE name IS NULL
OR
category IS NULL
OR
mrp IS NULL
OR
discountPercent IS NULL
OR
discountedSellingPrice IS NULL
OR
weightInGms IS NULL
OR
availableQuantity IS NULL
OR
outOfStock IS NULL
OR
quantity IS NULL;

-- different product categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;

-- product in stock vs out of stock
SELECT outOfStock, count(sku_id)
FROM zepto
GROUP BY outOfStock;

-- product names present multiple times
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY COUNT(sku_id) DESC;

-- DATA CLEANING
-- products with price = 0
SELECT * FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;

DELETE FROM zepto
WHERE mrp = 0;

-- conver paise to rupees
UPDATE zepto
SET mrp = mrp / 100,
discountedSellingPrice = discountedSellingPrice / 100;

SELECT mrp, discountedSellingPrice FROM zepto;

-- DATA ANALYSIS

-- Q1) Find the top 10 best-value products based on the discount percentage.
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;
-- top 10 products have discount of 50% or more. That's massive discounts. useful for both customers and businesses to know which products are being heavily promoted

-- Q2) What are the Products with High MRP but Out of Stock
SELECT DISTINCT name, mrp
FROM zepto
WHERE outOfStock = 1 AND mrp > 300
ORDER BY mrp DESC;
-- these are high priced products and the company might want to restock them as soon as possible if the customers are buying them frequently 

-- Q3) Calculate Estimated Revenue for each category
SELECT category,
SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto 
GROUP BY category
ORDER BY total_revenue;
---

-- Q4) Find all products where MRP is greater than ₹500 and discount is less than 10%.
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;
-- reaso these products dont have any discounts is because these items are popular enough and sell well without any discounts

-- Q5) Identify the top 5 categories offering the highest average discount percentage.
SELECT category,
ROUND(AVG(discountPercent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;
-- useful for marketing teams to understand where price cuts are happening the most. basically in which product categories price cuts are the most and how they can optimize them accordingly

-- Q6) Find the price per gram for products above 100g and sort by best value.
SELECT DISTINCT name, weightInGms, discountedSellingPrice,
ROUND(discountedSellingPrice/weightInGms, 2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;
-- helpful for customers comparing value for money for products and even for internal pricing startegies

-- Q7) Group the products into categories like Low, Medium, Bulk.
SELECT DISTINCT name, weightInGms,
CASE
	WHEN weightInGms < 1000 THEN 'Low'
    WHEN weightInGms < 5000 THEN 'Medium'
    ELSE 'Bulk'
END AS weight_category
FROM zepto;
-- kind of segmentation is helpful for packaging, delhivery, planning, and even bulk order strategies 

-- Q8) What is the Total Inventory Weight Per Category 
SELECT category,
SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;
-- really great for warehouse planning or identify bulky product categories









