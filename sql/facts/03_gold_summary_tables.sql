IF OBJECT_ID('dbo.GoldMarketUniverseSummary') IS NOT NULL DROP TABLE dbo.GoldMarketUniverseSummary;
CREATE TABLE dbo.GoldMarketUniverseSummary (
    country          VARCHAR(150) NULL,
    exchange         VARCHAR(10)  NULL,
    asset_type       VARCHAR(20)  NULL,
    instrument_count INT          NULL
);
GO

IF OBJECT_ID('dbo.GoldThemeUniverse') IS NOT NULL DROP TABLE dbo.GoldThemeUniverse;
CREATE TABLE dbo.GoldThemeUniverse (
    normalized_theme  VARCHAR(50)  NULL,
    asset_type        VARCHAR(20)  NULL,
    country           VARCHAR(150) NULL,
    exchange          VARCHAR(10)  NULL,
    instrument_count  INT          NULL
);
GO

IF OBJECT_ID('dbo.GoldCrossAssetTheme') IS NOT NULL DROP TABLE dbo.GoldCrossAssetTheme;
CREATE TABLE dbo.GoldCrossAssetTheme (
    normalized_theme      VARCHAR(50)  NULL,
    equity_count          INT          NULL,
    etf_count             INT          NULL,
    fund_count            INT          NULL,
    asset_class_breadth   INT          NULL,
    country_count         INT          NULL,
    exchange_count        INT          NULL,
    total_instruments     INT          NULL,
    theme_coverage_score  DECIMAL(6,2) NULL
);
