
CREATE DATABASE RetailChainDB;
USE RetailChainDB;

-- ======================================================
-- TABLE CREATION (DDL)
-- ======================================================

-- 1. STORE
CREATE TABLE Store (
    store_id INT PRIMARY KEY AUTO_INCREMENT,
    store_name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    region VARCHAR(50)
);

-- 2. MANAGER
CREATE TABLE Manager (
    manager_id INT PRIMARY KEY AUTO_INCREMENT,
    manager_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(100) UNIQUE,
    store_id INT,
    FOREIGN KEY (store_id) REFERENCES Store(store_id)
);

-- 3. STAFF
CREATE TABLE Staff (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    staff_name VARCHAR(100) NOT NULL,
    role VARCHAR(50),
    phone VARCHAR(15),
    email VARCHAR(100) UNIQUE,
    store_id INT,
    manager_id INT,
    FOREIGN KEY (store_id) REFERENCES Store(store_id),
    FOREIGN KEY (manager_id) REFERENCES Manager(manager_id)
);

-- 4. CUSTOMER
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100) UNIQUE,
    loyalty_points INT DEFAULT 0
);

-- 5. SUPPLIER
CREATE TABLE Supplier (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(100),
    contact_email VARCHAR(100),
    contact_phone VARCHAR(15)
);

-- 6. PRODUCT
CREATE TABLE Product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    supplier_id INT,
    price DECIMAL(10,2),
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
);

-- 7. DISCOUNT
CREATE TABLE Discount (
    discount_id INT PRIMARY KEY AUTO_INCREMENT,
    discount_name VARCHAR(100),
    discount_percent DECIMAL(5,2) CHECK (discount_percent BETWEEN 0 AND 100),
    start_date DATE,
    end_date DATE
);

