
-- 1a) NVARCHAR(1000)
SET STATISTICS IO ON; SET STATISTICS TIME ON;
SELECT COUNT(*) 
FROM mw.resource_metrics
WHERE TRY_CAST(JSON_VALUE(metric, '$.counts.row_count') AS BIGINT) > 1000;
GO

-- 1b) kolumna JSON
SET STATISTICS IO ON; SET STATISTICS TIME ON;
SELECT COUNT(*) 
FROM mw.resource_metrics_json
WHERE TRY_CAST(JSON_VALUE(metric, '$.counts.row_count') AS BIGINT) > 1000;
GO


-- 2a) NVARCHAR(1000)
SET STATISTICS IO ON; SET STATISTICS TIME ON;
SELECT rm.[timestamp], cnt.row_count
FROM mw.resource_metrics AS rm
CROSS APPLY OPENJSON(rm.metric, '$.counts')
  WITH (row_count BIGINT '$.row_count') AS cnt;
GO

-- 2b) JSON
SET STATISTICS IO ON; SET STATISTICS TIME ON;
SELECT rm.[timestamp], cnt.row_count
FROM mw.resource_metrics_json AS rm
CROSS APPLY OPENJSON(rm.metric, '$.counts')
  WITH (row_count BIGINT '$.row_count') AS cnt;
GO


-- 3a) NVARCHAR(1000) z ISJSON+JSON_VALUE
SET STATISTICS IO ON; SET STATISTICS TIME ON;
SELECT COUNT(*) 
FROM mw.resource_metrics
WHERE ISJSON(metric)=1
  AND JSON_VALUE(metric,'$.counts.partition_keys') IS NOT NULL;
GO

-- 3b) natywny JSON + JSON_EXISTS
SET STATISTICS IO ON; SET STATISTICS TIME ON;

SELECT COUNT(*) 
FROM mw.resource_metrics_json
WHERE ISJSON(metric)=1
  AND JSON_VALUE(metric,'$.counts.partition_keys') IS NOT NULL;
GO


ALTER TABLE mw.resource_metrics
  ADD row_count AS TRY_CAST(JSON_VALUE(metric,'$.counts.row_count') AS BIGINT) PERSISTED;
CREATE INDEX IX_mw_rm_json_rowcount
  ON mw.resource_metrics(row_count);



  -- bez indeksu (pełne JSON_VALUE)
SET STATISTICS IO ON; SET STATISTICS TIME ON;
SELECT COUNT(*) 
FROM mw.resource_metrics
WHERE TRY_CAST(JSON_VALUE(metric,'$.counts.row_count') AS BIGINT) > 1000;
GO

-- z indeksem na kolumnie persisted
SET STATISTICS IO ON; SET STATISTICS TIME ON;
SELECT COUNT(*) 
FROM mw.resource_metrics
WHERE row_count > 1000;
GO

ALTER TABLE mw.resource_metrics
ALTER COLUMN metric JSON NOT NULL


ALTER TABLE mw.resource_metrics
DROP COLUMN row_count

DROP INDEX IX_mw_rm_json_rowcount on mw.resource_metrics




