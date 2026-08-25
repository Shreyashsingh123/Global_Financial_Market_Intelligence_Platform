# Business Rules & Scope Decisions

## Scope
Only **equities, ETFs, funds** are ingested and transformed (indices, currencies,
cryptocurrencies, money markets were never ingested). This is a deliberate, already-made scope
decision, not an oversight — every downstream Gold product, the Theme Coverage Score formula,
and the `gold_cross_asset_theme` schema were designed around exactly 3 asset classes (not the
original spec's illustrative 5-7).

**Exchanges:** BER, BSE, FRA, GER, JPX, LSE, NSE, SHZ, VIE, NYQ — fixed set of 10, coverage is
uneven per asset class (NSE has equities only; see `data_dictionary.md` for `dim_exchange`).

## Key design decisions

**Duplicate detection key:** `symbol + exchange`, per asset class. Bronze rows carry no
row-level ingestion timestamp, so there is no reliable "keep the newest" tiebreak — duplicates
are dropped deterministically (first-seen) and the count is logged for `gold_data_quality`,
not silently discarded.

**`source_dataset` vs `asset_type`:** these are deliberately different fields.
`source_dataset` = the literal bronze folder name (`equities`/`etfs`/`funds`); `asset_type` =
the normalized singular form (`equity`/`etf`/`fund`) used in `instrument_id` hashing and
taxonomy joins.

**ETF/Fund `country`:** derived via join to `dim_exchange` (their bronze schema has no country
column, only exchange/mic). **ETF/Fund `market`:** deliberately left NULL, not derived — the
only "market" signal available for them is `dim_exchange.market_type`, which is the same
literal string `"Equity"` for every exchange and carries no real information. Leaving it NULL
preserves source fidelity rather than fabricating a value.

**`dim_country` scope:** initially built only from the 10 exchanges' host countries — this was
a bug, since equities' `country` field is the company's *headquarters* country, which is a much
larger, unrelated set (a US-listed company can be headquartered in Ireland, Bermuda, etc.).
Fixed to include every distinct headquarters country actually found in equities bronze
(~95 countries), with the original 10 fully enriched (iso2/iso3/region) and the rest flagged
`needs_review` but still valid for validation purposes.

**Multi-line CSV parsing:** bronze company `summary` fields contain descriptions with literal
line breaks inside quoted values. Spark's CSV reader does not handle this by default
(`multiLine=false`), which silently shifted columns for any row containing one. All reads use
`.option("multiLine", True).option("escape", "\"")`.

**Removed records:** detected via the `snapshot_date` already stored per Silver row — any row
whose snapshot_date isn't the latest for its asset_type is flagged `REMOVED_FROM_SOURCE`. On
the current single-snapshot dataset this correctly shows 0; it activates on the next bronze
refresh.

**Delisted flag:** equities bronze has a `delisted` column not carried into the Silver common
model (out of scope for the common model, asset-specific). Surfaced directly in
`gold_financial_instrument_catalog.is_delisted` via a lightweight, equities-only bronze read in
the Gold processing step.

**Theme Coverage Score formula (`gold_cross_asset_theme.theme_coverage_score`):** weighted
composite, bounded 0-100 — asset-class breadth 40% (max=3, this project's scope), country reach
30% (normalized against the actual max distinct country count in the catalog, not a fixed
assumption), exchange reach 20% (max=10, the fixed exchange scope), instrument scale 10%
(capped at 1000 instruments).

## Authentication (no hard-coded credentials)
- **ADLS Gen2 access:** Azure Databricks Access Connector + system-assigned Managed Identity,
  granted `Storage Blob Data Contributor` via Azure RBAC. No keys, no SAS tokens.
- **Azure SQL access (control table audit):** Entra ID Service Principal (app registration +
  client secret), authenticated via `authentication=ActiveDirectoryServicePrincipal` in the
  JDBC connection. Client ID/secret stored in Key Vault, accessed only via a Databricks
  Key Vault-backed secret scope (`dbutils.secrets.get`) — never typed into a notebook.