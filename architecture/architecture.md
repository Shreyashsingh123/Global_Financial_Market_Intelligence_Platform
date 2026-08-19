# Global Financial Market Intelligence Hub — Architecture

## 1. Purpose
This document describes the end-to-end architecture of the Global Financial Market Intelligence Hub: an Azure-based data engineering platform that ingests heterogeneous financial datasets (equities, ETFs, funds, indices, currencies, crypto, money markets) from the [FinanceDatabase](https://github.com/jerbouma/FinanceDatabase) repository, standardizes them into a common instrument model, maps source classifications to an organization-defined Common Financial Taxonomy, and serves the result through Azure SQL and Power BI.

## 2. Architecture Principles
- **Source fidelity is never lost.** Original classifications are always stored alongside normalized ones.
- **Medallion architecture.** Bronze (raw/immutable) → Silver (standardized/conformed) → Gold (business-ready).
- **Metadata-driven, not hard-coded.** Ingestion and taxonomy mapping are both config-driven tables, not notebook logic.
- **Everything is versioned.** Snapshots in Bronze, taxonomy versions in Silver, Delta history in Gold.
- **Nothing is silently dropped.** Failed/unmapped records go to quarantine, not `/dev/null`.
- **No hard-coded secrets.** Key Vault + Managed Identity throughout.

## 3. High-Level Data Flow

```
FinanceDatabase (GitHub source)
        │
        ▼
Azure Data Factory  ── metadata-driven ingestion, retries, logging
        │
        ▼
ADLS Gen2 — Bronze   ── raw snapshots, partitioned by snapshot_date
        │
        ▼
Azure Databricks (PySpark)
        │
        ├── Schema Standardization ─────► silver_financial_instrument
        ├── Reference Data Standardization ─► dim_country / dim_exchange / dim_currency
        └── Common Financial Taxonomy Mapping ─► taxonomy_mapping (confidence + version)
        │
        ▼
Delta Lake — Silver  ── conformed, quality-scored, quarantine side-path
        │
        ▼
Delta Lake — Gold    ── financial_catalog, market_summary, theme_universe, cross_asset_theme, data_quality
        │
   ┌────┴────┐
   ▼         ▼
Azure SQL   Delta Gold (direct query / Databricks SQL)
   │         │
   └────┬────┘
        ▼
   Power BI — Global Financial Market Intelligence Hub
   (Overview / Theme Intelligence / Cross-Asset Explorer / Geographic Intelligence / Data Product Health)
```

## 4. Layer Responsibilities

| Layer | Technology | Responsibility |
|---|---|---|
| Orchestration | Azure Data Factory | Metadata-driven ingestion, scheduling, retry/failure handling, pipeline audit logging |
| Raw storage | ADLS Gen2 — Bronze | Immutable source snapshots, one folder per `snapshot_date`, never overwritten |
| Processing | Azure Databricks (PySpark) | Schema standardization, reference-data conformance, taxonomy mapping, data quality checks |
| Conformed storage | Delta Lake — Silver | Common instrument model + asset-specific extension tables, quarantine routing |
| Curated storage | Delta Lake — Gold | Business-ready aggregates and the Financial Instrument Catalog |
| Relational serving | Azure SQL | Star-schema dimensional model for BI consumption |
| Analytics | Power BI | 5-page Market Intelligence Hub |
| Security (cross-cutting) | Key Vault, Managed Identity, RBAC | Secret management, identity-based access, no hard-coded credentials |

## 5. Medallion Layout (ADLS Gen2)

```
adls-gen2/
├── bronze/{equities,etfs,funds,indices,currencies,cryptocurrencies,money_markets}/snapshot_date=YYYY-MM-DD/
├── silver/{instruments,exchanges,countries,currencies,classifications,taxonomy}/
├── gold/{financial_catalog,market_summary,theme_universe,cross_asset_theme,data_quality}/
└── quarantine/{invalid_records,unmapped_classifications}/
```

## 6. Common Financial Taxonomy (summary)
Source classifications (Sector/Industry for equities, Family/Category for ETFs & funds, Exchange/Market for indices) are mapped via a config-driven `taxonomy_mapping` table into a fixed set of normalized themes (Technology, Healthcare, Energy, Financial Services, Industrials, Consumer, Real Estate, Utilities, Materials). Each mapping carries a `confidence_score`, `mapping_method`, and `taxonomy_version`, enabling both cross-asset analysis and full traceability back to the original label. See `docs/taxonomy.md` for full methodology.

## 7. Security Model
- All storage/database credentials retrieved from **Azure Key Vault** at runtime.
- ADF linked services and Databricks clusters authenticate via **Managed Identity**.
- Access to Bronze/Silver/Gold zones controlled by **Azure RBAC** at the container/folder level.
- No `password=`, `storage_key=`, or connection strings appear in notebooks, pipeline JSON, or config files.

## 8. Lineage
Every value shown in Power BI can be traced:
`Power BI dashboard value → Gold dataset row → Silver instrument row → taxonomy_mapping row → source_classification field → Bronze snapshot record → original FinanceDatabase source file`

## 9. Diagram
See `architecture.png` (exported from `architecture.svg`) in this folder for the visual diagram.
