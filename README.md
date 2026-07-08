# Customer Intelligence & Revenue Analytics Platform

An end-to-end analytics platform built on the [Olist Brazilian E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
(~100K orders across 9 relational tables). It turns raw transactional data into
business decisions: which customers are about to churn, what segments exist and
how to treat them, what revenue looks like next quarter, and which product
categories are dragging down margins.

**Stack:** Python 3.11 · DuckDB · dbt Core · scikit-learn · XGBoost · SHAP ·
MLflow · Prophet · Streamlit · Plotly

---

## Architecture

```
Raw CSVs ──► DuckDB (raw schema) ──► dbt (staging ► intermediate ► marts) ──► ML models ──► Streamlit dashboard
             load_raw.py             tested, documented SQL                    churn / segments / forecast
```

The data flows through clean layers. Raw is an untouched mirror of the source;
all cleaning, typing, and business logic live in dbt where they are tested and
documented; ML and the dashboard read only from the finished marts.

---

## Reproduce this project

### 1. Prerequisites
- Python 3.11+
- A [Kaggle account](https://www.kaggle.com/) (the dataset requires login to download)

### 2. Clone and set up the environment
```bash
git clone <your-repo-url>
cd olist

python -m venv .venv
# Windows (PowerShell):
.\.venv\Scripts\Activate.ps1
# macOS / Linux:
# source .venv/bin/activate

pip install -r requirements.txt
```

### 3. Download the data
The raw CSVs are **not** committed (they are large and reproducible from the
source). Download them yourself:

1. Go to the [Olist dataset on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).
2. Download and unzip all 9 CSV files into `data/raw/`.

Your `data/raw/` should contain:
```
olist_customers_dataset.csv          olist_order_reviews_dataset.csv
olist_geolocation_dataset.csv        olist_products_dataset.csv
olist_orders_dataset.csv             olist_sellers_dataset.csv
olist_order_items_dataset.csv        product_category_name_translation.csv
olist_order_payments_dataset.csv
```

### 4. Load the raw data into DuckDB
```bash
python scripts/load_raw.py
```
This creates `data/olist.duckdb` with all 9 tables in a `raw` schema. To confirm
your load matches the source, check the printed row counts against this table:

| Table | Rows |
|---|---|
| `raw.customers` | 99,441 |
| `raw.geolocation` | 1,000,163 |
| `raw.orders` | 99,441 |
| `raw.order_items` | 112,650 |
| `raw.order_payments` | 103,886 |
| `raw.order_reviews` | 99,224 |
| `raw.products` | 32,951 |
| `raw.sellers` | 3,095 |
| `raw.product_category_translation` | 71 |

### 5. Build the dbt transformation layer
> dbt commands must be run from inside the `dbt_project/` folder, which is where
> the connection profile (`profiles.yml`) lives.
```bash
cd dbt_project
dbt debug     # verify the DuckDB connection
dbt build     # run + test all models
```

---

## Project structure
```
olist/
├── data/
│   ├── raw/                # Source CSVs (gitignored — download from Kaggle)
│   └── olist.duckdb        # Analytical database (gitignored — built by load_raw.py)
├── scripts/
│   └── load_raw.py         # CSV → DuckDB raw-layer ingestion
├── dbt_project/            # dbt transformation layer (staging → intermediate → marts)
│   ├── models/
│   ├── profiles.yml        # DuckDB connection (no secrets — safe to commit)
│   └── dbt_project.yml
├── requirements.txt
└── README.md
```

---

## Build status
This project is being built in phases. Current progress:

- [x] Raw data ingestion into DuckDB (9 tables, row-count verified)
- [x] dbt project connected to DuckDB
- [x] dbt staging models (9, one per source — cleaned & typed)
- [x] dbt intermediate models (5 — fan-out tables aggregated to order grain, joins)
- [x] dbt mart models (`mart_orders`, `mart_customer_metrics`)
- [x] Data-quality tests (18 passing: unique, not_null, relationships, accepted_values, custom) + docs/lineage
- [x] Exploratory analysis notebook (`notebooks/01_eda.ipynb`)
- [x] 15 business questions answered in SQL (`notebooks/02_business_questions.ipynb`)
- [x] Cohort retention analysis + heatmap (`notebooks/03_cohort_retention.ipynb`)
- [x] Product & margin scorecard (`notebooks/04_product_margin.ipynb`)
- [ ] RFM segmentation (K-Means) — in progress
- [ ] Churn prediction (XGBoost + SHAP, tracked in MLflow)
- [ ] Revenue forecasting (Prophet)
- [ ] Cohort retention analysis
- [ ] Streamlit dashboard
