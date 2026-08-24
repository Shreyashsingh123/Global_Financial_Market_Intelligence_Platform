dbutils.widgets.text("storage_account", "", "ADLS Gen2 storage account name")
dbutils.widgets.text("snapshot_date", "", "Snapshot date to process (YYYY-MM-DD). Blank = latest available per exchange")
dbutils.widgets.text("taxonomy_version", "v1", "Taxonomy version tag to stamp on this run")

STORAGE_ACCOUNT = dbutils.widgets.get("storage_account")
SNAPSHOT_DATE = dbutils.widgets.get("snapshot_date") or None
TAXONOMY_VERSION = dbutils.widgets.get("taxonomy_version")

assert STORAGE_ACCOUNT, "storage_account widget must be set — pass it from the job/pipeline, don't hard-code it here."


def _container(container_name: str) -> str:
    return f"abfss://{container_name}@{STORAGE_ACCOUNT}.dfs.core.windows.net"

BRONZE = _container("bronze")
SILVER = _container("silver")
GOLD = _container("gold")
QUARANTINE = _container("quarantine")

ASSET_CLASSES = ["equities", "etfs", "funds"]

EXCHANGE_ASSET_COVERAGE = {
    "BER": ["equities", "etfs", "funds"],
    "BSE": ["equities", "funds"],
    "FRA": ["equities", "etfs", "funds"],
    "GER": ["equities", "etfs"],
    "JPX": ["equities", "etfs", "funds"],
    "LSE": ["equities", "etfs", "funds"],
    "NSE": ["equities"],
    "SHZ": ["equities", "funds"],
    "VIE": ["equities", "etfs", "funds"],
    "NYQ": ["equities", "etfs"],
}

def bronze_path(asset_class: str, exchange_code: str) -> str:
    """
    Points at the exchange folder, not a specific snapshot_date, so Spark can glob
    across all historical snapshots when needed (e.g. dim tables) or a caller can
    filter down to SNAPSHOT_DATE for incremental runs.
    """
    assert asset_class in ASSET_CLASSES, f"{asset_class} not in confirmed bronze scope {ASSET_CLASSES}"
    assert exchange_code in EXCHANGE_ASSET_COVERAGE, f"{exchange_code} not in confirmed 10-exchange scope"
    return f"{BRONZE}/{asset_class}/{exchange_code}"

def silver_path(table_name: str) -> str:
    return f"{SILVER}/{table_name}"

def gold_path(table_name: str) -> str:
    return f"{GOLD}/{table_name}"

def quarantine_path(sub: str) -> str:
    assert sub in ("invalid_records", "unmapped_classifications")
    return f"{QUARANTINE}/{sub}"

print(f"Config loaded. STORAGE_ACCOUNT={STORAGE_ACCOUNT} SNAPSHOT_DATE={SNAPSHOT_DATE or 'latest per exchange'} TAXONOMY_VERSION={TAXONOMY_VERSION}")