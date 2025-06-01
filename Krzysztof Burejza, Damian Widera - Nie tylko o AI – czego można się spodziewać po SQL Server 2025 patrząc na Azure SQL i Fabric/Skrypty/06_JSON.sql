/* ###########################################
   ##     DEMO: OBSŁUGA TYPU JSON           ##
   ##     CAST, INSERT, AGREGACJE, OPENJSON ##
   ########################################### */

-- 1. Usunięcie tabeli, jeśli istnieje
DROP TABLE IF EXISTS dbo.orders;
GO

-- 2. Tworzenie tabeli z kolumną typu JSON
CREATE TABLE dbo.orders
(
    order_id INT PRIMARY KEY,         
    -- Identyfikator zamówienia
    customer NVARCHAR(50),            
    -- Nazwa klienta
    details JSON                      
    -- Szczegóły zamówienia w formacie JSON
);
GO

-- 3. Wstawianie poprawnych danych JSON do tabeli
INSERT INTO dbo.orders (order_id, customer, details) VALUES
(1, 'John Doe', '{"product": "Laptop", "quantity": 2, "price": 1200.50}'),
(2, 'Jane Smith', '{"product": "Phone", "quantity": 1, "price": 800.00}'),
(3, 'Alice Johnson', '{"product": "Tablet", "quantity": 3, "price": 400.00}'),
(4, 'Bob Brown', '{"product": "Monitor", "quantity": 2, "price": 300.00}'),
(5, 'Eve Davis', '{"product": "Keyboard", "quantity": 5, "price": 50.00}'),
(6, 'Tom White', '{"product": "Mouse", "quantity": 4, "price": 40.00}');
GO

-- 4. Wyświetlenie zawartości tabeli
SELECT * FROM dbo.orders;
GO

-- 5. Pobranie metadanych kolumn – typ danych, długość itp.
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'orders';
GO

-- 6. Intencjonalny błąd: niepoprawny JSON 
--    Brakuje przecinka między "quantity" a "price"
--    Spowoduje błąd: Msg 13609 – 
-- Unexpected character '"' is found

 INSERT INTO dbo.orders (order_id, customer, details)
 VALUES (7, 'Invalid JSON', '{"product": "Broken", "quantity": 1 "price": 99.99}');
 GO

-- 7. Rzutowanie poprawnego i blednego tekstu na typ JSON
--    SQL Server rozpoznaje jako typ JSON, 
--    ale klienci widzą NVARCHAR
SELECT CAST('{"a":1, "b":2}' AS JSON) AS JsonResult;
GO

SELECT CAST('{"a":1, "b":2}/' AS JSON) AS JsonResult;
GO

-- 8. Pokazanie metadanych przy pomocy systemowej procedury
--    sp_describe_first_result_set 
-- NIE rozpoznaje typu JSON (zwraca NVARCHAR)
EXEC sp_describe_first_result_set 
    N'SELECT CAST(''{"a":1, "b":2}'' AS JSON) AS JsonResult';
GO

-- 9. JSON_ARRAYAGG – 
--agregacja kolumny "details" do jednej tablicy JSON
SELECT 
    JSON_ARRAYAGG(details) AS AllOrderDetails_JSONArray
FROM 
    dbo.orders;
GO

-- 10. JSON_ARRAYAGG – 
-- agregacja wszystkich nazw klientów do tablicy JSON
SELECT 
    JSON_ARRAYAGG(customer) AS AllCustomerNames_JSONArray
FROM 
    dbo.orders;
GO

-- 11a. Proste zapytanie – 
-- kolumny customer i details bez agregacji
SELECT 
    customer,
    details
FROM 
    dbo.orders;
GO

-- 11b. JSON_OBJECTAGG – 
-- agregacja: klucz = customer, wartość = JSON details
-- Tworzy obiekt JSON reprezentujący mapę klient → zamówienie
SELECT 
    JSON_OBJECTAGG(customer:details) AS CustomerOrderMap_JSONObject
FROM 
    dbo.orders;
GO
