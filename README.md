
# Healthcare dbt Analytics Pipeline
## Synthea Synthetic Patient Data - Complete Project Documentation


---

**Author**: Ivrama  
**Database**: healthcare_raw (source) → healthcare_analytics (target)  
**Tech Stack**: dbt, Snowflake, Synthea, Python  
**Date**: February 2026  
**Purpose**: Senior Data Engineer Portfolio (Warner Bros Prep)

![Lineage DAG](images/lineage.PNG)

---

## Table of Contents

1. Project Overview
2. Architecture & Data Flow
3. Three Pipeline Models
4. Stored Procedures (SP Pipeline)
5. Data Sources
6. Quick Start Guide
7. STAR Story (Interview Ready)
8. Sample Queries
9. Lineage & Documentation

---

## 1. Project Overview

This dbt project demonstrates end-to-end healthcare analytics pipelines, evolving from simple CSV ingestion to advanced Synthea JSON processing. Built to showcase senior data engineering skills: medallion architecture, incremental loads, schema evolution, hybrid orchestration (Snowflake SPs + pure dbt), and complete lineage traceability.

**Key Metrics**:
- 53+ dbt models compiled successfully
- 17 FHIR silver tables (patients, encounters, conditions, medications, observations, procedures, etc.)
- 10,000 synthetic patients across 6 batches
- 3 distinct pipeline paradigms in one repository

**Privacy-Safe**: Uses Synthea synthetic data (no PHI/PII) - perfect for GitHub portfolios and interviews.

---
**Lineage**: [View DAG](images/lineage.png) – JSON batches → gold summaries across all pipelines.

## 2. Architecture & Data Flow

### Medallion Architecture

```

BRONZE (Raw Ingestion)
├─ healthcare_raw.raw_data (CSV via COPY)
└─ healthcare_raw.bronze.master_json (JSON batches via external stages)
↓
SILVER (Cleaned/Conformed)
├─ L1: Flattened variant columns (patient-level JSON)
├─ L2: Metadata extraction (table_name, column_name, data_type)
└─ 17 FHIR clinical tables (patients, encounters, claims, allergies, etc.)
↓
GOLD (Analytics Marts)
├─ encounter_summary (CSV pipeline)
├─ j_encounter_summary (SP pipeline)
└─ d_encounter_summary (dbt pipeline)

```

### Database Schema

| Database | Schema | Purpose |
|----------|--------|---------|
| `healthcare_raw` | `raw_data` | CSV staging (encounter_summary source) |
| `healthcare_raw` | `bronze` | JSON master table (10K patients, 6 batches) |
| `healthcare_analytics` | `silver` | FHIR clinical tables (17 tables) |
| `healthcare_analytics` | `gold` | Marts (encounter summaries) |
| `healthcare_analytics` | `dbt_staging` | dbt staging models |
| `healthcare_analytics` | `dbt_marts` | dbt marts |

---

## 3. Three Pipeline Models

### Model 1: encounter_summary (CSV Pipeline)

**Source**: Kaggle Healthcare DB - https://www.kaggle.com/datasets/ramaiv/healthcare-db-dbt

**Pipeline**:
```

CSV files → External Stages → COPY INTO raw_data
↓
Staging (data type casting, nulls handling)
↓
Facts \& Dimensions (star schema modeling)
↓
encounter_summary (final mart)

```

**Characteristics**:
- Simplest pipeline - direct CSV ingestion
- Snowflake native COPY command
- Good for structured, pre-cleaned data
- Fast time-to-value

**Use Case**: When source data is already tabular and clean.

---

### Model 2: j_encounter_summary (SP-Orchestrated Pipeline)

**Source**: Synthea JSON - Harvard Dataverse  
https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/QDXLWR

**Pipeline Flow**:
```

JSON Batches (1-6) → External Stages
↓
COPY INTO master_json (bronze.master_json)
↓
SP: MASTER_TO_L1_MERGE
↓ (Flatten patient-level JSON → variant column)
L1 Table (flattened patient records)
↓
SP: L1_TO_L2_MERGE
↓ (Extract metadata: table_name, column_name, data_type by batch)
L2 Table (metadata catalog)
↓
SP: SP_APPLY_SCHEMA_CHANGES
↓ (Dynamic DDL: CREATE/ALTER silver tables)
Silver Schema Tables Created/Modified
↓
SP: SP_LOAD_SILVER_DATA
↓ (Flatten L1 JSON → INSERT to silver tables)
17 FHIR Tables Populated
↓
SP: SP_PIPELINE_AUDIT
↓ (Row counts by batch/table)
Audit Table Updated
↓
j_encounter_summary (final mart)

```

