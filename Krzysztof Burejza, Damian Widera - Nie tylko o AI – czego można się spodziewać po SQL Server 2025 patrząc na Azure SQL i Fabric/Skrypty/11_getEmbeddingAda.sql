/****** Object:  StoredProcedure [dbo].[getEmbeddingAda]    Script Date: 13.05.2025 23:37:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[getEmbeddingAda] 
    @inputText NVARCHAR(MAX), 
    @embedding NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @url NVARCHAR(4000) = N'Podaj swoj endpoint';
    DECLARE @headers NVARCHAR(102) = N'{"api-key":"Podaj swoj apikey"}';
    DECLARE @payload NVARCHAR(MAX);
    DECLARE @ret INT, @response NVARCHAR(MAX);

    -- Tworzenie poprawnego JSON-a (z poprawnym escape'owaniem cudzysłowów)
    SET @payload = N'{"input": ["' + REPLACE(@inputText, '"', '\"') + '"], "model": "text-embedding-ada-002"}';

    -- Wysyłanie zapytania do API OpenAI
    EXEC @ret = sp_invoke_external_rest_endpoint
        @url = @url,
        @method = 'POST',
        @headers = @headers,
        @payload = @payload,
        @timeout = 230,
        @response = @response OUTPUT;

    -- Obsługa błędów, jeśli API zwróciło błąd
    IF @ret <> 0 OR @response IS NULL OR JSON_VALUE(@response, '$.error') IS NOT NULL
    BEGIN
        PRINT 'Błąd podczas pobierania embeddingu';
        PRINT @response;
        SET @embedding = NULL;
        RETURN;
    END

    -- Wyciąganie embeddingu
    SET @embedding = JSON_QUERY(@response, '$.result.data[0].embedding');

    -- Zwrot wyniku (opcjonalny)
    RETURN;
END;
