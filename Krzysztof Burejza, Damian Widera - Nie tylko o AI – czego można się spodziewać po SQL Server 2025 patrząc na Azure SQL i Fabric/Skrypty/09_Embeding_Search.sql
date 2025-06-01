/* ############################################################
   ##  ANALIZA EMBEDDINGÓW RECENZJI GIER PLANSZOWYCH          ##
   ##  WYKORZYSTANIE WEKTORÓW I OBLICZANIE PODOBIEÑSTWA       ##
   ############################################################ */

/* 1. Usuniêcie tabeli BoardGames_Embeddings, jeœli istnieje */
DROP TABLE IF EXISTS [dbo].[BoardGames_Embeddings];

/* 2. Generowanie embeddingów dla kolumny 
UserReview w tabeli BoardGames */
EXEC GenerateColumnEmbeddings 'BoardGames', 'UserReview';

/* 3. Wyœwietlenie zawartoœci tabeli z embeddingami */
SELECT * FROM [dbo].[BoardGames_Embeddings];

/* 4. Po³¹czenie tabeli gier planszowych z embeddingami */
SELECT * FROM [dbo].[BoardGames] a
JOIN [dbo].[BoardGames_Embeddings] b ON a.GameID = b.GameID;

/* 5. Pobranie embeddingu dla konkretnej 
frazy "Najlepsza gra" */
DECLARE @embedding NVARCHAR(MAX);
EXEC [dbo].[getEmbeddingAda] 'Najlepsza gra', @embedding OUT;

/* 6. Wyœwietlenie wartoœci wygenerowanego embeddingu */
SELECT @embedding;

/* 7. Deklaracja wektora zapytania o rozmiarze 1536 */
DECLARE @query_vector VECTOR(1536) = @embedding;

/* 8. Znalezienie recenzji o wysokim 
podobieñstwie do zapytania */
SELECT a.GameID, userReview, userReview_EmbeddingAda,
       VECTOR_DISTANCE('COSINE', userReview_EmbeddingAda, @query_vector) AS similarity
FROM [dbo].[BoardGames] a
JOIN [dbo].[BoardGames_Embeddings] b ON a.GameID = b.GameID
WHERE VECTOR_DISTANCE('COSINE', userReview_EmbeddingAda, @query_vector) < 0.2  -- Tylko podobne wiersze
ORDER BY similarity ASC;