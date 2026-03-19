/* =========================================================
   UNLTD Wings Database Setup Script - FULL PRODUCTION SCALE
   Target: SQL Server (LocalDB or Standard)
   Version: 2.0 (Aligned with Official Menu Images)
   ========================================================= */

-- Create DB if needed
IF DB_ID('UNLTDWingsDB') IS NULL
BEGIN
    CREATE DATABASE UNLTDWingsDB;
END
GO

USE UNLTDWingsDB;
GO

SET NOCOUNT ON;

/* =========================
   1. TABLE: USERS
   ========================= */
IF OBJECT_ID('dbo.Users','U') IS NULL
BEGIN
    CREATE TABLE dbo.Users (
        UserID INT IDENTITY(1,1) PRIMARY KEY,
        Username NVARCHAR(50) NOT NULL UNIQUE,
        [Password] NVARCHAR(255) NOT NULL,
        [Name] NVARCHAR(100) NOT NULL,
        [Role] NVARCHAR(20) NOT NULL
            CONSTRAINT CK_Users_Role CHECK ([Role] IN ('Admin','Staff','Guest')),
        CreatedDate DATETIME NOT NULL CONSTRAINT DF_Users_CreatedDate DEFAULT (GETDATE())
    );
END
GO

/* =========================
   2. TABLE: MENU_ITEM
   ========================= */
IF OBJECT_ID('dbo.Menu_Item','U') IS NULL
BEGIN
    CREATE TABLE dbo.Menu_Item (
        ItemID INT IDENTITY(1,1) PRIMARY KEY,
        ItemName NVARCHAR(100) NOT NULL,
        ItemDescription NVARCHAR(255) NULL,
        ItemCategory NVARCHAR(50) NOT NULL
            CONSTRAINT CK_Menu_Item_Category CHECK (ItemCategory IN ('Unlimited','Wings','Rice Meals','Pasta','Combos','Fries','Drinks','Add-ons')),
        Price DECIMAL(10,2) NOT NULL CONSTRAINT CK_Menu_Item_Price CHECK (Price > 0),
        ImageUrl NVARCHAR(255) NULL,
        IsAvailable BIT NOT NULL CONSTRAINT DF_Menu_Item_IsAvailable DEFAULT (1),
        CreatedDate DATETIME NOT NULL CONSTRAINT DF_Menu_Item_CreatedDate DEFAULT (GETDATE())
    );
    
    CREATE INDEX IX_Menu_Item_Category ON dbo.Menu_Item(ItemCategory);
END
GO

/* =========================
   3. TABLE: ORDERS
   ========================= */
IF OBJECT_ID('dbo.Orders','U') IS NULL
BEGIN
    CREATE TABLE dbo.Orders (
        OrderID INT IDENTITY(1,1) PRIMARY KEY,
        CustomerName NVARCHAR(100) NOT NULL CONSTRAINT DF_Orders_CustomerName DEFAULT ('Guest'),
        ContactNumber NVARCHAR(30) NULL,
        TableNumber NVARCHAR(10) NULL,
        Address NVARCHAR(255) NULL,
        ReferenceNumber NVARCHAR(50) NULL,
        OrderType NVARCHAR(20) NOT NULL
            CONSTRAINT CK_Orders_OrderType CHECK (OrderType IN ('Dine-in','Delivery','Takeout','Walk-in')),
        OrderDate DATETIME NOT NULL CONSTRAINT DF_Orders_OrderDate DEFAULT(GETDATE()),
        OrderStatus NVARCHAR(20) NOT NULL CONSTRAINT DF_Orders_OrderStatus DEFAULT('Pending')
            CONSTRAINT CK_Orders_OrderStatus CHECK (OrderStatus IN ('Pending','Approved','Completed','Cancelled')),
        PaymentMethod NVARCHAR(20) NULL
            CONSTRAINT CK_Orders_PaymentMethod CHECK (PaymentMethod IN ('Cash','GCash')),
        PaymentStatus NVARCHAR(20) NOT NULL CONSTRAINT DF_Orders_PaymentStatus DEFAULT('Pending')
            CONSTRAINT CK_Orders_PaymentStatus CHECK (PaymentStatus IN ('Paid','Pending')),
        TotalAmount DECIMAL(10,2) NOT NULL CONSTRAINT DF_Orders_TotalAmount DEFAULT(0),
        ApprovedBy INT NULL,
        ApprovedDate DATETIME NULL,
        CONSTRAINT FK_Orders_ApprovedBy FOREIGN KEY (ApprovedBy) REFERENCES dbo.Users(UserID)
    );

    CREATE INDEX IX_Orders_OrderDate ON dbo.Orders(OrderDate DESC);
    CREATE INDEX IX_Orders_OrderStatus ON dbo.Orders(OrderStatus);
