-- To powinno dzia�a� bez czekania, je�li LAQ jest aktywne:
-- poniewa� rekordy z Score <= 19 NIE kwalifikuj� si� do UPDATE w pierwszej sesji,
-- wi�c nie zosta�y przez ni� zablokowane.
SELECT * FROM GameScores WHERE Score <= 19;

BEGIN TRAN
-- UPDATE te� powinien przej�� bez blokady (je�li LAQ dzia�a),
-- bo �aden z tych wierszy nie by� zablokowany wcze�niej przez pierwsz� transakcj�.
UPDATE GameScores
SET Score = Score + 1
WHERE Score < 19;

COMMIT TRAN


BEGIN TRAN
-- UPDATE nie powinien przejsc z racji blokady na >20 w g�re.
UPDATE GameScores
SET Score = Score + 10
WHERE Score > 19;


COMMIT TRAN