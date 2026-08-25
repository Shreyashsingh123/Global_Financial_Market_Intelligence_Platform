
IF OBJECT_ID('dbo.FactInstrument') IS NOT NULL DROP TABLE dbo.FactInstrument;
CREATE TABLE dbo.FactInstrument (
    instrument_key      BIGINT IDENTITY(1,1) PRIMARY KEY,
    instrument_id        VARCHAR(100)  NOT NULL,  
    symbol               VARCHAR(30)   NULL,
    instrument_name       VARCHAR(250)  NULL,
    asset_type_key       INT           NOT NULL REFERENCES dbo.DimAssetType(asset_type_key),
    country_key          INT           NULL REFERENCES dbo.DimCountry(country_key),
    exchange_key         INT           NULL REFERENCES dbo.DimExchange(exchange_key),
    currency_key         INT           NULL REFERENCES dbo.DimCurrency(currency_key),
    theme_key            INT           NULL REFERENCES dbo.DimTheme(theme_key),
    mapping_confidence   DECIMAL(4,2)  NULL,
    record_status        VARCHAR(20)   NULL,  
    is_delisted          BIT           NULL,
    CONSTRAINT UQ_FactInstrument_InstrumentId UNIQUE (instrument_id)
);
