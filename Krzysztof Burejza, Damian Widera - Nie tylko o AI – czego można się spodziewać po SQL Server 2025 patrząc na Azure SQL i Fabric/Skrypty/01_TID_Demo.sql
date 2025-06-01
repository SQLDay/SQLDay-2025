-- Utw�rz tabel� wynik�w graczy
DROP TABLE IF EXISTS dbo.GameScores
CREATE TABLE dbo.GameScores
(
    PlayerID INT PRIMARY KEY,
    PlayerName NVARCHAR(50),
    Score INT
);

-- Dodaj 10 graczy z pocz�tkowymi wynikami
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

-- Rozpocznij transakcj�: aktualizacja wynik�w wszystkich graczy
BEGIN TRANSACTION;

UPDATE GameScores
SET Score = Score + 5;  -- wszyscy gracze zdobywaj� +5 punkt�w

-- Podejrzyj aktualne blokady trzymane przez transakcj�
--Je�li optimized locking jest w��czone, ��danie 
--(transakcja) utrzymuje tylko jedn� blokad� typu X (wy��czn�) 
--na zasobie typu XACT (czyli samej transakcji),
--a nie na poszczeg�lnych wierszach, stronach czy kluczach.
SELECT 
    resource_type,
    resource_description,
    request_mode,
    request_status,
    request_session_id
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID
      AND resource_type IN ('PAGE', 'RID', 'KEY', 'XACT');

-- COMMIT zostaw na p�niej, aby testowa� blokady z innej sesji
COMMIT TRANSACTION;