**Stored Procedures**:

| SP Name | Purpose | Input | Output |
|---------|---------|-------|--------|
| `MASTER_TO_L1_MERGE` | Flatten JSON to patient-level variant | `master_json` (bronze) | `L1` table (flattened records) |
| `L1_TO_L2_MERGE` | Extract schema metadata by batch | `L1` table | `L2` table (table_name, column_name, data_type) |
| `SP_APPLY_SCHEMA_CHANGES` | Dynamic DDL for schema evolution | `L2` metadata | Silver tables CREATE/ALTER |
| `SP_LOAD_SILVER_DATA` | Flatten and load clinical data | `L1` JSON | 17 FHIR silver tables |
| `SP_PIPELINE_AUDIT` | Audit trail with row counts | All silver tables | Audit table |

**Orchestration**: Snowflake Tasks (DAG)
```

TASK_MASTER_TO_L1 (cron scheduled)
↓ AFTER
TASK_L1_TO_L2
↓ AFTER
TASK_APPLY_SCHEMA
↓ AFTER
TASK_LOAD_SILVER
↓ AFTER
TASK_AUDIT

```

**Characteristics**:
- Hybrid approach: procedural + dbt marts
- Schema evolution handles varying Synthea structures
- Full audit trail
- Production-ready error handling
- Batch processing (1-6)

**Use Case**: Complex JSON with evolving schemas, need dynamic DDL, existing SP infrastructure.

---

### Model 3: d_encounter_summary (Pure dbt Pipeline)

**Source**: Same Synthea JSON (10K patients)

**Pipeline Flow**:
```

JSON → External Stages
↓
dbt sources (master_json)
↓
Staging Models (stg_patients, stg_encounters, etc.)
↓ (Flatten JSON with dbt macros, CTEs)
Intermediate Models (int_encounters_enriched)
↓ (Joins, aggregations, business logic)
Silver Tables (ref models, incremental)
↓
Gold Marts (d_encounter_summary)

```

**dbt Configuration**:
```yaml
models:
  healthcare_dbt:
    staging:
      +materialized: ephemeral  # CTEs for flattening
      +schema: dbt_staging
    intermediate:
      +materialized: incremental
      +on_schema_change: append_new_columns
      +unique_key: patient_id
      +schema: silver
    marts:
      +materialized: table
      +schema: dbt_marts
```

**Key dbt Features**:

- Incremental models with `on_schema_change='append_new_columns'`
- Ephemeral models for JSON flattening (no temp tables)
- Tests (uniqueness, not_null, relationships)
- Full lineage in dbt docs
- Version control (Git)

**Characteristics**:

- Fully declarative
- Version controlled
- Auto-lineage generation
- Modern data stack best practices
- No stored procedures

**Use Case**: Modern cloud DW, need Git workflow, prefer declarative over procedural.

---

## 4. Stored Procedures (SP Pipeline Details)

### MASTER_TO_L1_MERGE

**Purpose**: Flatten raw JSON batches to patient-level records.

**Logic**:

```sql
-- Pseudo-code
MERGE INTO L1 
USING (
  SELECT 
    patient_id,
    batch_number,
    PARSE_JSON(payload) AS patient_json,
    CURRENT_TIMESTAMP() AS load_ts
  FROM master_json
  WHERE batch_number = ?
)
ON L1.patient_id = source.patient_id
WHEN MATCHED THEN UPDATE
WHEN NOT MATCHED THEN INSERT
```

**Output**: L1 table with columns: patient_id, batch_number, patient_json (VARIANT), load_ts

---

### L1_TO_L2_MERGE

**Purpose**: Extract metadata (table names, column names, data types) from JSON structure.

**Logic**:

```sql
-- Derives schema from JSON keys
SELECT DISTINCT
  'patients' AS table_name,
  key AS column_name,
  TYPEOF(value) AS data_type,
  batch_number
FROM L1,
LATERAL FLATTEN(input => patient_json)
WHERE batch_number = ?
```

**Output**: L2 metadata table (table_name, column_name, data_type, batch_number)

---

### SP_APPLY_SCHEMA_CHANGES

**Purpose**: Dynamically CREATE or ALTER silver tables based on L2 metadata.

**Logic**:

