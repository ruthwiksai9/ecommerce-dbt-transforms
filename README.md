# Ecommerce dbt Transforms

dbt transformation layer for the [ecommerce-etl-pipeline](https://github.com/ruthwiksai9/ecommerce-etl-pipeline) PostgreSQL warehouse. Transforms raw Olist e-commerce data through staging → intermediate → mart layers.

## Lineage

```
raw.orders ──────────────────────────────────────────┐
raw.order_items ──┬─► stg_order_items                │
raw.customers ────┼─► stg_customers ──► dim_customers ┤
raw.products  ────┼─► stg_products  ──► dim_products  ├─► fact_orders
raw.sellers   ────┼─► stg_sellers                     │
raw.order_payments┘─► stg_order_payments              │
raw.orders ───────►   stg_orders ──► int_orders_enriched ┘
                                           │
                  ┌────────────────────────┤
                  ▼                        ▼                  ▼
           revenue_daily        customer_cohorts    category_performance
```

## Models

| Layer | Model | Materialization | Description |
|-------|-------|----------------|-------------|
| Staging | `stg_orders` | View | Cleaned orders + time dims |
| Staging | `stg_order_items` | View | Items with freight ratio |
| Staging | `stg_customers` | View | Normalized city/state |
| Staging | `stg_products` | View | Products + volume_cm3 |
| Staging | `stg_sellers` | View | Sellers normalized |
| Staging | `stg_order_payments` | View | Payments + installment flag |
| Intermediate | `int_orders_enriched` | Ephemeral | Orders joined with items + payments |
| Core | `dim_customers` | Table | Customer dim + cohort + segment |
| Core | `dim_products` | Table | Product dim + demand tier |
| Core | `fact_orders` | Table | Order fact with surrogate keys |
| Analytics | `revenue_daily` | Table | Daily GMV, AOV, on-time rate |
| Analytics | `customer_cohorts` | Table | Cohort retention matrix |
| Analytics | `category_performance` | Table | Monthly category revenue share |

## Tests

**Schema tests** (via `schema.yml`): `unique`, `not_null`, `accepted_values`, `relationships`

**Singular tests** (custom SQL):
- `assert_positive_prices` — no negative prices in order items
- `assert_no_future_orders` — no orders with future timestamps
- `assert_delivery_after_order` — delivery date must be after order date

## Macros

| Macro | Description |
|-------|-------------|
| `safe_divide(num, den)` | Division returning 0 on zero denominator |
| `date_trunc_to_period(col, period)` | Shorthand for date_trunc cast to date |

## Quickstart

```bash
# Install dbt
pip install -r requirements.txt

# Configure connection (copy and edit)
cp profiles.yml.example ~/.dbt/profiles.yml

# Install packages (dbt_utils)
dbt deps

# Run all models
dbt run

# Run tests
dbt test

# Generate and serve docs
dbt docs generate
dbt docs serve  # opens http://localhost:8080
```

## CI

GitHub Actions runs on every push:
1. Spins up PostgreSQL with seed data
2. `dbt deps` → `dbt compile` → `dbt run` → `dbt test`
3. Generates and uploads dbt docs as artifact
