-- =============================================================================
-- 1. Sprawdzenie poprawności JSON-ów
--    Weryfikacja, które wiersze mają niepoprawne JSON-y w kolumnach `resource` i `metric`.
--    Funkcja: ISJSON()
-- =============================================================================

SELECT [timestamp]
      ,[resource_type]
      ,[resource]
      ,[metric]
  FROM [mw].[resource_metrics]


SELECT
    COUNT(*)                             AS total_rows,
    SUM(IIF(ISJSON(resource) = 1, 0, 1)) AS invalid_resource,
    SUM(IIF(ISJSON(metric)   = 1, 0, 1)) AS invalid_metric
FROM [mw].[resource_metrics];


-- =============================================================================
-- 2. Wydobycie wartości skalarnych z JSON-a
--    Wyciąganie pojedynczych właściwości i rzutowanie ich na odpowiednie typy.
--    Funkcje: JSON_VALUE()
-- =============================================================================
SELECT
    JSON_VALUE(resource, '$.db_name')                 AS db_name,
    JSON_VALUE(resource, '$.schema')                  AS schema_name,
    JSON_VALUE(resource, '$.table_name')              AS table_name,
    TRY_CAST(JSON_VALUE(metric, '$.storage.size_b')   AS BIGINT) AS size_b,
    TRY_CAST(JSON_VALUE(metric, '$.counts.row_count') AS BIGINT) AS row_count
FROM [mw].[resource_metrics];


-- =============================================================================
-- 3. Wydobycie całych struktur lub tablic z JSON-a
--    Zwracanie fragmentów JSON-a jako tekstu (obiektów lub tablic).
--    Funkcja: JSON_QUERY()
-- =============================================================================
SELECT
    JSON_QUERY(metric, '$.storage')               AS storage_json,
    JSON_QUERY(metric, '$.counts.partition_keys') AS partition_keys_json
FROM [mw].[resource_metrics];


-- =============================================================================
-- 4. Modyfikacja JSON „w locie”
--    Aktualizacja wybranego pola w JSON-ie i dodanie sufiksu strefy czasowej.
--    Funkcja: JSON_MODIFY()
-- =============================================================================
SELECT
    resource_type,
    JSON_MODIFY(
        metric,
        '$.operations.last_operation',
        CONCAT(
            FORMAT(
                TRY_CAST(JSON_VALUE(metric, '$.operations.last_operation') AS DATETIME2),
                'yyyy-MM-dd HH:mm:ss'
            ),
            '+01:00'    -- dodanie sufiksu strefy
        )
    ) AS metric_with_tz
FROM [mw].[resource_metrics];


-- =============================================================================
-- 5. Rozbicie JSON-a na wiersze i kolumny przy pomocy OPENJSON
--    a) Strukturalne otwarcie obiektu `counts`
--    b) Iteracja po tablicy `partition_keys`
--    Funkcja: OPENJSON()
-- =============================================================================

-- 5a) Strukturalne otwarcie obiektu “counts”
SELECT
    rm.[timestamp],
    rm.resource_type,
    cnt.row_count,
    cnt.partition_count
FROM [mw].[resource_metrics] AS rm
CROSS APPLY OPENJSON(rm.metric, '$.counts')
    WITH (
        row_count       BIGINT '$.row_count',
        partition_count INT     '$.partition_count'
    ) AS cnt;

-- 5b) Iteracja po tablicy “partition_keys”
SELECT
    rm.[timestamp],
    rm.resource_type,
    pk.[value]       AS partition_key
FROM [mw].[resource_metrics] AS rm
CROSS APPLY OPENJSON(rm.metric, '$.counts.partition_keys') AS pk;


-- =============================================================================
-- 6. Widok łączący wszystkie techniki
--    Prezentacja walidacji i wyodrębnionych pól w jednym widoku.
-- =============================================================================
CREATE OR ALTER VIEW [mw].[vw_resource_metrics_flat] AS
SELECT
    rm.[timestamp],
    rm.resource_type,

    -- Walidacja JSON-ów
    ISJSON(rm.resource) AS is_resource_valid,
    ISJSON(rm.metric)   AS is_metric_valid,

    -- Wartości skalarnych pól
    JSON_VALUE(rm.resource, '$.db_name')                 AS db_name,
    JSON_VALUE(rm.resource, '$.schema')                  AS schema_name,
    JSON_VALUE(rm.resource, '$.table_name')              AS table_name,
    TRY_CAST(JSON_VALUE(rm.metric,   '$.storage.size_b')   AS BIGINT) AS size_b,
    TRY_CAST(JSON_VALUE(rm.metric,   '$.counts.row_count') AS BIGINT) AS row_count,

    -- Całe podstruktury/tablice
    JSON_QUERY(rm.metric, '$.storage')               AS storage_obj,
    JSON_QUERY(rm.metric, '$.counts.partition_keys') AS partition_keys,

    -- Modyfikacja pola last_operation
    JSON_MODIFY(
        rm.metric,
        '$.operations.last_operation',
        CONCAT(
            FORMAT(
                TRY_CAST(JSON_VALUE(rm.metric, '$.operations.last_operation') AS DATETIME2),
                'yyyy-MM-dd HH:mm:ss'
            ),
            '+01:00'
        )
    ) AS metric_with_updated_ts
FROM [mw].[resource_metrics] AS rm;



SELECT TOP (1000) [timestamp]
      ,[resource_type]
      ,[is_resource_valid]
      ,[is_metric_valid]
      ,[db_name]
      ,[schema_name]
      ,[table_name]
      ,[size_b]
      ,[row_count]
      ,[storage_obj]
      ,[partition_keys]
      ,[metric_with_updated_ts]
  FROM [mw].[vw_resource_metrics_flat]

-- =============================================================================
-- 7. Filtrowanie i agregacje JSON
--    a) Tylko wiersze z tablicą `partition_keys`
--    b) Agregacja nazw tabel do JSON-owej tablicy lub obiektu
-- =============================================================================

-- 7a) Filtrowanie wierszy zawierających `partition_keys`
SELECT
    [timestamp],
    JSON_VALUE(resource, '$.table_name')           AS table_name,
    JSON_QUERY(metric, '$.counts.partition_keys')  AS partition_keys
FROM [mw].[resource_metrics]
WHERE JSON_PATH_EXISTS(metric, '$.counts.partition_keys') = 1;

-- 7b) Agregacja nazw tabel do JSON-owej tablicy
SELECT
    JSON_ARRAYAGG(JSON_VALUE(resource, '$.table_name')) AS all_tables
FROM [mw].[resource_metrics];

-- 7c) Agregacja nazw tabel do JSON-owego obiektu klucz-wartoœæ
SELECT
    JSON_OBJECTAGG('table_name' : JSON_VALUE(resource, '$.table_name')) AS all_tables
FROM [mw].[resource_metrics];
