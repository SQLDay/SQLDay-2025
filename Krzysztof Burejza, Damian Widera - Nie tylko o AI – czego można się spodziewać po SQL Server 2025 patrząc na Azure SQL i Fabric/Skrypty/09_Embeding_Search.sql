/* ############################################################
   ##  ANALIZA EMBEDDING�W RECENZJI GIER PLANSZOWYCH          ##
   ##  WYKORZYSTANIE WEKTOR�W I OBLICZANIE PODOBIE�STWA       ##
   ############################################################ */

/* 1. Usuni�cie tabeli BoardGames_Embeddings, je�li istnieje */
DROP TABLE IF EXISTS [dbo].[BoardGames_Embeddings];

/* 2. Generowanie embedding�w dla kolumny 
UserReview w tabeli BoardGames */
EXEC GenerateColumnEmbeddings 'BoardGames', 'UserReview';

/* 3. Wy�wietlenie zawarto�ci tabeli z embeddingami */
SELECT * FROM [dbo].[BoardGames_Embeddings];

/* 4. Po��czenie tabeli gier planszowych z embeddingami */
SELECT * FROM [dbo].[BoardGames] a
JOIN [dbo].[BoardGames_Embeddings] b ON a.GameID = b.GameID;

/* 5. Pobranie embeddingu dla konkretnej 
frazy "Najlepsza gra" */
DECLARE @embedding NVARCHAR(MAX);
EXEC [dbo].[getEmbeddingAda] 'Najlepsza gra', @embedding OUT;

/* 6. Wy�wietlenie warto�ci wygenerowanego embeddingu */
SELECT @embedding;

/* 7. Deklaracja wektora zapytania o rozmiarze 1536 */
DECLARE @query_vector VECTOR(1536) = @embedding;

/* 8. Znalezienie recenzji o wysokim 
podobie�stwie do zapytania */
SELECT a.GameID, userReview, userReview_EmbeddingAda,
       VECTOR_DISTANCE('COSINE', userReview_EmbeddingAda, @query_vector) AS similarity
FROM [dbo].[BoardGames] a
JOIN [dbo].[BoardGames_Embeddings] b ON a.GameID = b.GameID
WHERE VECTOR_DISTANCE('COSINE', userReview_EmbeddingAda, @query_vector) < 0.2  -- Tylko podobne wiersze
ORDER BY similarity ASC;