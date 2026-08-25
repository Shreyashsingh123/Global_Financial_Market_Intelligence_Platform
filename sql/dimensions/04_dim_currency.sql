
IF OBJECT_ID('dbo.DimCurrency') IS NOT NULL DROP TABLE dbo.DimCurrency;
CREATE TABLE dbo.DimCurrency (
    currency_key     INT IDENTITY(1,1) PRIMARY KEY,
    currency_code    VARCHAR(10)  NOT NULL,
    currency_name    VARCHAR(100) NULL,
    currency_region  VARCHAR(100) NULL,
    currency_type    VARCHAR(50)  NULL,
    CONSTRAINT UQ_DimCurrency_Code UNIQUE (currency_code)
);
