"""Load all raw Olist CSVs into DuckDB under the `raw` schema."""
from pathlib import Path
import duckdb

PROJECT_ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = PROJECT_ROOT / "data" / "raw"
DB_PATH = PROJECT_ROOT / "data" / "olist.duckdb"

# filename -> clean table name (explicit map beats fragile string-stripping)
TABLES: dict[str, str] = {
    "olist_customers_dataset.csv": "customers",
    "olist_geolocation_dataset.csv": "geolocation",
    "olist_orders_dataset.csv": "orders",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "order_payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "product_category_name_translation.csv": "product_category_translation",
}


def load_table(con: duckdb.DuckDBPyConnection, csv_name: str, table: str) -> int:
    """Load one CSV into raw.<table> and return the row count.

    Args:
        con: open DuckDB connection.
        csv_name: filename inside data/raw.
        table: destination table name in the `raw` schema.

    Returns:
        Number of rows loaded.
    """
    csv_path = RAW_DIR / csv_name
    con.execute(f"""
        CREATE OR REPLACE TABLE raw.{table} AS
        SELECT * FROM read_csv_auto('{csv_path.as_posix()}');
    """)
    return con.execute(f"SELECT COUNT(*) FROM raw.{table}").fetchone()[0]


def main() -> None:
    con = duckdb.connect(str(DB_PATH))
    con.execute("CREATE SCHEMA IF NOT EXISTS raw;")
    for csv_name, table in TABLES.items():
        n = load_table(con, csv_name, table)
        print(f"raw.{table:<28} {n:>10,} rows")
    con.close()


if __name__ == "__main__":
    main()