```sql
-- For new tables
CREATE TABLE IF NOT EXISTS silver.patients (
  patient_id VARCHAR,
  first_name VARCHAR,
  ...
  load_ts TIMESTAMP
);

-- For new columns
ALTER TABLE silver.encounters 
ADD COLUMN new_field VARCHAR;
```

**Smart Diff**: Compares L2 metadata against INFORMATION_SCHEMA to determine new tables/columns.

---

### SP_LOAD_SILVER_DATA

**Purpose**: Flatten L1 JSON and INSERT into silver FHIR tables.

**Logic**:

```sql
-- For each clinical table
INSERT INTO silver.patients
SELECT 
  patient_json:id::VARCHAR AS patient_id,
  patient_json:name:given::VARCHAR AS first_name,
  patient_json:name:family::VARCHAR AS last_name,
  patient_json:birthDate::DATE AS birth_date,
  patient_json:gender::VARCHAR AS gender,
  CURRENT_TIMESTAMP() AS load_ts
FROM L1
WHERE batch_number = ?
  AND NOT EXISTS (SELECT 1 FROM silver.patients p WHERE p.patient_id = L1.patient_json:id::VARCHAR);
```

**17 FHIR Tables**:

1. patients
2. encounters
3. conditions
4. medications
5. observations
6. procedures
7. immunizations
8. allergies
9. careplans
10. claims
11. organizations
12. providers
13. payers
14. imaging_studies
15. devices
16. supplies
17. careplan_activities

---

### SP_PIPELINE_AUDIT

**Purpose**: Track row counts and execution status.

**Output Table**:

```sql
CREATE TABLE audit_table (
  batch_number INT,
  table_name VARCHAR,
  row_count INT,
  execution_ts TIMESTAMP
);
```

**Logic**: Query COUNT(*) for each silver table by batch, INSERT into audit.

---

## 5. Data Sources

### Source 1: Kaggle Healthcare DB (CSV)

**URL**: https://www.kaggle.com/datasets/ramaiv/healthcare-db-dbt

**Tables**:

- patients.csv
- encounters.csv
- conditions.csv
- medications.csv
- observations.csv

**Characteristics**:

- Pre-cleaned tabular data
- Direct column mappings
- ~10K rows total

---

### Source 2: Harvard Dataverse Synthea (JSON)

**URL**: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/QDXLWR

**Dataset**: 10,000 Synthetic Medicare Patient Records

**Format**: FHIR JSON (one file per patient)

**Batches**: Split into 6 batches for incremental processing

**Sample JSON Structure**:

```json
{
  "resourceType": "Bundle",
  "type": "collection",
  "entry": [
    {
      "resource": {
        "resourceType": "Patient",
        "id": "patient-123",
        "name": [{"family": "Doe", "given": ["John"]}],
        "birthDate": "1970-01-01",
        "gender": "male"
      }
    },
    {
      "resource": {
        "resourceType": "Encounter",
        "id": "encounter-456",
        "patient": {"reference": "Patient/patient-123"},
        "period": {"start": "2020-01-15", "end": "2020-01-15"}
      }
    }
  ]
}
```

**Key Relationships**:

- `patient_id` is the primary key across all tables
- `encounter_id` links conditions, medications, procedures to encounters
- Temporal relationships via `start_date`, `end_date`

---

## 6. Quick Start Guide

### Prerequisites

- Snowflake account (trial OK)
- dbt-core or dbt Cloud
- Python 3.8+
- Git


### Setup Steps

**1. Clone Repository**

```bash
git clone https://github.com/YOUR_USERNAME/healthcare-dbt-synthea
cd healthcare-dbt-synthea
```

**2. Configure dbt Profile**

```yaml
# ~/.dbt/profiles.yml
healthcare_dbt:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: xy12345.us-east-1
      user: health
      password: Synthea_health123
      role: healthcare_admin
      database: healthcare_analytics
      warehouse: wh_healthcare
      schema: silver
      threads: 4
```

**3. Snowflake Setup**

```sql
-- Create databases
CREATE DATABASE healthcare_raw;
CREATE DATABASE healthcare_analytics;

-- Create schemas
CREATE SCHEMA healthcare_raw.raw_data;
CREATE SCHEMA healthcare_raw.bronze;
CREATE SCHEMA healthcare_analytics.silver;
CREATE SCHEMA healthcare_analytics.gold;

-- Create warehouse
CREATE WAREHOUSE wh_healthcare 
  WAREHOUSE_SIZE = 'XSMALL' 
  AUTO_SUSPEND = 300 
  AUTO_RESUME = TRUE;

-- Create external stages (example)
CREATE STAGE healthcare_raw.bronze.synthea_stage
  URL = 's3://your-bucket/synthea/'
  FILE_FORMAT = (TYPE = JSON);
```

