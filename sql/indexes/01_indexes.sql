
CREATE NONCLUSTERED INDEX IX_FactInstrument_AssetType ON dbo.FactInstrument(asset_type_key);
CREATE NONCLUSTERED INDEX IX_FactInstrument_Country    ON dbo.FactInstrument(country_key);
CREATE NONCLUSTERED INDEX IX_FactInstrument_Exchange   ON dbo.FactInstrument(exchange_key);
CREATE NONCLUSTERED INDEX IX_FactInstrument_Currency   ON dbo.FactInstrument(currency_key);
CREATE NONCLUSTERED INDEX IX_FactInstrument_Theme      ON dbo.FactInstrument(theme_key);

CREATE NONCLUSTERED INDEX IX_FactInstrument_Theme_AssetType_Country
    ON dbo.FactInstrument(theme_key, asset_type_key, country_key);

CREATE NONCLUSTERED INDEX IX_FactDataQualityRun_Dataset_Date
    ON dbo.FactDataQualityRun(dataset, run_date_key);

