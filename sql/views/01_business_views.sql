
CREATE OR ALTER VIEW dbo.vw_MarketByCountry AS
SELECT c.country_name, c.region, COUNT(*) AS instrument_count
FROM dbo.FactInstrument f
JOIN dbo.DimCountry c ON c.country_key = f.country_key
GROUP BY c.country_name, c.region;
GO

CREATE OR ALTER VIEW dbo.vw_MarketByExchange AS
SELECT e.exchange_name, e.exchange_code, at_.asset_type_name, COUNT(*) AS instrument_count
FROM dbo.FactInstrument f
JOIN dbo.DimExchange e ON e.exchange_key = f.exchange_key
JOIN dbo.DimAssetType at_ ON at_.asset_type_key = f.asset_type_key
GROUP BY e.exchange_name, e.exchange_code, at_.asset_type_name;
GO

CREATE OR ALTER VIEW dbo.vw_MarketByCurrency AS
SELECT COALESCE(cur.currency_name, cur.currency_code) AS currency_display,
       cur.currency_code, COUNT(*) AS instrument_count
FROM dbo.FactInstrument f
JOIN dbo.DimCurrency cur ON cur.currency_key = f.currency_key
GROUP BY COALESCE(cur.currency_name, cur.currency_code), cur.currency_code;
GO

CREATE OR ALTER VIEW dbo.vw_AssetClassDominanceByMarket AS
SELECT c.country_name, e.exchange_code, at_.asset_type_name, COUNT(*) AS instrument_count
FROM dbo.FactInstrument f
JOIN dbo.DimCountry c ON c.country_key = f.country_key
JOIN dbo.DimExchange e ON e.exchange_key = f.exchange_key
JOIN dbo.DimAssetType at_ ON at_.asset_type_key = f.asset_type_key
GROUP BY c.country_name, e.exchange_code, at_.asset_type_name;
GO

CREATE OR ALTER VIEW dbo.vw_ThemeByCountryExchange AS
SELECT th.theme_name, at_.asset_type_name, c.country_name, e.exchange_code,
       COUNT(*) AS instrument_count
FROM dbo.FactInstrument f
JOIN dbo.DimTheme th ON th.theme_key = f.theme_key
JOIN dbo.DimAssetType at_ ON at_.asset_type_key = f.asset_type_key
JOIN dbo.DimCountry c ON c.country_key = f.country_key
JOIN dbo.DimExchange e ON e.exchange_key = f.exchange_key
GROUP BY th.theme_name, at_.asset_type_name, c.country_name, e.exchange_code;
GO

CREATE OR ALTER VIEW dbo.vw_CrossAssetThemeCounts AS
SELECT th.theme_name,
       SUM(CASE WHEN at_.asset_type_name = 'Equity' THEN 1 ELSE 0 END) AS equity_count,
       SUM(CASE WHEN at_.asset_type_name = 'ETF'    THEN 1 ELSE 0 END) AS etf_count,
       SUM(CASE WHEN at_.asset_type_name = 'Fund'   THEN 1 ELSE 0 END) AS fund_count,
       COUNT(*) AS total_count
FROM dbo.FactInstrument f
JOIN dbo.DimTheme th ON th.theme_key = f.theme_key
JOIN dbo.DimAssetType at_ ON at_.asset_type_key = f.asset_type_key
GROUP BY th.theme_name;
GO

CREATE OR ALTER VIEW dbo.vw_ThemeCoverageScore AS
SELECT
    th.theme_name,
    COUNT(DISTINCT f.asset_type_key) AS asset_class_breadth,
    COUNT(DISTINCT f.country_key)    AS country_count,
    COUNT(DISTINCT f.exchange_key)   AS exchange_count,
    COUNT(*)                          AS instrument_count,

    ROUND(
        (COUNT(DISTINCT f.asset_type_key) * 1.0 / 3.0) * 33.34 +
        (COUNT(DISTINCT f.country_key) * 1.0 /
            NULLIF((SELECT COUNT(*) FROM dbo.DimCountry), 0)) * 33.33 +
        (COUNT(DISTINCT f.exchange_key) * 1.0 /
            NULLIF((SELECT COUNT(*) FROM dbo.DimExchange), 0)) * 33.33
    , 2) AS theme_coverage_score
FROM dbo.FactInstrument f
JOIN dbo.DimTheme th ON th.theme_key = f.theme_key
GROUP BY th.theme_name;
GO


CREATE OR ALTER VIEW dbo.vw_ThemeEquityVsFundGap AS
SELECT theme_name, equity_count, etf_count, fund_count,
       (etf_count + fund_count) AS etf_fund_count,
       CASE WHEN equity_count > 0
            THEN ROUND((etf_count + fund_count) * 1.0 / equity_count, 3)
            ELSE NULL END AS etf_fund_to_equity_ratio
