-- To powinno dzia³aæ bez czekania, jeœli LAQ jest aktywne:
-- poniewa¿ rekordy z Score <= 19 NIE kwalifikuj¹ siê do UPDATE w pierwszej sesji,
-- wiêc nie zosta³y przez ni¹ zablokowane.
SELECT * FROM GameScores WHERE Score <= 19;

BEGIN TRAN
-- UPDATE te¿ powinien przejœæ bez blokady (jeœli LAQ dzia³a),
-- bo ¿aden z tych wierszy nie by³ zablokowany wczeœniej przez pierwsz¹ transakcjê.
UPDATE GameScores
SET Score = Score + 1
WHERE Score < 19;

COMMIT TRAN


BEGIN TRAN
-- UPDATE nie powinien przejsc z racji blokady na >20 w góre.
UPDATE GameScores
SET Score = Score + 10
WHERE Score > 19;


COMMIT TRAN