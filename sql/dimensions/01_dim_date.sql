
IF OBJECT_ID('dbo.DimDate') IS NOT NULL DROP TABLE dbo.DimDate;
CREATE TABLE dbo.DimDate (
    date_key      INT         NOT NULL PRIMARY KEY,   -- yyyymmdd
    full_date     DATE        NOT NULL,
    year          SMALLINT    NOT NULL,
    quarter       TINYINT     NOT NULL,
    month         TINYINT     NOT NULL,
    month_name    VARCHAR(10) NOT NULL,
    day           TINYINT     NOT NULL,
    day_of_week   TINYINT     NOT NULL,
    day_name      VARCHAR(10) NOT NULL,
    is_weekend    BIT         NOT NULL
);
GO

DECLARE @StartDate DATE = '2024-01-01';
DECLARE @EndDate   DATE = '2030-12-31';

;WITH Dates AS (
    SELECT @StartDate AS d
    UNION ALL
    SELECT DATEADD(DAY, 1, d) FROM Dates WHERE d < @EndDate
)
INSERT INTO dbo.DimDate
SELECT
    CONVERT(INT, FORMAT(d, 'yyyyMMdd'))   AS date_key,
    d                                      AS full_date,
    YEAR(d)                                AS year,
    DATEPART(QUARTER, d)                   AS quarter,
    MONTH(d)                               AS month,
    DATENAME(MONTH, d)                      AS month_name,
    DAY(d)                                  AS day,
    DATEPART(WEEKDAY, d)                    AS day_of_week,
    DATENAME(WEEKDAY, d)                     AS day_name,
    CASE WHEN DATEPART(WEEKDAY, d) IN (1,7) THEN 1 ELSE 0 END AS is_weekend
FROM Dates
OPTION (MAXRECURSION 0);
GO