FROM dbo.vw_CrossAssetThemeCounts;
GO

CREATE OR ALTER VIEW dbo.vw_GeographicIntelligence AS
SELECT c.country_name, c.region, e.exchange_code, th.theme_name,
       at_.asset_type_name, COUNT(*) AS instrument_count
FROM dbo.FactInstrument f
JOIN dbo.DimCountry c ON c.country_key = f.country_key
JOIN dbo.DimExchange e ON e.exchange_key = f.exchange_key
LEFT JOIN dbo.DimTheme th ON th.theme_key = f.theme_key
JOIN dbo.DimAssetType at_ ON at_.asset_type_key = f.asset_type_key
GROUP BY c.country_name, c.region, e.exchange_code, th.theme_name, at_.asset_type_name;
GO


CREATE OR ALTER VIEW dbo.vw_TaxonomyCoverageOverall AS
SELECT
    COUNT(*) AS total_instruments,
    SUM(CASE WHEN theme_key IS NOT NULL THEN 1 ELSE 0 END) AS mapped_instruments,
    ROUND(SUM(CASE WHEN theme_key IS NOT NULL THEN 1.0 ELSE 0 END)
          / NULLIF(COUNT(*), 0) * 100, 2) AS mapped_pct
FROM dbo.FactInstrument;
GO

CREATE OR ALTER VIEW dbo.vw_TaxonomyCoverageByAssetType AS
SELECT at_.asset_type_name,
       COUNT(*) AS total_instruments,
       SUM(CASE WHEN f.theme_key IS NOT NULL THEN 1 ELSE 0 END) AS mapped_instruments,
       ROUND(SUM(CASE WHEN f.theme_key IS NOT NULL THEN 1.0 ELSE 0 END)
             / NULLIF(COUNT(*), 0) * 100, 2) AS mapped_pct
FROM dbo.FactInstrument f
JOIN dbo.DimAssetType at_ ON at_.asset_type_key = f.asset_type_key
GROUP BY at_.asset_type_name;
GO

CREATE OR ALTER VIEW dbo.vw_LowConfidenceMappings AS
SELECT instrument_id, symbol, instrument_name, mapping_confidence
FROM dbo.FactInstrument
WHERE mapping_confidence IS NOT NULL AND mapping_confidence < 0.75;
GO

CREATE OR ALTER VIEW dbo.vw_UnmappedInstruments AS
SELECT f.instrument_id, f.symbol, f.instrument_name, at_.asset_type_name,
       c.country_name, e.exchange_code
FROM dbo.FactInstrument f
JOIN dbo.DimAssetType at_ ON at_.asset_type_key = f.asset_type_key
LEFT JOIN dbo.DimCountry c ON c.country_key = f.country_key
LEFT JOIN dbo.DimExchange e ON e.exchange_key = f.exchange_key
WHERE f.theme_key IS NULL;
GO

CREATE OR ALTER VIEW dbo.vw_UnmappedByCountry AS
SELECT c.country_name, COUNT(*) AS unmapped_count
FROM dbo.FactInstrument f
JOIN dbo.DimCountry c ON c.country_key = f.country_key
WHERE f.theme_key IS NULL
GROUP BY c.country_name;
GO

CREATE OR ALTER VIEW dbo.vw_DataQualityBySourceDataset AS
SELECT dataset, MAX(run_datetime) AS latest_run,
       AVG(quality_score) AS avg_quality_score,
       SUM(invalid_records) AS total_invalid,
       SUM(unmapped_records) AS total_unmapped,
       SUM(duplicate_records) AS total_duplicates
FROM dbo.FactDataQualityRun
GROUP BY dataset;
GO

CREATE OR ALTER VIEW dbo.vw_DataQualityTrend AS
SELECT dataset, run_date_key, run_id, quality_score, total_records,
       valid_records, invalid_records, unmapped_records,
       low_confidence_records, duplicate_records, pipeline_status
FROM dbo.FactDataQualityRun;
GO

CREATE OR ALTER VIEW dbo.vw_LatestPipelineStatus AS
SELECT dataset, run_id, pipeline_status, quality_score, run_datetime
FROM dbo.FactDataQualityRun q
WHERE run_datetime = (
    SELECT MAX(q2.run_datetime) FROM dbo.FactDataQualityRun q2 WHERE q2.dataset = q.dataset
);
GO

CREATE OR ALTER VIEW dbo.vw_DuplicateRateByExchange AS

SELECT e.exchange_code, COUNT(*) AS total_instruments,
       COUNT(*) - COUNT(DISTINCT f.symbol) AS duplicate_symbol_count
FROM dbo.FactInstrument f
JOIN dbo.DimExchange e ON e.exchange_key = f.exchange_key
GROUP BY e.exchange_code;
