-- Utwórz tabelê wyników graczy
DROP TABLE IF EXISTS dbo.GameScores
CREATE TABLE dbo.GameScores
(
    PlayerID INT PRIMARY KEY,
    PlayerName NVARCHAR(50),
    Score INT
);

-- Dodaj 10 graczy z pocz¹tkowymi wynikami
INSERT INTO dbo.GameScores (PlayerID, PlayerName, Score)
VALUES 
(1, 'Alice', 10),
(2, 'Bob', 20),
(3, 'Charlie', 15),
(4, 'Diana', 25),
(5, 'Edward', 30),
(6, 'Fiona', 18),
(7, 'George', 22),
(8, 'Hannah', 12),
(9, 'Ivan', 28),
(10, 'Julia', 16);
GO

SELECT * FROM dbo.GameScores

-- Rozpocznij transakcjê: aktualizacja wyników wszystkich graczy
BEGIN TRANSACTION;

UPDATE GameScores
SET Score = Score + 5;  -- wszyscy gracze zdobywaj¹ +5 punktów

-- Podejrzyj aktualne blokady trzymane przez transakcjê
--Jeœli optimized locking jest w³¹czone, ¿¹danie 
--(transakcja) utrzymuje tylko jedn¹ blokadê typu X (wy³¹czn¹) 
--na zasobie typu XACT (czyli samej transakcji),
--a nie na poszczególnych wierszach, stronach czy kluczach.
SELECT 
    resource_type,
    resource_description,
    request_mode,
    request_status,
    request_session_id
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID
      AND resource_type IN ('PAGE', 'RID', 'KEY', 'XACT');

-- COMMIT zostaw na póŸniej, aby testowaæ blokady z innej sesji
COMMIT TRANSACTION;


