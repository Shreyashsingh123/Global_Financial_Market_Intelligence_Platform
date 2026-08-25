
CREATE TABLE dbo.ingestion_metadata (
    dataset_name           VARCHAR(100)  NOT NULL PRIMARY KEY,
    asset_type              VARCHAR(20)   NOT NULL,      
    exchange_code           VARCHAR(10)   NOT NULL,      
    source_url               VARCHAR(500)  NOT NULL,      
    bronze_container         VARCHAR(20)   NOT NULL,     
    bronze_target_path       VARCHAR(200)  NOT NULL,      
    is_active                CHAR(1)       NOT NULL DEFAULT 'Y',
    expected_min_records     INT           NOT NULL,
    load_type                VARCHAR(20)   NOT NULL DEFAULT 'full',
    created_at                DATETIME2     NOT NULL DEFAULT SYSUTCDATETIME()
);
GO

INSERT INTO dbo.ingestion_metadata
    (dataset_name, asset_type, exchange_code, source_url, bronze_container, bronze_target_path, is_active, expected_min_records, load_type)
VALUES
    ('equities_BER', 'equity', 'BER', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/equities/BER.csv', 'bronze', 'equities/BER', 'Y', 6990, 'full'),
    ('equities_BSE', 'equity', 'BSE', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/equities/BSE.csv', 'bronze', 'equities/BSE', 'Y', 3470, 'full'),
    ('equities_FRA', 'equity', 'FRA', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/equities/FRA.csv', 'bronze', 'equities/FRA', 'Y', 10431, 'full'),
    ('equities_GER', 'equity', 'GER', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/equities/GER.csv', 'bronze', 'equities/GER', 'Y', 1070, 'full'),
    ('equities_JPX', 'equity', 'JPX', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/equities/JPX.csv', 'bronze', 'equities/JPX', 'Y', 2754, 'full'),
    ('equities_LSE', 'equity', 'LSE', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/equities/LSE.csv', 'bronze', 'equities/LSE', 'Y', 3052, 'full'),
    ('equities_NSE', 'equity', 'NSE', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/equities/NSE.csv', 'bronze', 'equities/NSE', 'Y', 1737, 'full'),
    ('equities_SHZ', 'equity', 'SHZ', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/equities/SHZ.csv', 'bronze', 'equities/SHZ', 'Y', 2024, 'full'),
    ('equities_VIE', 'equity', 'VIE', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/equities/VIE.csv', 'bronze', 'equities/VIE', 'Y', 1219, 'full'),
    ('equities_NYQ', 'equity', 'NYQ', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/equities/NYQ.csv', 'bronze', 'equities/NYQ', 'Y', 3749, 'full'),
    ('etfs_BER', 'etf', 'BER', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/etfs/BER.csv', 'bronze', 'etfs/BER', 'Y', 5064, 'full'),
    ('etfs_FRA', 'etf', 'FRA', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/etfs/FRA.csv', 'bronze', 'etfs/FRA', 'Y', 4264, 'full'),
    ('etfs_GER', 'etf', 'GER', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/etfs/GER.csv', 'bronze', 'etfs/GER', 'Y', 2244, 'full'),
    ('etfs_JPX', 'etf', 'JPX', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/etfs/JPX.csv', 'bronze', 'etfs/JPX', 'Y', 72, 'full'),
    ('etfs_LSE', 'etf', 'LSE', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/etfs/LSE.csv', 'bronze', 'etfs/LSE', 'Y', 2457, 'full'),
    ('etfs_VIE', 'etf', 'VIE', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/etfs/VIE.csv', 'bronze', 'etfs/VIE', 'Y', 104, 'full'),
    ('etfs_NYQ', 'etf', 'NYQ', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/etfs/NYQ.csv', 'bronze', 'etfs/NYQ', 'Y', 17, 'full'),
    ('funds_BER', 'fund', 'BER', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/funds/BER.csv', 'bronze', 'funds/BER', 'Y', 27, 'full'),
    ('funds_BSE', 'fund', 'BSE', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/funds/BSE.csv', 'bronze', 'funds/BSE', 'Y', 445, 'full'),
    ('funds_FRA', 'fund', 'FRA', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/funds/FRA.csv', 'bronze', 'funds/FRA', 'Y', 5480, 'full'),
    ('funds_JPX', 'fund', 'JPX', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/funds/JPX.csv', 'bronze', 'funds/JPX', 'Y', 16, 'full'),
    ('funds_LSE', 'fund', 'LSE', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/funds/LSE.csv', 'bronze', 'funds/LSE', 'Y', 1587, 'full'),
    ('funds_SHZ', 'fund', 'SHZ', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/funds/SHZ.csv', 'bronze', 'funds/SHZ', 'Y', 9, 'full'),
    ('funds_VIE', 'fund', 'VIE', 'https://raw.githubusercontent.com/JerBouma/FinanceDatabase/main/database/funds/VIE.csv', 'bronze', 'funds/VIE', 'Y', 3031, 'full');
GO


SELECT asset_type, COUNT(*) AS file_count FROM dbo.ingestion_metadata GROUP BY asset_type;