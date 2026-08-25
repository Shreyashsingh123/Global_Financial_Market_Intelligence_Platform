-- Creates the dbo schema for curated Power BI tables and the stg schema for ADF data loading

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stg')
    EXEC('CREATE SCHEMA stg AUTHORIZATION dbo');
GO

