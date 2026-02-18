# Synthea FHIR → dbt Medallion Pipeline

![Lineage DAG](images/lineage.PNG)

End-to-end dbt project transforming [Synthea](https://synthetichealth.github.io/synthea/) synthetic FHIR/CSV patient data into a production-ready star schema data mart. Demonstrates senior data engineering skills: Snowpipe ingestion, layered transformations (53 models), incremental loads, tests, and full lineage traceability.[web:25]

## 🎯 Project Overview
- **Source**: Synthea-generated realistic patient records (patients, encounters, conditions, medications, observations—~15 CSV/JSON tables linked by `patient_id` UUID).[cite:11]
- **Architecture**: Medallion layers for healthcare compliance:
  | Layer | Prefix | Purpose | Models |
  |-------|--------|---------|--------|
  | Bronze (Raw) | `raw_` | Snowpipe JSON/CSV dumps | 5 |
  | L1 (Staging) | `stg_` | Flatten/parse (CTEs/ephemeral) | 12 |
  | L2 (Intermediate) | `int_` | Joins/aggs (incremental) | 15 |
  | Silver (Refined) | `silver_` | SCD Type 2, conformed dims (17 FHIR tables) | 17 |
  | Gold (Marts) | `mart_` | Star schema (e.g., `mart_encounter_summary`) | 4 |
- **Key Features**:
  - Full dbt lineage (screenshot above)—trace JSON → gold mart.
  - Incremental models + snapshots for CDC.
  - 100+ tests (uniqueness, relationships).
  - Healthcare-ready: Patient journeys via `encounter_id` hub.

## 🚀 Quick Start (Snowflake Trial)
1. Clone: `git clone https://github.com/YOUR_USERNAME/synthea-dbt`
2. Install: `pip install dbt-snowflake`
3. Profiles: Edit `~/.dbt/profiles.yml` with Snowflake creds.
4. Seeds: `dbt seed` (load Synthea CSVs).
5. Run: `dbt run --full-refresh` (53 models → gold).
6. Test/Docs: `dbt test && dbt docs generate && dbt docs serve`
7. Lineage: View in dbt Explorer (export PNG via browser).

## 📊 Star Schema (Gold Layer)
- **Fact**: `mart_encounter_summary` (encounters as grain; metrics: visit_count, cost).
- **Dims**: Patient, Provider, Condition, Medication (denormalized for analytics).
- Joins: `patient_id`, `encounter_id`, `start_date` (SCD2 history).[cite:11]

## 💼 Why This Project?
Built for senior DE interviews: Privacy-safe healthcare ETL, dbt mastery, Snowflake optimization. Live demo: [Snowflake queries](queries/) + [dbt Cloud](link-if-any).

## Acknowledgments
Inspired by [OHDSI dbt-synthea](https://github.com/OHDSI/dbt-synthea).[web:14][web:18]
