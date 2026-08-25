
IF OBJECT_ID('dbo.DimTheme') IS NOT NULL DROP TABLE dbo.DimTheme;
CREATE TABLE dbo.DimTheme (
    theme_key    INT IDENTITY(1,1) PRIMARY KEY,
    theme_name   VARCHAR(50) NOT NULL,
    CONSTRAINT UQ_DimTheme_Name UNIQUE (theme_name)
);
GO

INSERT INTO dbo.DimTheme (theme_name) VALUES
    ('Technology'), ('Healthcare'), ('Energy'), ('Financial Services'),
    ('Industrials'), ('Consumer'), ('Real Estate'), ('Utilities'), ('Materials');
