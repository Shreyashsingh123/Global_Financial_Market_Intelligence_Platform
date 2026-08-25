-- This table acts as a metadata-driven control list for ADF, 
-- telling the pipeline which Gold Delta data to copy into each staging SQL table

IF OBJECT_ID('dbo.sql_load_metadata') IS NOT NULL
    DROP TABLE dbo.sql_load_metadata;
GO

CREATE TABLE dbo.sql_load_metadata (
    load_id           INT IDENTITY(1,1) PRIMARY KEY,
    source_zone       VARCHAR(20)   NOT NULL,   
    source_container  VARCHAR(50)   NOT NULL,   
    source_path       VARCHAR(200)  NOT NULL,   
    target_schema     VARCHAR(20)   NOT NULL DEFAULT 'stg',
    target_table      VARCHAR(100)  NOT NULL,
    load_type         VARCHAR(20)   NOT NULL DEFAULT 'full',  
    watermark_column  VARCHAR(100)  NULL,
    is_active         BIT           NOT NULL DEFAULT 1,
    last_run_status   VARCHAR(20)   NULL,
    last_run_datetime DATETIME2     NULL
);
GO

INSERT INTO dbo.sql_load_metadata
    (source_zone, source_container, source_path, target_table, load_type, watermark_column)
VALUES
   
    ('silver', 'silver', 'dim_country',                   'country',                'full', NULL),
    ('silver', 'silver', 'dim_exchange',                   'exchange',               'full', NULL),
    ('silver', 'silver', 'dim_currency',                   'currency',               'full', NULL),
    ('gold',   'gold',   'financial_instrument_catalog', 'financial_catalog',      'incremental', 'snapshot_date'),
    ('gold',   'gold',   'data_quality',                  'data_quality_run',       'incremental', 'run_id'),
    ('gold',   'gold',   'market_universe_summary',       'market_universe_summary','full', NULL),
    ('gold',   'gold',   'theme_universe',                'theme_universe',         'full', NULL),
    ('gold',   'gold',   'cross_asset_theme',             'cross_asset_theme',      'full', NULL);
GO