END
GO

/* =========================
   4. TABLE: ORDER_ITEM
   ========================= */
IF OBJECT_ID('dbo.Order_Item','U') IS NULL
BEGIN
    CREATE TABLE dbo.Order_Item (
        OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
        OrderID INT NOT NULL,
        ItemSequence INT NOT NULL CONSTRAINT DF_Order_Item_ItemSequence DEFAULT (0),
        ItemID INT NOT NULL,
        Quantity INT NOT NULL CONSTRAINT CK_Order_Item_Qty CHECK (Quantity > 0),
        Subtotal DECIMAL(10,2) NOT NULL,
        Flavor NVARCHAR(50) NULL, -- For wing flavors
        SpecialRequest NVARCHAR(255) NULL, -- "Less ice", "Spicy", etc.
        CONSTRAINT FK_Order_Item_Order FOREIGN KEY (OrderID) REFERENCES dbo.Orders(OrderID),
        CONSTRAINT FK_Order_Item_Menu FOREIGN KEY (ItemID) REFERENCES dbo.Menu_Item(ItemID)
    );

    CREATE INDEX IX_Order_Item_OrderID ON dbo.Order_Item(OrderID);
END
GO

/* =========================
   5. TABLE: INVENTORY
   ========================= */
IF OBJECT_ID('dbo.Inventory','U') IS NULL
BEGIN
    CREATE TABLE dbo.Inventory (
        InventoryID INT IDENTITY(1,1) PRIMARY KEY,
        IngredientName NVARCHAR(100) NOT NULL UNIQUE,
        StockLevel DECIMAL(10,2) NOT NULL CONSTRAINT DF_Inventory_Stock DEFAULT(0),
        Unit NVARCHAR(10) NOT NULL
            CONSTRAINT CK_Inventory_Unit CHECK (Unit IN ('kg','pcs','liters','packs','g','ml')),
        ReorderLevel DECIMAL(10,2) NOT NULL CONSTRAINT DF_Inventory_Reorder DEFAULT(10),
        LastUpdated DATETIME NOT NULL CONSTRAINT DF_Inventory_LastUpdated DEFAULT(GETDATE())
    );
END
GO

/* =========================
   6. TABLE: RECIPE
   ========================= */
IF OBJECT_ID('dbo.Recipe','U') IS NULL
BEGIN
    CREATE TABLE dbo.Recipe (
        RecipeID INT IDENTITY(1,1) PRIMARY KEY,
        ItemID INT NOT NULL,
        InventoryID INT NOT NULL,
        QuantityNeeded DECIMAL(10,2) NOT NULL CONSTRAINT CK_Recipe_Qty CHECK (QuantityNeeded > 0),
        CONSTRAINT FK_Recipe_Item FOREIGN KEY (ItemID) REFERENCES dbo.Menu_Item(ItemID),
        CONSTRAINT FK_Recipe_Inventory FOREIGN KEY (InventoryID) REFERENCES dbo.Inventory(InventoryID)
    );

    CREATE INDEX IX_Recipe_ItemID ON dbo.Recipe(ItemID);
END
GO

/* =========================
   7. TABLE: REFILL_LOG
   ========================= */
