
IF OBJECT_ID('dbo.DimCountry') IS NOT NULL DROP TABLE dbo.DimCountry;
CREATE TABLE dbo.DimCountry (
    country_key      INT IDENTITY(1,1) PRIMARY KEY,
    country_name     VARCHAR(150) NOT NULL,
    iso2             CHAR(2)      NULL,
    iso3             CHAR(3)      NULL,
    region           VARCHAR(100) NULL,
    sub_region       VARCHAR(100) NULL,
    economic_region  VARCHAR(100) NULL,
    CONSTRAINT UQ_DimCountry_Name UNIQUE (country_name)
);
GO