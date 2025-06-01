/* #############################################
   ##  OPERACJE NA WEKTORACH W SQL SERVER     ##
   ##  Przykład: gry planszowe jako produkty   ##
   ############################################# */

-- 1. Usunięcie tabeli, jeśli już istnieje
DROP TABLE IF EXISTS dbo.products;
GO

-- 2. Tworzenie tabeli z kolumną VECTOR(3) 
-->– reprezentującą cechy produktu
CREATE TABLE dbo.products (
    id INT PRIMARY KEY,
    name NVARCHAR(50),
    features VECTOR(3) NOT NULL
);
GO

-- 3. Wstawienie 10 przykładowych gier 
--planszowych z przykładowymi wektorami cech
INSERT INTO dbo.products (id, name, features) VALUES
    (1, 'Catan', '[1.0, 2.0, 3.0]'),
    (2, 'Carcassonne', '[1.5, 2.5, 3.5]'),
    (3, 'Gloomhaven', '[10.0, 20.0, 30.0]'),
    (4, 'Ticket to Ride', '[2.0, 4.0, 6.0]'),
    (5, 'Azul', '[3.0, 3.0, 3.0]'),
    (6, '7 Wonders', '[0.5, 1.0, 1.5]'),
    (7, 'Terraforming Mars', '[5.0, 10.0, 15.0]'),
    (8, 'Dixit', '[8.0, 1.0, 2.0]'),
    (9, 'Uno', '[0.0, 0.0, 1.0]'),
    (10, 'Wingspan', '[7.0, 14.0, 21.0]');
GO

-- 4. Obliczenie norm (długości) wektorów dla każdej gry
SELECT 
    name,
    features AS OriginalVector,

    -- Obliczenie normy wektora dla trzech typów: 
    VECTOR_NORM(features, 'norm2') AS EuclideanNorm,   
    -- L2: pierwiastek z sumy kwadratów
    VECTOR_NORM(features, 'norm1') AS ManhattanNorm,   
    -- L1: suma wartości bezwzględnych
    VECTOR_NORM(features, 'norminf') AS MaxNorm        
    -- L∞: największa wartość bezwzględna
FROM dbo.products;
GO

-- 4b. Obliczenie znormalizowanych wektorów dla różnych norm
SELECT 
    name,
    features AS OriginalVector,

    -- Wektor przeskalowany do jednostkowej długości 
    --(dla każdej normy)
    VECTOR_NORMALIZE(
    features, 'norm2') AS Normalized_Euclidean,
    VECTOR_NORMALIZE(
    features, 'norm1') AS Normalized_Manhattan,
    VECTOR_NORMALIZE(
    features, 'norminf') AS Normalized_Max
FROM dbo.products;
GO

-- 5. Obliczanie odległości między grami a "Catan"
--    Pokazuje zarówno dystans euklidesowy, jak i kosinusowy
SELECT 
    p1.name AS Game1,
    p2.name AS Game2,
    p1.features AS Features1,
    p2.features AS Features2,

    VECTOR_DISTANCE(
    'EUCLIDEAN', p1.features, p2.features) AS Distance_Euclidean, 
    -- dystans L2
    VECTOR_DISTANCE(
    'COSINE', p1.features, p2.features) AS Distance_Cosine        
    -- odległość kosinusowa (kąt między wektorami)
FROM dbo.products p1
CROSS JOIN dbo.products p2
WHERE p1.name = 'Catan'; 
-- porównanie wszystkiego względem gry "Catan"