IF OBJECT_ID('dbo.Refill_Log','U') IS NULL
BEGIN
    CREATE TABLE dbo.Refill_Log (
        RefillLogID INT IDENTITY(1,1) PRIMARY KEY,
        OrderID INT NOT NULL,
        RefillNumber INT NOT NULL CONSTRAINT DF_Refill_Log_RefillNumber DEFAULT(0),
        InventoryID INT NULL,
        Flavor NVARCHAR(50) NULL,
        QuantityDeducted INT NOT NULL CONSTRAINT CK_Refill_Log_Qty CHECK (QuantityDeducted > 0),
        RefillTime DATETIME NOT NULL CONSTRAINT DF_Refill_Log_Time DEFAULT(GETDATE()),
        LoggedBy INT NULL,
        CONSTRAINT FK_Refill_Log_Order FOREIGN KEY (OrderID) REFERENCES dbo.Orders(OrderID),
        CONSTRAINT FK_Refill_Log_Inventory FOREIGN KEY (InventoryID) REFERENCES dbo.Inventory(InventoryID),
        CONSTRAINT FK_Refill_Log_User FOREIGN KEY (LoggedBy) REFERENCES dbo.Users(UserID)
    );

    CREATE INDEX IX_Refill_Log_Time ON dbo.Refill_Log(RefillTime DESC);
END
GO

/* =========================
   8. TABLE: ORDER APPROVALS
   ========================= */
IF OBJECT_ID('dbo.OrderApprovals','U') IS NULL
BEGIN
    CREATE TABLE dbo.OrderApprovals (
        OrderApprovalID INT IDENTITY(1,1) PRIMARY KEY,
        OrderID INT NOT NULL,
        ApprovedByUserID INT NOT NULL,
        ApprovalStatus NVARCHAR(20) NOT NULL,
        ApprovedDate DATETIME NOT NULL CONSTRAINT DF_OrderApprovals_Date DEFAULT(GETDATE()),
        CONSTRAINT FK_OrderApprovals_Order FOREIGN KEY (OrderID) REFERENCES dbo.Orders(OrderID),
        CONSTRAINT FK_OrderApprovals_User FOREIGN KEY (ApprovedByUserID) REFERENCES dbo.Users(UserID)
    );

    CREATE INDEX IX_OrderApprovals_OrderID ON dbo.OrderApprovals(OrderID);
END
GO

/* =========================
   9. TABLE: TABLE QR CODES
   ========================= */
IF OBJECT_ID('dbo.TableQRCodes','U') IS NULL
BEGIN
    CREATE TABLE dbo.TableQRCodes (
        QRCodeID INT IDENTITY(1,1) PRIMARY KEY,
        TableNumber NVARCHAR(10) NOT NULL,
        TableDescription NVARCHAR(100) NULL,
        OrderUrl NVARCHAR(500) NOT NULL,
        QRImageUrl NVARCHAR(500) NULL,
        IsActive BIT NOT NULL CONSTRAINT DF_TableQRCodes_IsActive DEFAULT(1),
        CreatedDate DATETIME NOT NULL CONSTRAINT DF_TableQRCodes_Created DEFAULT(GETDATE()),
        LastModified DATETIME NOT NULL CONSTRAINT DF_TableQRCodes_Mod DEFAULT(GETDATE())
    );

    CREATE UNIQUE INDEX UX_TableQRCodes_TableNumber ON dbo.TableQRCodes(TableNumber);
END
GO

/* =========================
   10. TABLE: TABLE SESSIONS
   ========================= */
IF OBJECT_ID('dbo.TableSessions','U') IS NULL
BEGIN
    CREATE TABLE dbo.TableSessions (
        SessionID INT IDENTITY(1,1) PRIMARY KEY,
        TableNumber NVARCHAR(10) NOT NULL,
        UserID INT NOT NULL,
        LoginTime DATETIME NOT NULL CONSTRAINT DF_TableSessions_Login DEFAULT(GETDATE()),
        SessionEndTime DATETIME NOT NULL,
        IsActive BIT NOT NULL CONSTRAINT DF_TableSessions_IsActive DEFAULT(1),
        LastActivityTime DATETIME NOT NULL CONSTRAINT DF_TableSessions_Activity DEFAULT(GETDATE()),
        CONSTRAINT FK_TableSessions_User FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID)
    );

    CREATE INDEX IX_TableSessions_TableNumber ON dbo.TableSessions(TableNumber);
