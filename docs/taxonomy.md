# Taxonomy Methodology — Global Financial Market Intelligence Hub

## The 9 normalized themes
Technology, Healthcare, Energy, Financial Services, Industrials, Consumer, Real Estate,
Utilities, Materials.

## Source classification shapes (confirmed against real data, not assumed)
- **Equities:** `sector` (11 GICS-style values) → `industry_group` (25 more granular values)
- **ETFs & Funds (shared shape):** `family` → `category_group` (19-21 values) → `category`
  (25-63 values)

## Mapping methodology
Every distinct source value across both shapes was manually reviewed and mapped (method =
`RULE`) with an explicit confidence score, stored in `taxonomy_mapping`. Two deliberate design
decisions:

**1. Theme consolidation.** The organization's 9 themes are fewer than GICS's standard 11
sectors — most notably, there is no dedicated "Communication Services" theme. `Communication
Services`, `Media & Entertainment`, and `Telecommunication Services` are folded into
`Technology` at **medium confidence (0.7-0.75)**, a genuine judgment call rather than a clean
match. This is intentional and shows up correctly as "review required" under the confidence
thresholds below.

**2. Not every source value is a theme.** A large share of ETF/Fund `category`/`category_group`
values describe *asset class or investment style*, not sector (`Fixed Income`, `Cash`,
`Growth`, `Large Cap`, `Emerging Markets`, country names). These are included in
`taxonomy_mapping` with `normalized_theme = NULL` and a low confidence score — documented as
"reviewed, no theme applies," not silently missing. This is what lets the data quality checks
distinguish `UNKNOWN_CATEGORY` (reviewed, N/A) from `UNMAPPED_CLASSIFICATION` (never seen,
needs actual review).

## Confidence thresholds (per original spec)
- 0.90–1.00 → High Confidence
- 0.75–0.89 → Medium Confidence
- < 0.75 → Review Required

Of 160 active mappings: ~78 resolve to a real theme, ~82 are explicitly "no theme applies,"
~84 sit below the 0.75 review threshold (mostly by design — the asset-class/style values are
deliberately scored low since they aren't really "mappable").

## Per-instrument theme assignment — field priority
Both equities and ETF/Fund instruments have two classifiable fields. Rather than an arbitrary
rule, priority was set by checking which field actually yields better theme coverage in the
real data:
- **Equity:** `industry_group` preferred over `sector` — nearly every industry_group value maps
  to a real theme, and it's more precise.
- **ETF/Fund:** `category_group` preferred over `category` — category_group values are mostly
  real sector names with high hit-rate; `category` is mostly style/geography tags that rarely
  carry a theme.

Whichever field yields a non-null theme wins; falls back to the other field if the primary
gives nothing. Implemented in the Gold processing step → `instrument_theme_assignment`.

## Versioning
`taxonomy_mapping` is SCD Type 2: re-running under a new `taxonomy_version` expires the prior
active row for the same (asset_type, source_field, source_value) — setting `is_active=false`
and `effective_to`=today — before inserting the new version's row. Full history is preserved,
answerable via "which taxonomy version classified this instrument" queries against
`instrument_theme_assignment.taxonomy_version`.