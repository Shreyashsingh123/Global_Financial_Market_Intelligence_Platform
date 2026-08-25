# Pipeline Design — Transformation Layer

## Notebook execution order and dependencies

```
04_reference_standardization  (no dependencies — build first)
        │
        ▼
03_schema_standardization     (depends on dim_exchange from 04)
        │
        ▼
05_taxonomy_mapping           (independent of 03/04, but conceptually follows —
                                depends on nothing at runtime, config-driven)
        │
        ▼
06_data_quality                (depends on 03's financial_instrument + extension
                                 tables, 04's dim_* tables, 05's taxonomy_mapping)
        │
        ▼
07_gold_processing             (depends on everything above)

01_source_profiling and 02_bronze_ingestion have no dependency on 03/04/05/06/07 —
run independently, any time, to (re-)verify bronze state.
```

## Parameters (Databricks widgets, no hard-coded values)
Every notebook takes: `storage_account`, `snapshot_date` (blank = latest per exchange),
`taxonomy_version`. `06`/`07` additionally read config from `04`'s output; `02` additionally
takes `sql_server`, `sql_database`, `secret_scope`, `tenant_id` for the Entra ID SQL audit.

## Key architectural choices

**Config-driven, not hard-coded:** `databricks/utilities/config.py` centralizes all paths,
the exchange/asset-class coverage map, and the `latest_snapshot_path()` helper — every
notebook reads exactly one snapshot folder per exchange deterministically (never globs across
multiple `snapshot_date=` folders in one read, which previously caused a real bug: an old
corrupted snapshot got mixed into the same schema-inference call as a corrected one).

**MERGE upserts throughout Silver/Gold**, not overwrite — `financial_instrument`, the
extension tables, `dim_currency`, `taxonomy_mapping`, and `gold_cross_asset_theme` all use
Delta MERGE keyed on a stable identifier (`instrument_id`, `currency_code`, or the mapping's
composite key), so re-running with new data updates in place rather than duplicating.
Reference tables that are meant to be fully replaced each run (`dim_exchange`, `dim_country`)
use `overwrite` instead, since they're small, curated, and fully reproducible from source.

**Time travel:** demonstrated on `gold/cross_asset_theme` in the Gold processing step —
`DESCRIBE HISTORY` shows version 0 (WRITE) → version 1 (MERGE), and
`option("versionAsOf", 0)` recovers the original version's data directly, confirming Delta's
version recovery works on Gold as required.

## Authentication
- **Storage (ADLS Gen2):** Databricks Access Connector, system-assigned Managed Identity,
  `Storage Blob Data Contributor` RBAC role — see `business_rules.md`.
- **Azure SQL (control table audit):** Entra ID Service Principal via
  `authentication=ActiveDirectoryServicePrincipal`, credentials in Key Vault, accessed through
  a Databricks secret scope.

## Known limitation of this environment
Compute is **serverless-only** (no classic all-purpose cluster option was available in this
workspace) — all cost-control for this project relies on minimizing session time and batching
work into single, complete runs per notebook rather than iterative cell-by-cell debugging
cycles, since serverless bills continuously on session activity rather than per-cluster-hour.