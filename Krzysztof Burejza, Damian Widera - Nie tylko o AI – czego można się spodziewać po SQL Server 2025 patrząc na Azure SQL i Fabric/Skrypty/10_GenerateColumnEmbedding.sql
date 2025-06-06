/****** Object:  StoredProcedure [dbo].[GenerateColumnEmbeddings]    Script Date: 13.05.2025 23:36:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[GenerateColumnEmbeddings]
    @sourceTable NVARCHAR(255),
    @columnName NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @newTable NVARCHAR(255) = @sourceTable + '_Embeddings';
    DECLARE @primaryKey NVARCHAR(MAX);
    DECLARE @embeddingColumn NVARCHAR(255) = @columnName + '_EmbeddingAda';
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @text NVARCHAR(MAX);
    DECLARE @embedding NVARCHAR(MAX);
    DECLARE @rowMax INT;
    DECLARE @i INT = 1;
    
    -- Pobranie klucza głównego
    SELECT @primaryKey = c.COLUMN_NAME
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE c 
        ON tc.CONSTRAINT_NAME = c.CONSTRAINT_NAME
    WHERE tc.TABLE_NAME = @sourceTable
          AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';
    
    IF @primaryKey IS NULL
    BEGIN
        PRINT 'Tabela nie posiada klucza głównego.';
        RETURN;
    END
    
    -- Sprawdzenie czy tabela embeddingowa już istnieje
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @newTable)
    BEGIN
        -- Tworzenie tabeli embeddingowej
        SET @sql = 'SELECT ' + QUOTENAME(@primaryKey) + ', CAST(NULL AS VECTOR(1536)) AS ' + QUOTENAME(@embeddingColumn) + ' 
                    INTO ' + QUOTENAME(@newTable) + ' FROM ' + QUOTENAME(@sourceTable) + '';
        EXEC sp_executesql @sql;
    END
    ELSE
    BEGIN
        -- Sprawdzenie czy kolumna już istnieje
        IF NOT EXISTS (
            SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_NAME = @newTable AND COLUMN_NAME = @embeddingColumn
        )
        BEGIN
            -- Dodanie nowej kolumny do istniejącej tabeli embeddingowej
            SET @sql = 'ALTER TABLE ' + QUOTENAME(@newTable) + ' ADD ' + QUOTENAME(@embeddingColumn) + ' VECTOR(1536);';
            EXEC sp_executesql @sql;
        END
    END
    
    -- Pobranie liczby rekordów w tabeli źródłowej
    SET @sql = 'SELECT @rowMax = COUNT(*) FROM ' + QUOTENAME(@sourceTable);
    EXEC sp_executesql @sql, N'@rowMax INT OUTPUT', @rowMax OUTPUT;
    
    -- Iteracja po rekordach w tabeli źródłowej
    WHILE @i <= @rowMax
    BEGIN
        -- Pobranie tekstu (DYNAMICZNIE)
        SET @sql = 'SELECT @text = ' + QUOTENAME(@columnName) + ' FROM ' + QUOTENAME(@sourceTable) + ' WHERE ' + QUOTENAME(@primaryKey) + ' = @i';
        EXEC sp_executesql @sql, N'@text NVARCHAR(MAX) OUTPUT, @i INT', @text OUTPUT, @i;
        
        -- Jeśli tekst nie jest NULL, generujemy embedding
        IF @text IS NOT NULL
        BEGIN
            EXEC dbo.getEmbeddingAda @text, @embedding OUTPUT;
            
            -- Aktualizacja tabeli embeddingowej (DYNAMICZNIE)
            SET @sql = 'UPDATE ' + QUOTENAME(@newTable) + 
                       ' SET ' + QUOTENAME(@embeddingColumn) + ' = @embedding
                         WHERE ' + QUOTENAME(@primaryKey) + ' = @i';
            EXEC sp_executesql @sql, N'@embedding NVARCHAR(MAX), @i INT', @embedding, @i;
        END;
        
        SET @i = @i + 1;
    END;
END;
