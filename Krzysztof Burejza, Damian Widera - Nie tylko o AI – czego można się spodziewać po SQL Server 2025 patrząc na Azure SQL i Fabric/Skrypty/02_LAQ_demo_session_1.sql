-- Utwórz tabelê wyników graczy
DROP TABLE IF EXISTS dbo.GameScores
CREATE TABLE dbo.GameScores
(
    PlayerID INT PRIMARY KEY,
    PlayerName NVARCHAR(50),
    Score INT
);

-- Dodaj 10 graczy z pocz¹tkowymi wynikami
INSERT INTO GameScores (PlayerID, PlayerName, Score)
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


-- Domyœlnie, jeœli LAQ dzia³a  
-- blokady nak³adane s¹ dopiero po spe³nieniu warunku Score >= 40

BEGIN TRANSACTION;

UPDATE GameScores
SET Score = Score + 10
WHERE Score >= 20;

-- SprawdŸ, co jest zablokowane
SELECT 
    resource_type,
    resource_description,
    request_mode,
    request_status,
    request_session_id
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID
      AND resource_type IN ('KEY', 'PAGE', 'RID', 'XACT');

-- Pozostaw transakcjê otwart¹, aby zobaczyæ dzia³anie z innej sesji
-- COMMIT TRANSACTION;