**4. Load Data**

```sql
-- CSV: COPY to raw_data
COPY INTO healthcare_raw.raw_data.patients
FROM @csv_stage/patients.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1);

-- JSON: COPY to master_json
COPY INTO healthcare_raw.bronze.master_json
FROM @synthea_stage/batch_1/
FILE_FORMAT = (TYPE = JSON);
```

**5. Run dbt**

```bash
# Verify connection
dbt debug

# Install dependencies
dbt deps

# Run all models
dbt run --full-refresh

# Run tests
dbt test

# Generate docs
dbt docs generate
dbt docs serve
```

**6. Execute SP Pipeline (j_encounter)**

```sql
-- Create tasks (one-time)
CREATE TASK task_master_to_l1
  WAREHOUSE = wh_healthcare
  SCHEDULE = 'USING CRON 0 2 * * * UTC'
AS
  CALL MASTER_TO_L1_MERGE();

-- Trigger manually
EXECUTE TASK task_master_to_l1;
```


---

## 7. STAR Story (Interview Ready)

### Situation

At Deliveroo's advertising domain, I encountered nested JSON datasets (4B+ rows) lacking structure for BI teams. Four verticals needed consistent, queryable tables for KPI dashboards. Similar challenge with healthcare data: Synthea's FHIR JSON bundles (10K patients) required transformation into analytics-ready star schema for clinical insights.

### Task

Design and implement a scalable ETL pipeline transforming raw Synthea JSON into a medallion architecture (bronze → silver → gold), supporting:

- Schema evolution (varying JSON structures across batches)
- Incremental loads
- Audit traceability
- Multiple consumption patterns (SP orchestration vs. pure dbt)


### Action

**Built 3-paradigm pipeline**:

1. **CSV Baseline** (encounter_summary): External stages → COPY → staging → facts/dims → mart. Established foundation.
2. **SP-Orchestrated Pipeline** (j_encounter_summary):
    - Created 5 stored procedures handling JSON flattening (L1), metadata extraction (L2), dynamic DDL (SP_APPLY_SCHEMA_CHANGES), data loading (17 FHIR tables), and auditing
    - Orchestrated via Snowflake tasks in DAG (cascading execution)
    - Enabled batch processing (6 batches) with schema evolution
    - Built audit table tracking row counts per batch/table
3. **Pure dbt Pipeline** (d_encounter_summary):
    - 53 dbt models (staging → intermediate → marts)
    - Incremental configs with `on_schema_change='append_new_columns'`
    - Ephemeral models for JSON flattening (no temp tables)
    - Full lineage via dbt docs generate
    - Version controlled in GitHub

**Key Technical Decisions**:

- Used VARIANT columns for flexible JSON parsing
- Implemented incremental patterns to avoid full refreshes
- Added 100+ tests (uniqueness, relationships, not_null)
- Exported lineage PNG for portfolio


### Result

- **53 models compiled successfully** end-to-end
- **17 FHIR silver tables** ready for analytics (patients, encounters, conditions, medications, etc.)
- **Complete lineage traceability** from JSON → gold marts
- **GitHub portfolio** showcasing hybrid (SP + dbt) and modern (pure dbt) approaches
- **Interview-ready** demonstration of senior DE skills: medallion architecture, schema evolution, orchestration, version control
- **Privacy-safe** synthetic data enabling public portfolio

**Impact**: Portfolio project positioned for Warner Bros healthcare DE interview—demonstrates scalability, modern data stack proficiency, and production-ready patterns.

---

## 8. Sample Queries

### Query Gold Marts

```sql
-- encounter_summary (CSV pipeline)
SELECT 
  patient_id,
  encounter_count,
  total_cost,
  avg_encounter_duration_days
FROM healthcare_analytics.gold.encounter_summary
LIMIT 10;

-- d_encounter_summary (dbt pipeline)
SELECT 
  patient_id,
  encounter_type,
  condition_category,
  medication_count,
  total_procedures
FROM healthcare_analytics.gold.d_encounter_summary
WHERE encounter_date >= '2020-01-01'
LIMIT 10;
```


### Query Silver Tables

