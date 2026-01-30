----Task 1: Database Design
CREATE DATABASE telecom_dw;
USE telecom_dw;

use Retail;
CREATE TABLE customers (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    city VARCHAR(50),
    created_at DATE DEFAULT GETDATE()
);


--Task 2: Sample Data & Views

INSERT INTO customers (full_name, email, phone, city) VALUES
('Rahul Sharma','rahul@gmail.com','9000011111','Delhi'),
('Anita Verma','anita@gmail.com','9000022222','Mumbai'),
('Amit Singh','amit@gmail.com','9000033333','Bangalore'),
('Neha Gupta','neha@gmail.com','9000044444','Pune'),
('Suresh Kumar','suresh@gmail.com','9000055555','Chennai');



CREATE TABLE plans (
    plan_id INT IDENTITY(1,1) PRIMARY KEY,
    plan_name VARCHAR(50) NOT NULL,
    monthly_fee DECIMAL(8,2) CHECK (monthly_fee >= 0),
    data_limit_gb INT,
    validity_days INT
);

INSERT INTO plans VALUES
('Basic 199',199,2,28),
('Smart 299',299,5,28),
('Unlimited 499',499,50,28),
('Premium 699',699,100,28),
('Annual Saver',1999,120,365);


CREATE TABLE subscriptions (
    subscription_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) CHECK (status IN ('ACTIVE','SUSPENDED','CANCELLED')),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);

INSERT INTO subscriptions VALUES
(1,1,'2025-01-01',NULL,'ACTIVE'),
(2,3,'2025-01-05',NULL,'ACTIVE'),
(3,2,'2025-01-10',NULL,'ACTIVE'),
(4,4,'2025-01-12',NULL,'SUSPENDED'),
(5,5,'2025-01-15',NULL,'ACTIVE');



CREATE TABLE devices (
    device_id INT IDENTITY(1,1) PRIMARY KEY,
    device_name VARCHAR(100),
    device_type VARCHAR(50),
    price DECIMAL(10,2)
);

INSERT INTO devices (device_name, device_type, price) VALUES
('iPhone 14', 'Smartphone', 69999),
('Samsung Galaxy S23', 'Smartphone', 64999),
('Mi Router AX1800', 'Router', 3999),
('JioFi Dongle', 'Dongle', 2499),
('Apple Watch SE', 'Wearable', 29999);



CREATE TABLE customer_devices (
    customer_id INT,
    device_id INT,
    purchase_date DATE,
    PRIMARY KEY (customer_id, device_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (device_id) REFERENCES devices(device_id)
);

INSERT INTO customer_devices (customer_id, device_id, purchase_date) VALUES
(1, 1, '2025-01-02'),
(1, 5, '2025-01-03'),
(2, 2, '2025-01-06'),
(3, 3, '2025-01-11'),
(4, 4, '2025-01-13'),
(5, 1, '2025-01-16');



CREATE TABLE towers (
    tower_id INT IDENTITY(1,1) PRIMARY KEY,
    location VARCHAR(100),
    city VARCHAR(50)
);

INSERT INTO towers (location, city) VALUES
('Connaught Place', 'Delhi'),
('Andheri East', 'Mumbai'),
('Whitefield', 'Bangalore'),
('Hinjewadi', 'Pune'),
('T Nagar', 'Chennai');


CREATE TABLE usage_records (
    usage_id INT IDENTITY(1,1) PRIMARY KEY,
    subscription_id INT,
    usage_date DATE,
    data_used_mb INT,
    call_minutes INT,
    sms_count INT,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id)
);

INSERT INTO usage_records (subscription_id, usage_date, data_used_mb, call_minutes, sms_count) VALUES
(1, '2025-01-10', 850, 120, 15),
(1, '2025-01-20', 950, 90, 10),
(2, '2025-01-15', 3200, 250, 30),
(3, '2025-01-18', 1800, 150, 20),
(4, '2025-01-22', 500, 60, 5),
(5, '2025-01-25', 4100, 300, 40);


CREATE TABLE invoices (
    invoice_id INT IDENTITY(1,1) PRIMARY KEY,
    subscription_id INT,
    invoice_date DATE,
    amount DECIMAL(10,2),
    paid_status BIT DEFAULT 0,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id)
);

INSERT INTO invoices VALUES
(1,'2025-01-31',199,1),
(2,'2025-01-31',499,1),
(3,'2025-01-31',299,1),
(4,'2025-01-31',699,0),
(5,'2025-01-31',1999,1);


CREATE TABLE payments (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    invoice_id INT,
    payment_date DATE,
    payment_method VARCHAR(30),
    amount DECIMAL(10,2),
    FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id)
);

INSERT INTO payments (invoice_id, payment_date, payment_method, amount) VALUES
(1, '2025-02-01', 'UPI', 199),
(2, '2025-02-01', 'Credit Card', 499),
(3, '2025-02-01', 'Debit Card', 299),
(5, '2025-02-02', 'Net Banking', 1999);


