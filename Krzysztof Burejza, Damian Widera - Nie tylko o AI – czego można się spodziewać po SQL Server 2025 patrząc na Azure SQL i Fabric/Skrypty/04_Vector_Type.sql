/* #############################################
   ##  TWORZENIE I OBSŁUGA KOLUMN VECTOR      ##
   ##  PRZYKŁAD UŻYCIA + INTENCJONALNY BŁĄD   ##
   ############################################# */

-- 1. Usunięcie tabeli, jeśli już istnieje
DROP TABLE IF EXISTS dbo.vectors;
GO

-- 2. Tworzenie tabeli z kolumną VECTOR(3)
CREATE TABLE dbo.vectors (
    id INT PRIMARY KEY,
    v VECTOR(3) NOT NULL
);
GO

-- 3. Informacja o kolumnach tabeli 
--(potwierdzenie typu danych VECTOR)
SELECT 
    table_name, 
    column_name, 
    data_type 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'vectors';
GO

-- 4. Wstawianie przykładowych danych – 7 rekordów
INSERT INTO dbo.vectors (id, v) VALUES 
    (1, '[0.1, 2, 30]'),
    (2, '[-100.2, 0.123, 9.876]'),
    (3, '[1.1, 1.1, 1.1]'),
    (4, '[0.0, 0.0, 0.0]'),
    (5, '[10.0, 20.0, 30.0]'),
    (6, '[3.3, 6.6, 9.9]'),
    (7, '[7.7, 8.8, 9.9]');
GO

-- 5. Pobranie danych z tabeli
SELECT * FROM dbo.vectors;
GO

-- 6. Prawidłowa deklaracja zmiennej typu VECTOR(3)
DECLARE @v VECTOR(3) = '[0.1, 2, 30]';
SELECT @v;
GO

-- 7. Intencjonalny błąd: przypisanie wektora 
--3-elementowego do zmiennej VECTOR(10)
-- To zapytanie spowoduje błąd:
-- error The vector dimensions 10 and 3 do not match.
-- Pokazuje, że wektor musi mieć dokładnie tyle 
--elementów, ile wskazuje typ.

-- Przykład błędny – spowoduje błąd wykonania
DECLARE @invalid VECTOR(10) = '[0.1, 2, 30]';
SELECT @invalid;
GO