# Data Dictionary — Global Financial Market Intelligence Hub

Scope: equities, ETFs, funds only (indices/currencies/crypto/money markets not yet
ingested — see `business_rules.md`).

## Silver Layer

### `silver/financial_instrument`
Common model across all asset classes.

| Column | Type | Notes |
|---|---|---|
| instrument_id | string | sha256(asset_type, symbol, exchange) — stable across snapshots |
| symbol | string | |
| instrument_name | string | |
| asset_type | string | `equity` / `etf` / `fund` |
| country | string | Direct from source for equities (HQ country); derived from `dim_exchange` for ETF/Fund |
| currency | string | |
| exchange | string | One of the 10 confirmed exchange codes |
| market | string | Populated for equities only; NULL for ETF/Fund (no reliable source — see business_rules.md) |
| source_dataset | string | `equities` / `etfs` / `funds` (literal bronze folder name — distinct from `asset_type`) |
| source_record_id | string | symbol\|exchange\|snapshot_date |
| snapshot_date | string | Which bronze snapshot this row came from |

### `silver/equity_extension`
instrument_id, sector, industry_group, industry, market_cap

### `silver/etf_extension`
instrument_id, family, category_group, category

### `silver/fund_extension`
instrument_id, family, category_group, category

### `silver/dim_exchange`
exchange_code, exchange_name, country_name, iso2, iso3, region, market_type, exchange_key, taxonomy_version, is_current
— hand-curated, exactly 10 rows (the confirmed exchange scope).

### `silver/dim_country`
country_key, country_name, iso2, iso3, region, sub_region, economic_region, needs_review
— seeded from the 10 exchange countries (fully enriched) plus every distinct equity headquarters
country actually found in bronze (iso2/iso3/region NULL + `needs_review=true` for these until
manually enriched). ~95 rows.

### `silver/dim_currency`
currency_key, currency_code, currency_name, currency_region, currency_type, needs_review
— discovered from all distinct currency codes in bronze (~187). Only ~11 major currencies have
a curated name; the rest are flagged `needs_review` but are still valid, usable rows for
validation purposes.

### `silver/taxonomy_mapping`
mapping_id, asset_type, source_field, source_value, normalized_theme, mapping_method,
confidence_score, taxonomy_version, effective_from, effective_to, is_active
— SCD Type 2 versioned. 160 rows. See `taxonomy.md` for methodology.

### `silver/instrument_theme_assignment`
instrument_id, asset_type, source_field_used, source_classification, normalized_theme,
confidence_score, mapping_method, taxonomy_version
— per-instrument theme, resolved via field-priority logic (see `taxonomy.md`).

## Gold Layer

### `gold/financial_instrument_catalog`
instrument_id, symbol, name, asset_type, country, region, exchange, currency,
normalized_theme, mapping_confidence, record_status (`ACTIVE`/`REMOVED_FROM_SOURCE`),
is_delisted

### `gold/market_universe_summary`
country, exchange, asset_type, instrument_count

### `gold/theme_universe`
normalized_theme, asset_type, country, exchange, instrument_count

### `gold/cross_asset_theme`
normalized_theme, equity_count, etf_count, fund_count, asset_class_breadth, country_count,
exchange_count, total_instruments, theme_coverage_score

### `gold/data_quality`
run_id, dataset, total_records, valid_records, invalid_records, unmapped_records,
low_confidence_records, duplicate_records, quality_score, pipeline_status, run_timestamp
— append-only, one row per dataset per pipeline run; builds a quality-over-time history.

## Quarantine

### `quarantine/invalid_records`
source_dataset, source_record (JSON), failure_reason (`CORE_FIELD_MISSING` /
`INVALID_EXCHANGE` / `INVALID_COUNTRY` / `INVALID_CURRENCY` / `DUPLICATE_RECORD`),
failed_column, pipeline_run_id, snapshot_date, quarantine_timestamp

### `quarantine/unmapped_classifications`
source_dataset, source_record (JSON), failure_reason (`UNMAPPED_CLASSIFICATION` /
`INVALID_THEME`), failed_column, pipeline_run_id, snapshot_date, quarantine_timestamp