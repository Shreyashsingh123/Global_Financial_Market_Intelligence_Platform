# Data Quality Rules

## Completeness (measured, not auto-failed)
Checked on `financial_instrument`: symbol, instrument_name, asset_type, country, currency.
Thresholds calibrated against real profiled null rates (source profiling), not assumed
clean data: equities show ~5.4% null country, ~7.2% null sector — these are expected source
characteristics, not failures. Only `country`/`currency` being **non-null but not matching the
reference dimension** counts as a validity failure (see below); a null value alone does not.

## Validity (routes to `quarantine/invalid_records`)
| Rule | failure_reason |
|---|---|
| symbol / instrument_name / asset_type is NULL | `CORE_FIELD_MISSING` |
| exchange not in `dim_exchange` | `INVALID_EXCHANGE` |
| country is non-null and not in `dim_country` | `INVALID_COUNTRY` |
| currency is non-null and not in `dim_currency` | `INVALID_CURRENCY` |
| duplicate symbol+exchange (beyond first occurrence) | `DUPLICATE_RECORD` |

## Taxonomy quality (per instrument, per classifiable field)
| Flag | Meaning | Quarantined? |
|---|---|---|
| `UNMAPPED_CLASSIFICATION` | Source value has no entry at all in `taxonomy_mapping` | Yes |
| `INVALID_THEME` | Mapping exists but its theme string isn't one of the 9 canonical themes (defensive check) | Yes |
| `UNKNOWN_CATEGORY` | Mapping exists, explicitly reviewed, `normalized_theme` is NULL (asset-class/style value, not a sector) | No — informational |
| `LOW_CONFIDENCE_MAPPING` | Mapping exists with a real theme but confidence_score < 0.75 | No — informational, flagged in `gold_data_quality` |

Only `UNMAPPED_CLASSIFICATION` and `INVALID_THEME` are quarantined — the other two are known,
reviewed states that would otherwise flood quarantine with expected, non-actionable data (e.g.
quarantining every `Growth`/`Large Cap` fund would be wrong; that's not a data quality failure,
it's just not a sector).

## `gold_data_quality` — one row per dataset per pipeline run (append-only)
Builds a quality-over-time history, directly answering "how has data quality changed between
runs" (a named business question in the original spec). `quality_score` =
valid_records / total_records × 100. `pipeline_status` reflects whether the run itself
completed, independent of the data quality score.

## Known, accepted, non-blocking states (reviewed — not defects)
- **375 equities flagged `CORE_FIELD_MISSING`** (out of 40,549) — genuine gaps in source data,
  correctly caught and quarantined by design. Not investigated further; the quarantine layer is
  working as intended by isolating them rather than either silently dropping or silently
  passing them through.

- **176 of 187 discovered currency codes lack a curated display name** in `dim_currency`
  (flagged `needs_review=true`) — cosmetic only. These currencies are still valid, complete
  entries and pass validation checks correctly; only the human-readable `currency_name` is
  unfilled for the long tail beyond the 11 major currencies initially curated.
  
- **95 of ~95+ discovered headquarters countries in `dim_country`** — the original 10
  exchange-host countries are fully enriched (iso2/iso3/region); the remainder are flagged
  `needs_review` for the same reason (present and valid, missing enrichment fields).