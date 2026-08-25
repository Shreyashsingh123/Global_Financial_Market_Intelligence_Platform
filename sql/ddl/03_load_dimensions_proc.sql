
CREATE OR ALTER PROCEDURE dbo.usp_LoadDimCountry
AS
BEGIN
    SET NOCOUNT ON;
    MERGE dbo.DimCountry AS tgt
    USING (
        SELECT country_name, iso2, iso3, region, sub_region, economic_region
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY country_name ORDER BY (SELECT NULL)) AS rn
            FROM stg.country
        ) d
        WHERE rn = 1
    ) AS src
        ON tgt.country_name = src.country_name
    WHEN MATCHED THEN UPDATE SET
        iso2 = src.iso2, iso3 = src.iso3, region = src.region,
        sub_region = src.sub_region, economic_region = src.economic_region
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (country_name, iso2, iso3, region, sub_region, economic_region)
        VALUES (src.country_name, src.iso2, src.iso3, src.region, src.sub_region, src.economic_region);
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_LoadDimExchange
AS
BEGIN
    SET NOCOUNT ON;
    MERGE dbo.DimExchange AS tgt
    USING (
        SELECT d.exchange_name, d.exchange_code, d.region, d.market_type, c.country_key
        FROM (
            SELECT e.exchange_name, e.exchange_code, e.country_name, e.region, e.market_type,
                   ROW_NUMBER() OVER (
                       PARTITION BY e.exchange_code
                       ORDER BY CASE WHEN e.is_current = 1 THEN 0 ELSE 1 END
                   ) AS rn
            FROM stg.exchange e
        ) d
        LEFT JOIN dbo.DimCountry c ON c.country_name = d.country_name
        WHERE d.rn = 1
    ) AS src
        ON tgt.exchange_code = src.exchange_code
    WHEN MATCHED THEN UPDATE SET
        exchange_name = src.exchange_name, country_key = src.country_key,
        region = src.region, market_type = src.market_type
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (exchange_name, exchange_code, country_key, region, market_type)
        VALUES (src.exchange_name, src.exchange_code, src.country_key, src.region, src.market_type);
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_LoadDimCurrency
AS
BEGIN
    SET NOCOUNT ON;
    MERGE dbo.DimCurrency AS tgt
    USING (
        SELECT currency_code, currency_name, currency_region, currency_type
        FROM (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY currency_code ORDER BY (SELECT NULL)) AS rn
            FROM stg.currency
        ) d
        WHERE rn = 1
    ) AS src
        ON tgt.currency_code = src.currency_code
    WHEN MATCHED THEN UPDATE SET
        currency_name = src.currency_name, currency_region = src.currency_region,
        currency_type = src.currency_type
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (currency_code, currency_name, currency_region, currency_type)
        VALUES (src.currency_code, src.currency_name, src.currency_region, src.currency_type);
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_LoadAllDimensions
AS
BEGIN
    EXEC dbo.usp_LoadDimCountry;
    EXEC dbo.usp_LoadDimExchange;   
    EXEC dbo.usp_LoadDimCurrency;
END
GO