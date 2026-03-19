# UNLTD Wings - System Analysis and Design Documentation

## 1. System Overview & Core Workflows

### Role-Based Access Control (RBAC)
* [cite_start]**Administrator (Owner):** Granted full access to Account Management, Menu Management, and Financial Reports[cite: 844].
* [cite_start]**Staff:** Restricted to the Operational Dashboard for order validation, manual order entry, and refill logging[cite: 845].
* [cite_start]**Guest (No Login):** Sessions are restricted to the digital menu and order request page accessed via table QR codes[cite: 847].

### Order Management Flow
* [cite_start]**Guest Ordering:** Customers scan a QR code to browse the menu and request an order[cite: 161]. [cite_start]These orders remain in a "Pending" state until a staff member verifies and approves them to prevent fraudulent entries[cite: 162].
* [cite_start]**Manual Entry:** Staff can manually input orders for walk-in customers and log delivery orders received via external messaging apps[cite: 163, 168].
* [cite_start]**Calculations:** The system captures the Order Type, Customer Name, and Payment Method, and automatically calculates the Subtotal and Total Amount by pulling pricing data from the Menu_Item entity[cite: 856, 857].

### Inventory & Refill Tracking Logic
* [cite_start]**Automated Deductions:** Inventory utilizes trigger-based updates; stock levels are automatically decremented only after an order is validated and "Approved" by staff[cite: 877].
* [cite_start]**Recipe Logic:** The system uses a centralized `Recipe` entity to act as a logic bridge, translating every `Order_Item` into a specific set of raw inventory deductions[cite: 261, 262].
* [cite_start]**Unlimited Refill Enforcement:** To support the "unlimited" service model, staff manually input wing batches into a `Refill_Log`, which deducts stock based on actual consumption[cite: 878]. The system tracks the `Refill_Time` to help management enforce the 1 hour and 30 minutes dining limit[cite: 260].
* [cite_start]**Low Stock Alerts:** The system will provide visual alerts when physical inventory reaches a predefined minimum threshold (`Reorder_Level`)[cite: 172, 266].

---

## 2. Database Schema (SQL Server)

### User Table
* [cite_start]**user_ID:** INT, PRIMARY KEY, IDENTITY [cite: 1348]
* **username:** NVARCHAR(50), UNIQUE, NOT NULL [cite: 1348]
* [cite_start]**password:** NVARCHAR(255), Minimum of 8 characters, NOT NULL [cite: 1348]
* [cite_start]**Name:** NVARCHAR(100), NOT NULL [cite: 1348]
* **Role:** NVARCHAR(20), CHECK (Admin, Staff), NOT NULL [cite: 1348]

### Order Table
* [cite_start]**Order_id:** INT, PRIMARY KEY, IDENTITY [cite: 1352, 1353, 1358]
* **Customer_name:** NVARCHAR(100), Default 'Guest', NOT NULL [cite: 1360, 1361, 1362]
* **Contact_number:** NVARCHAR(15), Numeric format, NULLABLE [cite: 1363, 1364, 1365]
* **Order_type:** NVARCHAR(20), (Dine-in or Delivery), NOT NULL [cite: 1366, 1368, 1370]
* **Order_date:** DATETIME, DEFAULT GETDATE(), NOT NULL [cite: 1371, 1373, 1374, 1375]
* **Payment_method:** NVARCHAR(20), (Cash or GCash), NOT NULL [cite: 1378]
* **Payment_status:** NVARCHAR(20), (Paid or Pending), NOT NULL [cite: 1378]
* **Total_amount:** DECIMAL(10,2), Calculated value, NOT NULL [cite: 1378]

### Order_Item Table
* [cite_start]**Order_ID:** INT, PRIMARY KEY, FOREIGN KEY [cite: 1380]
* [cite_start]**Item_Sequence:** INT, PRIMARY KEY (Separates each item in an order) [cite: 1380]
* **Item_ID:** INT, FOREIGN KEY [cite: 1380]
* **Quantity:** INT, CHECK (Quantity > 0), NOT NULL [cite: 1380]
* [cite_start]**Subtotal:** DECIMAL(10,2), Calculated value (Price x Quantity), NOT NULL [cite: 1380]

### Menu_Item Table
* **Item_ID:** INT, PRIMARY KEY, IDENTITY [cite: 1382]
* **Item_Name:** NVARCHAR(100), UNIQUE, NOT NULL [cite: 1382, 1385]
* **Item_Category:** NVARCHAR(50), (Wings, Sides, Drinks), NOT NULL [cite: 1385]
* **Price:** DECIMAL(10,2), Positive value, NOT NULL [cite: 1385]

### Inventory Table
* [cite_start]**Inventory_ID:** INT, PRIMARY KEY, IDENTITY [cite: 1387]
* **Ingredient_Name:** NVARCHAR(100), NOT NULL [cite: 1387]
* **Stock_Level:** DECIMAL(10,2), NOT NULL [cite: 1387]
* **Unit:** NVARCHAR(10), (kg, pcs, liters), NOT NULL [cite: 1387]
* [cite_start]**Reorder_Level:** DECIMAL(10,2), NOT NULL [cite: 1387]

### Refill_Log Table
* [cite_start]**Order_ID:** INT, PRIMARY KEY, FOREIGN KEY [cite: 1393]
* [cite_start]**Refill_Number:** INT, PRIMARY KEY [cite: 1393]
* [cite_start]**Inventory_ID:** INT, FOREIGN KEY [cite: 1393]
* **Quantity_Deducted:** INT, Positive Value, NOT NULL [cite: 1393]
* **Refill_Time:** DATETIME, DEFAULT GETDATE(), NOT NULL [cite: 1393]

### Recipe Table
* **Recipe_ID:** INT, PRIMARY KEY, IDENTITY [cite: 1397]
* **Item_ID:** INT, FOREIGN KEY [cite: 1397]
* **Inventory_ID:** INT, FOREIGN KEY [cite: 1397]
* **Quantity:** DECIMAL(10,2), Positive Value, NOT NULL [cite: 1397]

### Report Table
* [cite_start]**Report_ID:** INT, PRIMARY KEY, IDENTITY [cite: 1391]
* **Report_Type:** NVARCHAR(50), (Sales Summary), NOT NULL [cite: 1391]
* **Start_Date:** DATE, Must be <= End_Date, NOT NULL [cite: 1391]
* [cite_start]**End_Date:** DATE, Must be >= Start_Date, NOT NULL [cite: 1391]
* [cite_start]**Total_Sales:** DECIMAL(12,2), Calculated value, NOT NULL [cite: 1391]