```sql
-- Patients
SELECT * FROM healthcare_analytics.silver.patients LIMIT 10;

-- Encounters with patient demographics
SELECT 
  e.encounter_id,
  e.encounter_type,
  e.start_date,
  p.first_name,
  p.last_name,
  p.birth_date
FROM healthcare_analytics.silver.encounters e
JOIN healthcare_analytics.silver.patients p 
  ON e.patient_id = p.patient_id
LIMIT 10;

-- Conditions by frequency
SELECT 
  condition_code,
  condition_description,
  COUNT(*) AS patient_count
FROM healthcare_analytics.silver.conditions
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 20;
```


### Audit Queries

```sql
-- Pipeline execution audit
SELECT 
  batch_number,
  table_name,
  row_count,
  execution_ts
FROM healthcare_analytics.silver.audit_table
ORDER BY execution_ts DESC
LIMIT 50;

-- Batch completion status
SELECT 
  batch_number,
  COUNT(DISTINCT table_name) AS tables_loaded,
  SUM(row_count) AS total_rows,
  MAX(execution_ts) AS last_execution
FROM healthcare_analytics.silver.audit_table
GROUP BY 1
ORDER BY 1;
```


### Lineage Queries

```sql
-- dbt run results
SELECT 
  name,
  status,
  execution_time,
  rows_affected
FROM dbt_run_results
WHERE run_date = CURRENT_DATE()
ORDER BY execution_time DESC;
```


---

## 9. Lineage \& Documentation

### dbt Docs

**Generate and Serve**:

```bash
dbt docs generate
dbt docs serve
```

**Access**: http://localhost:8080

**Features**:

- Interactive DAG visualization
- Model dependencies (upstream/downstream)
- Column-level lineage
- Test results
- Model descriptions


### Export Lineage

**Browser Screenshot**:

1. Open dbt docs serve
2. Navigate to Lineage tab
3. Select all models
4. Browser screenshot → save as `images/lineage.png`

**GitHub Integration**:

```markdown

```


### Model Counts

| Layer | Model Count | Materialization |
| :-- | :-- | :-- |
| Staging | 12 | Ephemeral/View |
| Intermediate | 15 | Incremental |
| Silver | 17 | Table |
| Gold/Marts | 9 | Table |
| **Total** | **53** | Mixed |


---

## Appendix: Technical Specifications

### Snowflake Configuration

**Compute**:

- Warehouse: wh_healthcare (XSMALL)
- Auto-suspend: 300 seconds
- Auto-resume: TRUE

**Storage**:

- Databases: 2 (healthcare_raw, healthcare_analytics)
- Schemas: 6 (raw_data, bronze, silver, gold, dbt_staging, dbt_marts)
- Tables: 30+ (17 silver FHIR + staging + marts)

**Cost Optimization**:

- Small warehouse for dev (XSMALL)
- Incremental models reduce compute
- Auto-suspend minimizes idle costs


### dbt Configuration

**dbt_project.yml**:

```yaml
name: 'healthcare_dbt'
version: '1.0.0'
profile: 'healthcare_dbt'

models:
  healthcare_dbt:
    staging:
      +materialized: ephemeral
      +schema: dbt_staging
    intermediate:
      +materialized: incremental
      +on_schema_change: append_new_columns
      +unique_key: patient_id
      +schema: silver
    marts:
      +materialized: table
      +schema: dbt_marts
```

**packages.yml**:

```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1
```


### Performance Metrics

**dbt run --full-refresh**:

- Total models: 53
- Execution time: ~8 minutes
- Rows processed: 500K+

**SP Pipeline Execution**:

- Batch processing time: ~5 minutes per batch
- Total pipeline: ~30 minutes (6 batches)

---

## Conclusion

This project demonstrates mastery of:

- **Medallion Architecture**: Bronze → Silver → Gold
- **Hybrid Orchestration**: SP DAGs + dbt
- **Schema Evolution**: Dynamic DDL for varying JSON
- **Incremental Processing**: Efficient batch loads
- **Full Lineage**: dbt docs + audit tables
- **Version Control**: Git workflow
- **Healthcare Standards**: FHIR compliance

**Portfolio Value**: Showcases senior DE skills for healthcare/analytics roles (Warner Bros, Tide, etc.) with privacy-safe synthetic data enabling public GitHub demonstration.

---

**Repository**: https://github.com/YOUR_USERNAME/healthcare-dbt-synthea
**LinkedIn**: [Your Profile]
**Contact**: [Your Email]

---

*Generated: February 18, 2026*
*Tech: dbt + Snowflake + Synthea*

```
 🚀```

