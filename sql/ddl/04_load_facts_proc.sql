
CREATE OR ALTER PROCEDURE dbo.usp_LoadFactInstrument
AS
BEGIN
    SET NOCOUNT ON;

    MERGE dbo.FactInstrument AS tgt
    USING (
        SELECT
            f.instrument_id,
            f.symbol,
            f.name AS instrument_name,
            at_.asset_type_key,
            c.country_key,
            e.exchange_key,
            cur.currency_key,
            th.theme_key,
            f.mapping_confidence,
            f.record_status,
            f.is_delisted
        FROM stg.financial_catalog f
        LEFT JOIN dbo.DimAssetType at_ ON LOWER(at_.asset_type_name) = LOWER(f.asset_type)
        LEFT JOIN dbo.DimCountry   c   ON c.country_name      = f.country
        LEFT JOIN dbo.DimExchange  e   ON e.exchange_code     = f.exchange
        LEFT JOIN dbo.DimCurrency  cur ON cur.currency_code   = f.currency
        LEFT JOIN dbo.DimTheme     th  ON th.theme_name       = f.normalized_theme
    ) AS src
        ON tgt.instrument_id = src.instrument_id
    WHEN MATCHED THEN UPDATE SET
        symbol = src.symbol, instrument_name = src.instrument_name,
        asset_type_key = src.asset_type_key, country_key = src.country_key,
        exchange_key = src.exchange_key, currency_key = src.currency_key,
        theme_key = src.theme_key, mapping_confidence = src.mapping_confidence,
        record_status = src.record_status, is_delisted = src.is_delisted
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (instrument_id, symbol, instrument_name, asset_type_key, country_key,
                exchange_key, currency_key, theme_key, mapping_confidence,
                record_status, is_delisted)
        VALUES (src.instrument_id, src.symbol, src.instrument_name, src.asset_type_key,
                src.country_key, src.exchange_key, src.currency_key, src.theme_key,
                src.mapping_confidence, src.record_status, src.is_delisted);
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_LoadFactDataQualityRun
AS
BEGIN
    SET NOCOUNT ON;

    MERGE dbo.FactDataQualityRun AS tgt
    USING (
        SELECT
            q.run_id, q.dataset, q.total_records, q.valid_records,
            q.invalid_records, q.unmapped_records, q.low_confidence_records,
            q.duplicate_records, q.quality_score, q.pipeline_status,
            CONVERT(INT, FORMAT(q.run_timestamp, 'yyyyMMdd')) AS run_date_key,
            q.run_timestamp
        FROM stg.data_quality_run q
    ) AS src
        ON tgt.run_id = src.run_id AND tgt.dataset = src.dataset
    WHEN MATCHED THEN UPDATE SET
        total_records = src.total_records, valid_records = src.valid_records,
        invalid_records = src.invalid_records, unmapped_records = src.unmapped_records,
        low_confidence_records = src.low_confidence_records,
        duplicate_records = src.duplicate_records, quality_score = src.quality_score,
        pipeline_status = src.pipeline_status, run_date_key = src.run_date_key,
        run_datetime = src.run_timestamp
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (run_id, dataset, total_records, valid_records, invalid_records,
                unmapped_records, low_confidence_records, duplicate_records,
                quality_score, pipeline_status, run_date_key, run_datetime)
        VALUES (src.run_id, src.dataset, src.total_records, src.valid_records,
                src.invalid_records, src.unmapped_records, src.low_confidence_records,
                src.duplicate_records, src.quality_score, src.pipeline_status,
                src.run_date_key, src.run_timestamp);
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_LoadGoldSummaryPassthrough
AS
BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE dbo.GoldMarketUniverseSummary;
    INSERT INTO dbo.GoldMarketUniverseSummary SELECT * FROM stg.market_universe_summary;

    TRUNCATE TABLE dbo.GoldThemeUniverse;
    INSERT INTO dbo.GoldThemeUniverse SELECT * FROM stg.theme_universe;

    TRUNCATE TABLE dbo.GoldCrossAssetTheme;
    INSERT INTO dbo.GoldCrossAssetTheme SELECT * FROM stg.cross_asset_theme;
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_LoadAllFacts
AS
BEGIN
    EXEC dbo.usp_LoadFactInstrument;
    EXEC dbo.usp_LoadFactDataQualityRun;
    EXEC dbo.usp_LoadGoldSummaryPassthrough;
END
GO

/* A single Stored Procedure Activity that ADF calls at the end of PL_Gold_To_SQL. */
   
CREATE OR ALTER PROCEDURE dbo.usp_LoadStarSchema
AS
BEGIN
    EXEC dbo.usp_LoadAllDimensions;
    EXEC dbo.usp_LoadAllFacts;
END
GO