END
GO

/* Stored Procedure for Table Sessions */
IF OBJECT_ID('dbo.sp_CreateTableSession','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CreateTableSession;
GO

EXEC('
CREATE PROCEDURE dbo.sp_CreateTableSession
    @TableNumber NVARCHAR(10),
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Update any expired session to inactive
    UPDATE dbo.TableSessions 
    SET IsActive = 0 
    WHERE TableNumber = @TableNumber AND SessionEndTime < GETDATE();

    -- Check for existing active session
    IF EXISTS (
        SELECT 1 FROM dbo.TableSessions
        WHERE TableNumber = @TableNumber
          AND IsActive = 1
          AND SessionEndTime > GETDATE()
    )
    BEGIN
        -- Optional: allow re-login if same user, otherwise block
        DECLARE @ExistingUser INT;
        SELECT @ExistingUser = UserID FROM dbo.TableSessions WHERE TableNumber = @TableNumber AND IsActive=1;
        
        IF @ExistingUser <> @UserID
        BEGIN
            RAISERROR(''This table already has an active session from another device'', 16, 1);
            RETURN;
        END
    END

    INSERT INTO dbo.TableSessions(TableNumber, UserID, SessionEndTime)
    VALUES(@TableNumber, @UserID, DATEADD(MINUTE, 30, GETDATE()));
END
');
GO

/* =========================
   SEED DATA: USERS
   ========================= */
IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username='admin')
INSERT INTO dbo.Users(Username,[Password],[Name],[Role]) VALUES ('admin','admin123','System Administrator','Admin');

IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username='staff')
INSERT INTO dbo.Users(Username,[Password],[Name],[Role]) VALUES ('staff','staff123','Staff Member','Staff');

DECLARE @t INT = 1;
WHILE @t <= 10 -- Provision for up to 10 tables
BEGIN
    DECLARE @u NVARCHAR(50) = CONCAT('Table', @t);
    IF NOT EXISTS (SELECT 1 FROM dbo.Users WHERE Username=@u)
        INSERT INTO dbo.Users(Username,[Password],[Name],[Role]) VALUES (@u,@u,CONCAT('Table ',@t),'Guest');
    SET @t += 1;
END
GO

/* =========================
   SEED DATA: INVENTORY
   ========================= */
-- Core Ingredients
MERGE INTO dbo.Inventory AS Target
USING (VALUES 
    ('Chicken Wings', 1000, 'pcs', 200),
    ('Rice', 100, 'kg', 20),
    ('Fries (Frozen)', 50, 'kg', 10),
    ('Burger Patties', 200, 'pcs', 50),
    ('Burger Buns', 200, 'pcs', 50),
    ('Pasta Noodles', 50, 'packs', 10),
    ('Pork Chop', 100, 'pcs', 20),
    ('Pork Tonkatsu', 100, 'pcs', 20),
    ('Ribs', 50, 'pcs', 10),
    ('Whole Chicken', 20, 'pcs', 5), -- Hainanese base
    ('Nachos Chips', 20, 'packs', 5),
    ('Cheese Sauce', 10, 'liters', 2)
) AS Source (IngredientName, StockLevel, Unit, ReorderLevel)
ON Target.IngredientName = Source.IngredientName
WHEN NOT MATCHED THEN
    INSERT (IngredientName, StockLevel, Unit, ReorderLevel) 
    VALUES (Source.IngredientName, Source.StockLevel, Source.Unit, Source.ReorderLevel);

-- Sauces (For Wings)
MERGE INTO dbo.Inventory AS Target
USING (VALUES 
    ('Buffalo Sauce', 10, 'liters', 2),
    ('BBQ Sauce', 10, 'liters', 2),
    ('Honey Garlic Sauce', 10, 'liters', 2),
    ('Garlic Parmesan', 10, 'kg', 2), -- Powder/Mix
    ('Mango Habanero Sauce', 10, 'liters', 2),
    ('Garlic Mayo', 10, 'liters', 2),
    ('Sour Cream Powder', 5, 'kg', 1)
) AS Source (IngredientName, StockLevel, Unit, ReorderLevel)
ON Target.IngredientName = Source.IngredientName
WHEN NOT MATCHED THEN
    INSERT (IngredientName, StockLevel, Unit, ReorderLevel) 
    VALUES (Source.IngredientName, Source.StockLevel, Source.Unit, Source.ReorderLevel);

