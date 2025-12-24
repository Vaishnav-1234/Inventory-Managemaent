--Table Formation 

CREATE TABLE inventory_records (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,

    opening_stock INTEGER NOT NULL CHECK (opening_stock >= 0),
    purchase_stock INTEGER NOT NULL CHECK (purchase_stock >= 0),
    units_sold INTEGER NOT NULL CHECK (units_sold >= 0),

    hand_in_stock INTEGER NOT NULL CHECK (hand_in_stock >= 0),

    cost_price_per_unit NUMERIC(10,2) NOT NULL CHECK (cost_price_per_unit >= 0),
    cost_price_total NUMERIC(12,2) NOT NULL CHECK (cost_price_total >= 0)
	);

--Retrieve all product records

Select * from inventory_records;

--Display Product Name and Units Sold.

SELECT Product_name,units_sold from inventory_records;

--Find products where Units Sold = 0

SELECT Product_name,units_sold from inventory_records
where units_sold = 0;

--Count total number of products

select count(product_id) as Total_Product_count from inventory_records;

--Order products by highest Units Sold

select product_name,units_sold from inventory_records
Order by Units_sold Desc;

--Calculate Hand-in-Stock

select product_name,opening_stock+Purchase_stock-units_sold 
	as calculated_stock 
	from inventory_records;

--Find products with Hand-in-Stock < 20

select product_name,Hand_In_Stock from inventory_records
where hand_in_stock < 20;

--Calculate total inventory cost

select sum(cost_price_total) as Total_Inventory_Cost from inventory_records;
	
--Group products by Product Name and sum Units Sold
 
select product_name,sum(units_sold) as Total_unit from inventory_records
Group by product_name;

--Find average Cost Price Per Unit

SELECT AVG(cost_price_per_unit) as avg_cost_price from inventory_records;

--Identify products with negative stock

select product_name,hand_in_stock from inventory_records
where hand_in_stock < 0;

--top 5 products by total cost value

select product_name,cost_price_total from inventory_records
order by cost_price_total desc limit 5;

--Add a column showing Stock Status

select product_name,hand_in_stock,
case
when hand_in_stock < 20 then 'low stock'
else 'normal stock'
end as stock_status
from inventory_records;

--Validate stock logic by comparing calculated vs stored Hand-in-Stock

select product_name,hand_in_stock,
(opening_stock+Purchase_stock-units_sold) as calculated_stock,
case
when hand_in_stock = (opening_stock+Purchase_stock-units_sold)
then 'correct'
else 'mismatch'
end as validation_status
from inventory_records;

--stock utilization %

select product_name,
round(units_sold::DECIMAL / (opening_stock + purchase_stock) * 100, 2)
as stock_utilization_pct from inventory_records;

--Identify products contributing to top 80% inventory cost

select * from
(select
	product_name,cost_price_total,
	sum(cost_price_total) over () as total_cost,
	sum(cost_price_total) over (order by cost_price_total desc) as running_cost
	from inventory_records
	) t
where running_cost<=total_cost*0.8;

--Rank products by Units Sold

SELECT 
    product_name,
    units_sold,
    RANK() OVER (ORDER BY units_sold DESC) AS sales_rank
FROM inventory_records;

--CTE for Inventory KPIs

WITH inventory_kpi AS (
    SELECT 
        COUNT(*) AS total_products,
        SUM(units_sold) AS total_units_sold,
        SUM(cost_price_total) AS total_inventory_value
    FROM inventory_records
)
SELECT * FROM inventory_kpi;

--Identify slow-moving products

SELECT *
FROM inventory_records
WHERE units_sold < (
    SELECT AVG(units_sold)
    FROM inventory_records
);

--Re-order recommendation query

SELECT 
    product_name,
    hand_in_stock,
    units_sold,
    CASE
        WHEN hand_in_stock < 20 AND units_sold > (
            SELECT AVG(units_sold) FROM inventory_records
        )
        THEN 'Reorder Immediately'
        ELSE 'No Action'
    END AS reorder_status
FROM inventory_records;