CREATE TABLE support_tickets (
    ticket_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT,
    issue_type VARCHAR(100),
    status VARCHAR(30),
    created_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO support_tickets (customer_id, issue_type, status, created_date) VALUES
(1, 'Network issue', 'Resolved', '2025-01-12'),
(2, 'Billing discrepancy', 'Closed', '2025-01-18'),
(3, 'Slow internet speed', 'In Progress', '2025-01-20'),
(4, 'SIM deactivation', 'Resolved', '2025-01-22'),
(5, 'Plan upgrade request', 'Open', '2025-01-25');


--- TASK 2: VIEW CREATION
-- View 1: Monthly Revenue Summary

CREATE VIEW vw_monthly_revenue
AS
SELECT 
    YEAR(invoice_date) AS revenue_year,
    MONTH(invoice_date) AS revenue_month,
    SUM(amount) AS total_revenue
FROM invoices
GROUP BY YEAR(invoice_date), MONTH(invoice_date);

--View 2: Customer Usage Performance View

CREATE VIEW vw_customer_usage
AS
SELECT 
    c.full_name,
    SUM(u.data_used_mb) AS total_data_used_mb,
    SUM(u.call_minutes) AS total_call_minutes,
    SUM(u.sms_count) AS total_sms_sent
FROM customers c
JOIN subscriptions s ON c.customer_id = s.customer_id
JOIN usage_records u ON s.subscription_id = u.subscription_id
GROUP BY c.full_name;





--- TASK 3: ADVANCED SQL ANALYTICS QUERIES
--Query 1: High-Value Customers (JOIN + GROUP BY + HAVING)
SELECT 
    c.full_name,
    SUM(i.amount) AS total_spent
FROM customers c
JOIN subscriptions s ON c.customer_id = s.customer_id
JOIN invoices i ON s.subscription_id = i.subscription_id
GROUP BY c.full_name
HAVING SUM(i.amount) > 300;


--Query 2: Plan Categorisation Using CASE
SELECT 
    plan_name,
    monthly_fee,
    CASE 
        WHEN monthly_fee < 300 THEN 'Low Cost'
        WHEN monthly_fee BETWEEN 300 AND 600 THEN 'Mid Range'
        ELSE 'Premium'
    END AS plan_category
FROM plans;

--Query 3: Subquery – Above Average Data Usage
SELECT 
    subscription_id,
    SUM(data_used_mb) AS total_data_used
FROM usage_records
GROUP BY subscription_id
HAVING SUM(data_used_mb) >
      (SELECT AVG(data_used_mb) FROM usage_records);


--Query 4: Window Function – Customer Spending Rank
SELECT 
    c.full_name,
    SUM(i.amount) AS total_spent,
    RANK() OVER (ORDER BY SUM(i.amount) DESC) AS spending_rank
FROM customers c
JOIN subscriptions s ON c.customer_id = s.customer_id
JOIN invoices i ON s.subscription_id = i.subscription_id
GROUP BY c.full_name;

--Query 5: Multi-Table JOIN (4 Tables)
SELECT 
    c.full_name,
    p.plan_name,
    SUM(u.data_used_mb) AS total_data_used_mb
FROM customers c
JOIN subscriptions s ON c.customer_id = s.customer_id
JOIN plans p ON s.plan_id = p.plan_id
JOIN usage_records u ON s.subscription_id = u.subscription_id
GROUP BY c.full_name, p.plan_name;



---Stored Procedure
CREATE PROCEDURE sp_get_customer_invoices
    @customer_id INT
AS
BEGIN
    SELECT 
        c.full_name,
        i.invoice_date,
        i.amount,
        i.paid_status
    FROM customers c
    JOIN subscriptions s ON c.customer_id = s.customer_id
    JOIN invoices i ON s.subscription_id = i.subscription_id
    WHERE c.customer_id = @customer_id;
END;


--User-Defined Function
CREATE FUNCTION dbo.fn_calculate_tax (@amount DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN @amount * 0.18;
END;


SELECT 
    invoice_id,
    amount,
    dbo.fn_calculate_tax(amount) AS tax_amount
FROM invoices;


--- TASK 5: QUERY PERFORMANCE & OPTIMIZATION

--Inefficient Query
SELECT 
    c.full_name,
    SUM(i.amount)
FROM customers c
JOIN subscriptions s ON c.customer_id = s.customer_id
JOIN invoices i ON s.subscription_id = i.subscription_id
GROUP BY c.full_name;

--Optimization Strategy 1: Indexing
CREATE INDEX idx_subscriptions_customer
ON subscriptions(customer_id);

CREATE INDEX idx_invoices_subscription
ON invoices(subscription_id);


--Optimization Strategy 2: Execution Plan Check
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