-- Drinks
MERGE INTO dbo.Inventory AS Target
USING (VALUES 
    ('Soda Syrup Base', 50, 'liters', 10),
    ('Passion Fruit Syrup', 5, 'liters', 1),
    ('Lychee Syrup', 5, 'liters', 1),
    ('Strawberry Syrup', 5, 'liters', 1),
    ('Green Apple Syrup', 5, 'liters', 1),
    ('Blueberry Syrup', 5, 'liters', 1),
    ('Kiwi Syrup', 5, 'liters', 1),
    ('Watermelon Syrup', 5, 'liters', 1),
    ('Yakult', 500, 'pcs', 50),
    ('Popping Boba', 20, 'kg', 5),
    ('Nata De Coco', 20, 'kg', 5)
) AS Source (IngredientName, StockLevel, Unit, ReorderLevel)
ON Target.IngredientName = Source.IngredientName
WHEN NOT MATCHED THEN
    INSERT (IngredientName, StockLevel, Unit, ReorderLevel) 
    VALUES (Source.IngredientName, Source.StockLevel, Source.Unit, Source.ReorderLevel);
GO

/* =========================
   SEED DATA: MENU ITEMS
   ========================= */
-- We delete strict duplicates to re-seed correctly if needed, but MERGE is safer.
-- Since Identity Insert is ON by default in table creation, we rely on Clean Insert.
-- Clearing menu items to ensure order matches structure if needed
-- DELETE FROM dbo.Menu_Item; -- Uncomment only if full reset desired (WARNING: Deletes existing)

-- Helper table for seeding to avoid huge hardcoded ID list
DECLARE @MenuItems TABLE (Category NVARCHAR(50), Name NVARCHAR(100), Price DECIMAL(10,2), Img NVARCHAR(255));

INSERT INTO @MenuItems VALUES
-- UNLIMITED
('Unlimited', 'SET A (Unli Wings + Unli Rice)', 329.00, 'Images/Menu/unli_a.jpg'),
('Unlimited', 'SET B (Unli Wings + Drinks + Rice)', 349.00, 'Images/Menu/unli_b.jpg'),
('Unlimited', 'SET C (6pc Wings + Unli Rice/Drinks)', 299.00, 'Images/Menu/unli_c.jpg'),

-- WINGS SOLO
('Wings', '5 Pcs Wings', 149.00, 'Images/Menu/wings_5.jpg'),
('Wings', '8 Pcs Wings', 249.00, 'Images/Menu/wings_8.jpg'),
('Wings', '10 Pcs Wings', 299.00, 'Images/Menu/wings_10.jpg'),
('Wings', '12 Pcs Wings', 349.00, 'Images/Menu/wings_12.jpg'),
('Wings', '16 Pcs Wings', 499.00, 'Images/Menu/wings_16.jpg'),
('Wings', '40 Pcs Wings', 999.00, 'Images/Menu/wings_40.jpg'),
('Wings', '50 Pcs Wings', 1299.00, 'Images/Menu/wings_50.jpg'),

-- RICE MEALS
('Rice Meals', 'Chicken Poppers', 129.00, 'Images/Menu/rice_poppers.jpg'),
('Rice Meals', 'Porkchop Steak', 149.00, 'Images/Menu/rice_porkchop.jpg'),
('Rice Meals', 'Pork Tonkatsu', 149.00, 'Images/Menu/rice_tonkatsu.jpg'),
('Rice Meals', 'Katsu Curry', 159.00, 'Images/Menu/rice_katsu.jpg'),
('Rice Meals', '3pcs Chicken Wings w/ Rice', 149.00, 'Images/Menu/rice_wings.jpg'),
('Rice Meals', 'Hainanese Chicken', 159.00, 'Images/Menu/rice_hainanese.jpg'),
('Rice Meals', 'Baby Back Ribs', 199.00, 'Images/Menu/rice_ribs.jpg'),

