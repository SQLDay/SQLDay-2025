
/* =========================================================
   1.  PRODUCTS  
   ========================================================= */
DROP TABLE IF EXISTS mw.Products;
GO
CREATE TABLE mw.Products
(
    ProductID      int            IDENTITY(1,1) PRIMARY KEY,
    ProductName    nvarchar(100)  NOT NULL,
    Category       nvarchar(50)   NOT NULL,
    Price          decimal(10,2)  NOT NULL,
    Discount       decimal(5,2)   NULL,
     Specs         JSON NOT NULL                       -- ← włącz, jeśli masz natywny typ
    --Specs          nvarchar(max)  NOT NULL               -- ← włącz jeśli nie masz typu JSON
);
GO

INSERT INTO mw.Products (ProductName, Category, Price, Discount, Specs)
VALUES
/* 1 */ (N'Keyboard',  N'Electronics',  49.90,  NULL,
         N'{
             "color":"black",
             "status":"active",
             "dimensions":{"w":45,"h":5,"d":15},
             "tags":["peripheral","wired"]
           }'),
/* 2 */ (N'Laptop',    N'Electronics',1299.00,  10.0,
         N'{
             "color":"silver",
             "status":"active",
             "battery":"60Wh",
             "dimensions":{"w":32,"h":2,"d":22},
             "tags":["portable"]
           }'),
/* 3 */ (N'Smartphone',N'Electronics', 799.00,  5.0,
         N'{
             "color":"blue",
             "status":"active",
             "dimensions":{"w":7,"h":0.8,"d":15},
             "tags":["5G","OLED"]
           }'),
/* 4 */ (N'Tablet',    N'Electronics', 499.00,  NULL,
         N'{
             "color":"black",
             "status":"inactive",
             "dimensions":{"w":25,"h":0.7,"d":17},
             "tags":["OLED"]
           }');
GO


/* =========================================================
   2.  ORDERS  
   ========================================================= */
DROP TABLE IF EXISTS mw.Orders;
GO
CREATE TABLE mw.Orders
(
    OrderID     int            IDENTITY(1001,1) PRIMARY KEY,
    CreatedOn   datetime2      NOT NULL          DEFAULT sysdatetime(),
    -- OrderDetails  JSON NOT NULL,                             -- natywny typ
    OrderDetails nvarchar(max) NOT NULL,

    CONSTRAINT chk_jsonvalid  CHECK (ISJSON(OrderDetails)=1),
    CONSTRAINT chk_items_exist CHECK (
         JSON_PATH_EXISTS(OrderDetails,'$.items')=1)
);
GO

INSERT INTO mw.Orders (OrderDetails)
VALUES
(N'{
    "orderId":987,
    "customer":"Acme Corp",
    "status":"pending",
    "items":[
        {"sku":"KB-01","qty":2},
        {"sku":"MS-02","qty":1}
    ],
    "shipping":{"method":"courier","cost":9.90}
 }');
GO


/* =========================================================
   3.  TELEMETRY (IoT demo )
   ========================================================= */
DROP TABLE IF EXISTS mw.Telemetry;
GO
CREATE TABLE mw.Telemetry
(
    TelemetryID int            IDENTITY PRIMARY KEY,
    DeviceId    varchar(50)    NOT NULL,
    Payload     nvarchar(max)  NOT NULL,
    ReceivedOn  datetime2      NOT NULL  DEFAULT sysdatetime()
);
GO

INSERT INTO mw.Telemetry (DeviceId, Payload)
VALUES
('sensor-01', N'{"temp":22.4,"battery":88,"ts":"2025-05-10T10:12:55Z"}'),
('sensor-02', N'{"hum":45,"ts":"2025-05-10T10:13:01Z"}');
GO


/* =========================================================
   4.  EVENTS  (audit / event-sourcing)
   ========================================================= */
DROP TABLE IF EXISTS mw.Events;
GO
CREATE TABLE mw.Events
(
    EventID      bigint         IDENTITY PRIMARY KEY,
    EventType    nvarchar(50)   NOT NULL,
    EventPayload nvarchar(max)  NOT NULL,
    EventTime    datetime2      NOT NULL DEFAULT sysdatetime()
);
GO

INSERT INTO mw.Events (EventType, EventPayload)
VALUES
('OrderPlaced',   N'{"orderId":987,"customer":"Acme Corp","total":1400}'),
('OrderShipped',  N'{"orderId":987,"carrier":"DHL"}');
GO


/* =========================================================
   5.  TENANTS  (feature-flags demo)
   ========================================================= */
DROP TABLE IF EXISTS mw.Tenants;
GO
CREATE TABLE mw.Tenants
(
    TenantID  int            IDENTITY PRIMARY KEY,
    Name      nvarchar(100)  NOT NULL,
    Settings  nvarchar(max)  NOT NULL
);
GO

INSERT INTO mw.Tenants (Name, Settings)
VALUES
(N'Contoso', N'{
   "features":{
       "chat":"disabled",
       "darkMode":"enabled"
   },
   "limits":{"maxUsers":50}
}');
GO


/* =========================================================
   6.  Przydatne zmienne demonstracyjne 
   ========================================================= */


DECLARE @order nvarchar(max) = N'{
  "orderId": 987,
  "customer": "Acme Corp",
  "status": "pending",
  "items": [
    { "sku": "KB-01", "qty": 2 },
    { "sku": "MS-02", "qty": 1 }
  ]
}';

DECLARE @productList nvarchar(max) = N'{
  "products":[
    { "id":1, "name":"Laptop",   "qty":10 },
    { "id":2, "name":"Keyboard", "qty":50 }
  ]
}';



/* =========================================================
   7.  Szybkie testy – uruchom, aby potwierdzić:
   ========================================================= */


PRINT '--- ISJSON():';
SELECT ISJSON(@order) AS IsValid;

PRINT '--- JSON_VALUE():';
SELECT JSON_VALUE(@order,'$.customer') AS Customer;

PRINT '--- Agregaty (ARRAYAGG / OBJECTAGG):';
SELECT
    JSON_ARRAYAGG(ProductName ORDER BY ProductName) AS ProductList,
    JSON_OBJECTAGG(ProductID : ProductName)         AS ProductsById
FROM mw.Products;

PRINT '--- OPENJSON() przykład:';
SELECT *
FROM OPENJSON(@productList,'$.products')
     WITH (
        ProductID   int           '$.id',
        ProductName nvarchar(50)  '$.name',
        Quantity    int           '$.qty'
     );
GO



/* --- 1. dodanie kolumnę obliczaną (persisted) ----------------------------- */
ALTER TABLE mw.Products
ADD Color AS JSON_VALUE(Specs,'$.color') PERSISTED;

/* --- 2. załóż indeks na kolumnie obliczanej ----------------------------- */
CREATE INDEX IX_Products_Color
    ON mw.Products (Color);

/* --- 3. test: filtr po kolorze ----------------------------------------- */
SET STATISTICS IO ON;      -- włącz I/O, żeby zobaczyć seek vs scan

SELECT ProductID, ProductName, Price, Color
FROM   mw.Products
WHERE  Color = N'black';

SET STATISTICS IO OFF;


--sprobujmy usunąc kolumne specs
ALTER TABLE mw.Products
ALTER COLUMN Specs JSON NOT NULL;

--The column 'Color' is dependent on column 'Specs'.


ALTER TABLE mw.Products
DROP COLUMN Color

--The index 'IX_Products_Color' is dependent on column 'Color'.


DROP INDEX IX_Products_Color on mw.Products

