DROP TABLE IF EXISTS [mw].[resource_metrics];

CREATE TABLE [mw].[resource_metrics](
	[timestamp] DATETIME2(3)  NULL,
	[resource_type] NVARCHAR(50) NULL,
	[resource] NVARCHAR(1000) NULL,
	[metric] NVARCHAR(1000) NULL
);
GO

-- Wstawienie jednego rekordu przykładowego
INSERT INTO [mw].[resource_metrics] ([timestamp], resource_type, resource, metric)
VALUES
  ('2023-07-30 02:49:11.860', 'DATABRICKS',
    '{"db_name":"randomDB1","schema":"dev001","table_name":"fact_sales"}',
    '{
      "storage": {
        "size_b": 488246,
        "avg_row_size_b": 30,
        "compression_ratio": 0.75
      },
      "counts": {
        "row_count": 16423,
        "partition_count": 4,
        "partition_keys": ["sale_date","region"]
      },
      "operations": {
        "inserts": 15000,
        "updates": 1423,
        "last_operation": "2023-05-24T14:16:29Z"
      }
    }'
  );

-- Deklaracja zmiennych
DECLARE 
    @i INT = 1,
    @size_b INT,
    @row_count INT,
    @avg_row_size INT,
    @compression_ratio FLOAT,
    @partition_count INT,
    @updates INT,
    @inserts INT;

-- Generowanie danych
WHILE @i <= 99
BEGIN
    -- Losowe przypisania
    SET @size_b = 10000 + ABS(CHECKSUM(NEWID())) % 10000000;
    SET @row_count = 100 + ABS(CHECKSUM(NEWID())) % 1000000;
    SET @avg_row_size = 10 + ABS(CHECKSUM(NEWID())) % 50;
    SET @compression_ratio = CAST(50 + ABS(CHECKSUM(NEWID())) % 50 AS FLOAT) / 100;
    SET @partition_count = 1 + ABS(CHECKSUM(NEWID())) % 12;
    SET @updates = ABS(CHECKSUM(NEWID())) % 1000;
    SET @inserts = @row_count - @updates;

    -- Wstawienie rekordu
    INSERT INTO [mw].[resource_metrics] ([timestamp], resource_type, resource, metric)
    VALUES (
        DATEADD(SECOND, @i, '2023-07-30T03:00:00.000'),
        'DATABRICKS',
        CONCAT('{"db_name":"randomDB1","schema":"dev001","table_name":"auto_table_', @i, '"}'),
        CONCAT('{
          "storage": {
            "size_b": ', @size_b, ',
            "avg_row_size_b": ', @avg_row_size, ',
            "compression_ratio": ', @compression_ratio, '
          },
          "counts": {
            "row_count": ', @row_count, ',
            "partition_count": ', @partition_count, ',
            "partition_keys": ["key_', @i, '"]
          },
          "operations": {
            "inserts": ', @inserts, ',
            "updates": ', @updates, ',
            "last_operation": "2023-05-30T12:00:', RIGHT('00' + CAST(@i % 60 AS NVARCHAR), 2), 'Z"
          }
        }')
    );

    SET @i += 1;
END;
