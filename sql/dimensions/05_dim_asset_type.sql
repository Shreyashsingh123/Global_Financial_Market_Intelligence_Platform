
IF OBJECT_ID('dbo.DimAssetType') IS NOT NULL DROP TABLE dbo.DimAssetType;
CREATE TABLE dbo.DimAssetType (
    asset_type_key   INT IDENTITY(1,1) PRIMARY KEY,
    asset_type_name  VARCHAR(20) NOT NULL,
    CONSTRAINT UQ_DimAssetType_Name UNIQUE (asset_type_name)
);
GO

INSERT INTO dbo.DimAssetType (asset_type_name) VALUES ('Equity'), ('ETF'), ('Fund');
