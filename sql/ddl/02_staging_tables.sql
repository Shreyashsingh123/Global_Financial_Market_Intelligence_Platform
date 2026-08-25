-- Landing tables for ADF Copy Activity.
IF OBJECT_ID('stg.country') IS NOT NULL DROP TABLE stg.country;
CREATE TABLE stg.country (
    country_name     VARCHAR(150) NOT NULL,
    iso2             CHAR(2)      NULL,
    iso3             CHAR(3)      NULL,
    region           VARCHAR(100) NULL,
    country_key      VARCHAR(100) NULL,   
    sub_region       VARCHAR(100) NULL,
    economic_region  VARCHAR(100) NULL
);
GO

IF OBJECT_ID('stg.exchange') IS NOT NULL DROP TABLE stg.exchange;
CREATE TABLE stg.exchange (
    exchange_code    VARCHAR(10)  NOT NULL,
    exchange_name    VARCHAR(150) NOT NULL,
    country_name     VARCHAR(150) NULL,
    iso2             CHAR(2)      NULL,
    iso3             CHAR(3)      NULL,
    region           VARCHAR(100) NULL,
    market_type      VARCHAR(50)  NULL,
    exchange_key     VARCHAR(100) NULL,   
    -- source's own hash-based key, not our surrogate int
    taxonomy_version VARCHAR(10)  NULL,
    is_current       BIT          NULL
);
GO

IF OBJECT_ID('stg.currency') IS NOT NULL DROP TABLE stg.currency;
CREATE TABLE stg.currency (
    currency_code    VARCHAR(10)  NOT NULL,
    currency_name    VARCHAR(100) NULL,      
     -- ~176/187 hold a placeholder like 'UNKNOWN - NOK'
    currency_region  VARCHAR(100) NULL,
    currency_type    VARCHAR(50)  NULL,
    currency_key     VARCHAR(100) NULL,       
    needs_review     BIT          NULL
);
GO

IF OBJECT_ID('stg.financial_catalog') IS NOT NULL DROP TABLE stg.financial_catalog;
CREATE TABLE stg.financial_catalog (
    instrument_id     VARCHAR(100)  NOT NULL,  
    symbol            VARCHAR(30)   NULL,
    name              VARCHAR(250)  NULL,
    asset_type        VARCHAR(20)   NOT NULL,  
    country           VARCHAR(150)  NULL,
    region            VARCHAR(100)  NULL,
    exchange          VARCHAR(10)   NULL,
    currency          VARCHAR(10)   NULL,
    normalized_theme  VARCHAR(50)   NULL,
    mapping_confidence DECIMAL(4,2) NULL,
    record_status     VARCHAR(20)   NULL,
    is_delisted       BIT           NULL
);
GO

IF OBJECT_ID('stg.data_quality_run') IS NOT NULL DROP TABLE stg.data_quality_run;
CREATE TABLE stg.data_quality_run (
    run_id                 VARCHAR(50)   NOT NULL,
    dataset                VARCHAR(100)  NULL,
    total_records          INT           NULL,
    valid_records          INT           NULL,
    invalid_records        INT           NULL,
    unmapped_records       INT           NULL,
    low_confidence_records INT           NULL,
    duplicate_records      INT           NULL,
    quality_score          DECIMAL(5,2)  NULL,
    pipeline_status        VARCHAR(20)   NULL,
    run_timestamp          DATETIME2     NULL
);
GO

-- Three tables simply keep a direct Gold-layer copy for traceability,
--  while Power BI and the vw_* views continue to use the FactInstrument views as the main source of truth.

IF OBJECT_ID('stg.market_universe_summary') IS NOT NULL DROP TABLE stg.market_universe_summary;
CREATE TABLE stg.market_universe_summary (
    country          VARCHAR(150) NULL,
    exchange         VARCHAR(10)  NULL,
    asset_type       VARCHAR(20)  NULL,
    instrument_count INT          NULL
);
GO

IF OBJECT_ID('stg.theme_universe') IS NOT NULL DROP TABLE stg.theme_universe;
CREATE TABLE stg.theme_universe (
    normalized_theme  VARCHAR(50)  NULL,
    asset_type        VARCHAR(20)  NULL,
    country           VARCHAR(150) NULL,
    exchange          VARCHAR(10)  NULL,
    instrument_count  INT          NULL
);
GO

IF OBJECT_ID('stg.cross_asset_theme') IS NOT NULL DROP TABLE stg.cross_asset_theme;
CREATE TABLE stg.cross_asset_theme (
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
GO