-- PASTA
('Pasta', 'Quezo Creamy Basil Penne Al Marco', 199.00, 'Images/Menu/pasta_basil.jpg'),
('Pasta', 'Shrimp Penne Al Sebastiano', 199.00, 'Images/Menu/pasta_shrimp.jpg'),
('Pasta', 'Penne Pasta Al Sardino', 199.00, 'Images/Menu/pasta_sardino.jpg'),
('Pasta', 'Penne Pasta Al Tonno', 199.00, 'Images/Menu/pasta_tonno.jpg'),

-- COMBOS (Burgers/Sandwiches) -> Mapped to 'Combos' category
('Combos', 'Chicken Burger', 79.00, 'Images/Menu/burger_chicken.jpg'),
('Combos', 'Chicken Burger w/ Fries', 99.00, 'Images/Menu/burger_fries.jpg'),
('Combos', 'Chicken Burger w/ Fries & Drink', 139.00, 'Images/Menu/burger_meal.jpg'),
('Combos', 'Chicken Sub Sandwich', 139.00, 'Images/Menu/sub_sandwich.jpg'),
('Combos', 'Chicken & Fries', 129.00, 'Images/Menu/chicken_fries.jpg'),
('Combos', 'Cheesy Chicken Patata', 129.00, 'Images/Menu/chicken_patata.jpg'),
('Combos', 'Beefy Nachos Overload', 229.00, 'Images/Menu/nachos.jpg'),

-- FRIES
('Fries', 'Fries Bucket', 99.00, 'Images/Menu/fries_bucket.jpg'),
('Fries', 'Mega Fries', 139.00, 'Images/Menu/fries_mega.jpg'),
('Fries', 'GIGA Fries', 199.00, 'Images/Menu/fries_giga.jpg'),

-- DRINKS - Sparkling
('Drinks', 'Sparkling Soda - Passion Fruit', 59.00, 'Images/Menu/soda_passion.jpg'),
('Drinks', 'Sparkling Soda - Lychee', 59.00, 'Images/Menu/soda_lychee.jpg'),
('Drinks', 'Sparkling Soda - Strawberry', 59.00, 'Images/Menu/soda_strawberry.jpg'),
('Drinks', 'Sparkling Soda - Green Apple', 59.00, 'Images/Menu/soda_apple.jpg'),
('Drinks', 'Sparkling Soda - Blueberry', 59.00, 'Images/Menu/soda_blueberry.jpg'),
('Drinks', 'Sparkling Soda - Kiwi', 59.00, 'Images/Menu/soda_kiwi.jpg'),
('Drinks', 'Sparkling Soda - Watermelon', 59.00, 'Images/Menu/soda_watermelon.jpg'),

('Drinks', 'Gradient Soda', 79.00, 'Images/Menu/soda_gradient.jpg'),
('Drinks', 'Four Seasons', 79.00, 'Images/Menu/soda_fourseasons.jpg'),

-- DRINKS - Yakult
('Drinks', 'Yakult Soda - Strawberry', 79.00, 'Images/Menu/yakult_straw.jpg'),
('Drinks', 'Yakult Soda - Kiwi', 79.00, 'Images/Menu/yakult_kiwi.jpg'),
('Drinks', 'Yakult Soda - Lychee', 79.00, 'Images/Menu/yakult_lychee.jpg'),
('Drinks', 'Yakult Soda - Green Apple', 79.00, 'Images/Menu/yakult_apple.jpg'),
('Drinks', 'Yakult Soda - Blueberry', 79.00, 'Images/Menu/yakult_blue.jpg'),
('Drinks', 'Yakult Soda - Watermelon', 79.00, 'Images/Menu/yakult_water.jpg'),

-- ADD-ONS
('Add-ons', 'Popping Boba', 15.00, 'Images/Menu/addon_boba.jpg'),
('Add-ons', 'Nata De Coco', 15.00, 'Images/Menu/addon_nata.jpg'),
('Add-ons', 'Extra Rice', 25.00, 'Images/Menu/addon_rice.jpg');

