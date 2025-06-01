-- Utw�rz tabel� wynik�w graczy
DROP TABLE IF EXISTS dbo.GameScores
CREATE TABLE dbo.GameScores
(
    PlayerID INT PRIMARY KEY,
    PlayerName NVARCHAR(50),
    Score INT
);

-- Dodaj 10 graczy z pocz�tkowymi wynikami
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


-- Domy�lnie, je�li LAQ dzia�a  
-- blokady nak�adane s� dopiero po spe�nieniu warunku Score >= 40

BEGIN TRANSACTION;

UPDATE GameScores
SET Score = Score + 10
WHERE Score >= 20;

-- Sprawd�, co jest zablokowane
SELECT 
    resource_type,
    resource_description,
    request_mode,
    request_status,
    request_session_id
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID
      AND resource_type IN ('KEY', 'PAGE', 'RID', 'XACT');

-- Pozostaw transakcj� otwart�, aby zobaczy� dzia�anie z innej sesji
-- COMMIT TRANSACTION;