
IF OBJECT_ID('dbo.FactDataQualityRun') IS NOT NULL DROP TABLE dbo.FactDataQualityRun;
CREATE TABLE dbo.FactDataQualityRun (
    quality_run_key         BIGINT IDENTITY(1,1) PRIMARY KEY,
    run_id                  VARCHAR(50)   NOT NULL,
    dataset                 VARCHAR(100)  NULL,
    total_records           INT           NULL,
    valid_records           INT           NULL,
    invalid_records         INT           NULL,
    unmapped_records        INT           NULL,
    low_confidence_records  INT           NULL,
    duplicate_records       INT           NULL,
    quality_score           DECIMAL(5,2)  NULL,
    pipeline_status         VARCHAR(20)   NULL,
    run_date_key            INT           NULL REFERENCES dbo.DimDate(date_key),
    run_datetime            DATETIME2     NULL,
    CONSTRAINT UQ_FactDataQualityRun_RunId UNIQUE (run_id, dataset)
);
