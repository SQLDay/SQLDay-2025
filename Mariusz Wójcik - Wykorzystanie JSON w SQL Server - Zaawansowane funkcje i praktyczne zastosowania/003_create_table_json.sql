-- 1) Utworzenie nowej tabeli z natywnym typem JSON dla kolumn resource i metric
DROP TABLE IF EXISTS [mw].[resource_metrics_json]

CREATE TABLE [mw].[resource_metrics_json] (
    [timestamp]     DATETIME2(3)    NOT NULL,
    resource_type   NVARCHAR(50)    NOT NULL,
    resource        JSON            NOT NULL,
    metric          JSON            NOT NULL
);
GO

-- 2) Przekopiowanie danych ze starej tabeli do nowej, konwertując NVARCHAR→JSON
INSERT INTO [mw].[resource_metrics_json] ([timestamp], resource_type, resource, metric)
SELECT
    [timestamp],
    resource_type,
    CAST(resource AS JSON),
    CAST(metric   AS JSON)
FROM [mw].[resource_metrics];
GO
