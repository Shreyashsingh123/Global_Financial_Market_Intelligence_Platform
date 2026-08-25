IF OBJECT_ID('dbo.DimExchange') IS NOT NULL DROP TABLE dbo.DimExchange;
CREATE TABLE dbo.DimExchange (
    exchange_key    INT IDENTITY(1,1) PRIMARY KEY,
    exchange_name   VARCHAR(150) NOT NULL,
    exchange_code   VARCHAR(10)  NOT NULL,
    country_key     INT          NULL REFERENCES dbo.DimCountry(country_key),
    region          VARCHAR(100) NULL,
    market_type     VARCHAR(50)  NULL,
    CONSTRAINT UQ_DimExchange_Code UNIQUE (exchange_code)
);