-- 8. INVENTORY
CREATE TABLE Inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    store_id INT,
    product_id INT,
    quantity_in_stock INT DEFAULT 0,
    FOREIGN KEY (store_id) REFERENCES Store(store_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- 9. DELIVERY
CREATE TABLE Delivery (
    delivery_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_id INT,
    store_id INT,
    delivery_date DATE,
    product_id INT,
    quantity_delivered INT,
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id),
    FOREIGN KEY (store_id) REFERENCES Store(store_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- 10. SALES
CREATE TABLE Sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    store_id INT,
    customer_id INT,
    staff_id INT,
    sale_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (store_id) REFERENCES Store(store_id),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
);

-- 11. SALES DETAILS
CREATE TABLE SalesDetails (
    sale_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    sale_id INT,
    product_id INT,
    quantity INT,
    discount_id INT,
    effective_price DECIMAL(10,2),
    FOREIGN KEY (sale_id) REFERENCES Sales(sale_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id),
    FOREIGN KEY (discount_id) REFERENCES Discount(discount_id)
);

CREATE TABLE SupplierInventory (
    supplier_inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_id INT,
    product_id INT,
    quantity_in_stock INT DEFAULT 0,
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- ======================================================
-- INSERT VALUES (10 PER TABLE)
-- ======================================================

-- STORE
INSERT INTO Store (store_name, location, region) VALUES
('MegaMart Koramangala', 'Bangalore', 'South'),
('MegaMart Indiranagar', 'Bangalore', 'South'),
('MegaMart Whitefield', 'Bangalore', 'South'),
('MegaMart Pune Central', 'Pune', 'West'),
('MegaMart Mumbai West', 'Mumbai', 'West'),
('MegaMart Delhi East', 'Delhi', 'North'),
('MegaMart Hyderabad City', 'Hyderabad', 'South'),
('MegaMart Ahmedabad Mall', 'Ahmedabad', 'West'),
('MegaMart Kochi Harbour', 'Kochi', 'South'),
('MegaMart Kolkata Plaza', 'Kolkata', 'East');

-- MANAGER
INSERT INTO Manager (manager_name, phone, email, store_id) VALUES
('Ravi Sharma', '9876543210', 'ravi@megamart.com', 1),
('Priya Menon', '9876501234', 'priya@megamart.com', 2),
('Anil Nair', '9123456780', 'anil@megamart.com', 3),
('Rohit Singh', '9998887776', 'rohit@megamart.com', 4),
('Neha Gupta', '9812312345', 'neha@megamart.com', 5),
('Suresh Reddy', '9812349876', 'suresh@megamart.com', 6),
('Kavita Rao', '9822113344', 'kavita@megamart.com', 7),
('Mona Joshi', '9876540099', 'mona@megamart.com', 8),
('Ritika Basu', '9898989898', 'ritika@megamart.com', 9),
('Arjun Patel', '9876001122', 'arjun@megamart.com', 10);

-- STAFF
INSERT INTO Staff (staff_name, role, phone, email, store_id, manager_id) VALUES
('Karan', 'Cashier', '9988776655', 'karan@megamart.com', 1, 1),
('Sneha', 'Sales Associate', '9876123456', 'sneha@megamart.com', 2, 2),
('Ravi Kumar', 'Cashier', '9898771122', 'ravi.kumar@megamart.com', 3, 3),
('Ananya', 'Sales Lead', '9823456789', 'ananya@megamart.com', 4, 4),
('Rajesh', 'Cashier', '9977554433', 'rajesh@megamart.com', 5, 5),
('Asha', 'Cashier', '9786001122', 'asha@megamart.com', 6, 6),
('Rohan', 'Sales Associate', '9755543322', 'rohan@megamart.com', 7, 7),
('Sana', 'Inventory Clerk', '9888800011', 'sana@megamart.com', 8, 8),
('Manoj', 'Cashier', '9911998877', 'manoj@megamart.com', 9, 9),
('Divya', 'Sales Executive', '9822212345', 'divya@megamart.com', 10, 10);

-- CUSTOMER
INSERT INTO Customer (customer_name, phone, email, loyalty_points) VALUES
('Aarav Patel', '9123456789', 'aarav@gmail.com', 20),
('Diya Kapoor', '9876541230', 'diya@gmail.com', 45),
('Ishaan Rao', '9090909090', 'ishaan@gmail.com', 30),
('Meera Iyer', '9887766554', 'meera@gmail.com', 15),
('Aditya Desai', '9776655443', 'aditya@gmail.com', 60),
('Rohan Shetty', '9445566677', 'rohan.shetty@gmail.com', 10),
('Tanya Jain', '9888776655', 'tanya.jain@gmail.com', 35),
('Kunal Mehta', '9677889900', 'kunal.mehta@gmail.com', 50),
('Nisha Dsouza', '9765432199', 'nisha.dsouza@gmail.com', 25),
('Harshad Patel', '9898765432', 'harshad.patel@gmail.com', 60);

-- SUPPLIER
INSERT INTO Supplier (supplier_name, contact_email, contact_phone) VALUES
('FreshSupplies Ltd', 'fresh@supplies.com', '9988007766'),
('DailyGoods Pvt Ltd', 'daily@goods.com', '8877665544'),
('FoodBase Distributors', 'foodbase@dist.com', '9099099099'),
('GreenGrocers Pvt Ltd', 'green@grocers.com', '9123456677'),
('UrbanFoods Supply', 'urban@foods.com', '9080706050'),
('NutriFresh Distributors', 'nutrifresh@dist.com', '9998887771'),
('DailyDelights Ltd', 'delight@daily.com', '9111002211'),
('Farm2Store Logistics', 'farm2store@logi.com', '9888997766'),
('VeggieExpress', 'veggie@express.com', '9898098098'),
('AgroWorld Ltd', 'agro@world.com', '9777788888');

-- PRODUCT
INSERT INTO Product (product_name, category, supplier_id, price) VALUES
('Milk 1L', 'Dairy', 1, 45.00),
('Bread', 'Bakery', 2, 35.00),
('Butter 500g', 'Dairy', 1, 220.00),
('Rice 5kg', 'Grocery', 3, 450.00),
('Pasta 1kg', 'Grocery', 3, 190.00),
('Cheese 200g', 'Dairy', 1, 150.00),
('Eggs 12pc', 'Poultry', 4, 90.00),
('Cereal 1kg', 'Grocery', 2, 250.00),
('Cake 1kg', 'Bakery', 2, 500.00),
('Cooking Oil 1L', 'Grocery', 5, 210.00);

-- DISCOUNT
INSERT INTO Discount (discount_name, discount_percent, start_date, end_date) VALUES
('Festive Offer', 10.00, '2025-10-01', '2025-10-20'),
('Weekend Sale', 5.00, '2025-10-05', '2025-10-10'),
('Member Discount', 15.00, '2025-10-01', '2025-12-31'),
('Summer Saver', 8.00, '2025-05-01', '2025-05-15'),
('Monsoon Offer', 12.00, '2025-07-01', '2025-07-20'),
('Diwali Bonanza', 20.00, '2025-11-01', '2025-11-10'),
('Loyalty Bonus', 5.00, '2025-10-01', '2025-12-31'),
('Clearance Sale', 30.00, '2025-12-15', '2025-12-31'),
('New Year Sale', 25.00, '2025-12-25', '2026-01-05'),
('Big Billion Sale', 18.00, '2025-09-10', '2025-09-15');

-- INVENTORY
INSERT INTO Inventory (store_id, product_id, quantity_in_stock) VALUES
(1,1,200),(1,2,150),(1,3,100),(2,4,80),(3,5,120),(4,6,130),(5,7,100),(6,8,75),(7,9,90),(8,10,110);

-- DELIVERY
INSERT INTO Delivery (supplier_id, store_id, delivery_date, product_id, quantity_delivered) VALUES
(1,1,'2025-10-01',1,50),(2,2,'2025-10-02',2,60),(3,3,'2025-10-03',4,40),
(4,4,'2025-10-04',7,55),(5,5,'2025-10-05',10,70),(6,6,'2025-10-06',8,65),
(7,7,'2025-10-07',6,75),(8,8,'2025-10-08',5,90),(9,9,'2025-10-09',3,50),(10,10,'2025-10-10',9,45);

-- SALES
INSERT INTO Sales (store_id, customer_id, staff_id, sale_date, total_amount) VALUES
(1,1,1,'2025-10-08',500.00),(2,2,2,'2025-10-09',850.00),(3,3,3,'2025-10-09',700.00),
(4,4,4,'2025-10-09',620.00),(5,5,5,'2025-10-10',900.00),(6,6,6,'2025-10-10',400.00),
(7,7,7,'2025-10-10',560.00),(8,8,8,'2025-10-11',450.00),(9,9,9,'2025-10-11',750.00),(10,10,10,'2025-10-11',1000.00);

-- SALES DETAILS
INSERT INTO SalesDetails (sale_id, product_id, quantity, discount_id, effective_price) VALUES
(1,1,5,1,202.50),(2,2,3,2,99.75),(3,4,2,3,382.50),(4,5,4,4,698.00),(5,6,3,5,396.00),
(6,7,1,6,72.00),(7,8,2,7,475.00),(8,9,1,8,350.00),(9,10,3,9,472.50),(10,3,5,10,902.00);

INSERT INTO SupplierInventory (supplier_id, product_id, quantity_in_stock) VALUES
(1, 1, 200),  -- FreshSupplies Ltd has 200 units of Milk
(1, 3, 100),  -- same supplier has 100 Butter
(2, 2, 150),  -- DailyGoods Pvt Ltd has 150 Bread
(3, 4, 300),  -- FoodBase Distributors has 300 Rice
(3, 5, 250),  -- same supplier has 250 Pasta
(4, 7, 180),  -- GreenGrocers Pvt Ltd has 180 Eggs
(5, 10, 220), -- UrbanFoods Supply has 220 Cooking Oil
(2, 8, 140),  -- DailyGoods has 140 Cereal
(9, 9, 190),  -- VeggieExpress has 190 Cake
(6, 6, 170);  -- NutriFresh has 170 Cheese


-- ======================================================
-- TRIGGERS
-- ======================================================
DROP TRIGGER IF EXISTS trg_update_inventory_after_sale;

DELIMITER //

CREATE TRIGGER trg_update_inventory_after_sale
BEFORE INSERT ON SalesDetails
FOR EACH ROW
BEGIN
    DECLARE available_stock INT;

    -- Get current stock for the product in the respective store
    SELECT quantity_in_stock 
    INTO available_stock
    FROM Inventory 
    WHERE product_id = NEW.product_id
      AND store_id = (SELECT store_id FROM Sales WHERE sale_id = NEW.sale_id);

    -- If not enough stock, stop the insert
    IF available_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Insufficient stock for this product!';
    END IF;

    -- Otherwise, reduce the stock
    UPDATE Inventory
    SET quantity_in_stock = quantity_in_stock - NEW.quantity
    WHERE product_id = NEW.product_id
      AND store_id = (SELECT store_id FROM Sales WHERE sale_id = NEW.sale_id);
END //

DELIMITER ;



DELIMITER //
CREATE TRIGGER trg_add_loyalty_points
AFTER INSERT ON Sales
FOR EACH ROW
BEGIN
    UPDATE Customer
    SET loyalty_points = loyalty_points + (NEW.total_amount / 100)
    WHERE customer_id = NEW.customer_id;
END //
DELIMITER ;

CREATE TABLE LowStockLog (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    store_id INT,
    quantity_left INT,
    alert_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER trg_low_stock_alert
AFTER UPDATE ON Inventory
FOR EACH ROW
BEGIN
    IF NEW.quantity_in_stock < 20 THEN
        INSERT INTO LowStockLog (product_id, store_id, quantity_left)
        VALUES (NEW.product_id, NEW.store_id, NEW.quantity_in_stock);
    END IF;
END //
DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_update_inventory_after_delivery
AFTER INSERT ON Delivery
FOR EACH ROW
BEGIN
    -- Check if the product already exists in Inventory for the store
    IF EXISTS (SELECT 1 FROM Inventory 
               WHERE product_id = NEW.product_id AND store_id = NEW.store_id) THEN
        UPDATE Inventory
        SET quantity_in_stock = quantity_in_stock + NEW.quantity_delivered
        WHERE product_id = NEW.product_id AND store_id = NEW.store_id;
    ELSE
        INSERT INTO Inventory (store_id, product_id, quantity_in_stock)
        VALUES (NEW.store_id, NEW.product_id, NEW.quantity_delivered);
    END IF;
END;
//

DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_update_supplier_inventory_after_delivery
AFTER INSERT ON Delivery
FOR EACH ROW
BEGIN
    UPDATE SupplierInventory
    SET quantity_in_stock = quantity_in_stock - NEW.quantity_delivered
    WHERE supplier_id = NEW.supplier_id AND product_id = NEW.product_id;
END //
DELIMITER ;



-- ======================================================
-- PROCEDURES
-- ======================================================

DELIMITER //
CREATE PROCEDURE sp_GetDailySalesReport(IN report_date DATE)
BEGIN
    SELECT s.store_id, st.store_name, SUM(sd.effective_price * sd.quantity) AS total_sales
    FROM Sales s
    JOIN SalesDetails sd USING(sale_id)
    JOIN Store st USING(store_id)
    WHERE s.sale_date = report_date
    GROUP BY s.store_id;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_CheckInventory(IN p_product_id INT)
BEGIN
    SELECT s.store_name, i.quantity_in_stock
    FROM Inventory i
    JOIN Store s USING(store_id)
    WHERE i.product_id = p_product_id;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_ReorderProduct(IN p_product_id INT, IN threshold INT)
BEGIN
    DECLARE qty INT;
    SELECT SUM(quantity_in_stock) INTO qty FROM Inventory WHERE product_id = p_product_id;
    IF qty < threshold THEN
        SELECT '⚠️ Reorder Required' AS Message, p_product_id AS ProductID, qty AS CurrentStock;
    ELSE
        SELECT 'Stock Sufficient' AS Message, qty AS CurrentStock;
    END IF;
END //
DELIMITER ;

-- ======================================================
-- FUNCTIONS
-- ======================================================

DELIMITER //
CREATE FUNCTION fn_GetEffectivePrice(price DECIMAL(10,2), discount_percent DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN price - (price * discount_percent / 100);
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION fn_StockValue(price DECIMAL(10,2), quantity INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN price * quantity;
END //
DELIMITER ;

DELIMITER $$

DELIMITER $$

CREATE FUNCTION fn_SupplierRating(
    delivered INT,
    delayed_count INT
) 
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    RETURN CASE 
        WHEN delivered = 0 THEN 0
        ELSE ((delivered - delayed_count) / CAST(delivered AS DECIMAL(10,2))) * 100
    END;
END$$

DELIMITER ;





-- ======================================================
-- TEST CALLS
-- ======================================================
CALL sp_GetDailySalesReport('2025-10-09');
CALL sp_CheckInventory(3);
CALL sp_ReorderProduct(5, 300);

SELECT fn_GetEffectivePrice(200, 10) AS Discounted_Price;
SELECT fn_StockValue(45.00, 200) AS Stock_Value;
SELECT fn_SupplierRating(100, 5) AS Supplier_Performance;

select *from inventory;
SHOW TABLES;
select * from inventory;
SHOW TRIGGERS;
DROP TRIGGER IF EXISTS trg_update_supplier_inventory_after_delivery;