-- Insert excluding duplicates
INSERT INTO dbo.Menu_Item (ItemName, ItemDescription, ItemCategory, Price, ImageUrl)
SELECT Name, 'Delicious ' + Name, Category, Price, Img
FROM @MenuItems m
WHERE NOT EXISTS (SELECT 1 FROM dbo.Menu_Item WHERE ItemName = m.Name);
GO

/* =========================
   SEED DATA: RECIPES (Mapping)
   ========================= */
-- 1. Wings mapping
INSERT INTO dbo.Recipe (ItemID, InventoryID, QuantityNeeded)
SELECT m.ItemID, i.InventoryID,
    CASE 
        WHEN m.ItemName LIKE '5 Pcs%' THEN 5
        WHEN m.ItemName LIKE '8 Pcs%' THEN 8
        WHEN m.ItemName LIKE '10 Pcs%' THEN 10
        WHEN m.ItemName LIKE '12 Pcs%' THEN 12
        WHEN m.ItemName LIKE '16 Pcs%' THEN 16
        WHEN m.ItemName LIKE '40 Pcs%' THEN 40
        WHEN m.ItemName LIKE '50 Pcs%' THEN 50
        WHEN m.ItemName LIKE 'SET %' THEN 6 -- Base for unli
        WHEN m.ItemName LIKE '3pcs%' THEN 3
        ELSE 0 
    END
FROM dbo.Menu_Item m
CROSS JOIN dbo.Inventory i
WHERE i.IngredientName = 'Chicken Wings'
  AND (m.ItemCategory = 'Wings' OR m.ItemCategory = 'Unlimited' OR m.ItemName LIKE '%Wings%')
  AND NOT EXISTS (SELECT 1 FROM dbo.Recipe WHERE ItemID=m.ItemID AND InventoryID=i.InventoryID);

-- 2. Rice mapping
INSERT INTO dbo.Recipe (ItemID, InventoryID, QuantityNeeded)
SELECT m.ItemID, i.InventoryID, 0.2 -- approx 200g rice per serving
FROM dbo.Menu_Item m
CROSS JOIN dbo.Inventory i
WHERE i.IngredientName = 'Rice'
  AND (m.ItemCategory = 'Rice Meals' OR m.ItemName LIKE '%Unli Rice%' OR m.ItemName = 'Extra Rice')
  AND NOT EXISTS (SELECT 1 FROM dbo.Recipe WHERE ItemID=m.ItemID AND InventoryID=i.InventoryID);

-- 3. Fries mapping
INSERT INTO dbo.Recipe (ItemID, InventoryID, QuantityNeeded)
SELECT m.ItemID, i.InventoryID, 
    CASE 
        WHEN m.ItemName = 'Fries Bucket' THEN 0.3
        WHEN m.ItemName = 'Mega Fries' THEN 0.4
        WHEN m.ItemName = 'GIGA Fries' THEN 0.6
        ELSE 0.15 
    END
FROM dbo.Menu_Item m
CROSS JOIN dbo.Inventory i
WHERE i.IngredientName = 'Fries (Frozen)'
  AND m.ItemCategory IN ('Fries', 'Combos') AND m.ItemName LIKE '%Fries%'
  AND NOT EXISTS (SELECT 1 FROM dbo.Recipe WHERE ItemID=m.ItemID AND InventoryID=i.InventoryID);

-- 4. Burger mapping
INSERT INTO dbo.Recipe (ItemID, InventoryID, QuantityNeeded)
SELECT m.ItemID, i.InventoryID, 1
FROM dbo.Menu_Item m
CROSS JOIN dbo.Inventory i
WHERE i.IngredientName IN ('Burger Patties', 'Burger Buns')
  AND (m.ItemName LIKE '%Burger%' OR m.ItemName LIKE '%Sub%')
  AND NOT EXISTS (SELECT 1 FROM dbo.Recipe WHERE ItemID=m.ItemID AND InventoryID=i.InventoryID);

GO

PRINT '=====================================================';
PRINT 'UNLTD WINGS DATABASE SETUP COMPLETE';
PRINT '=====================================================';
