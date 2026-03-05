# Healthcare dbt Analytics Pipeline
## Synthea Synthetic Patient Data - Complete Project Documentation

---

**Author**: Ivrama  
**Database**: healthcare_raw (source) → healthcare_analytics (target)  
**Tech Stack**: dbt, Snowflake, Synthea, Python  
**Date**: March 2026  
**Purpose**: Senior Data Engineer Portfolio (Warner Bros Prep)

<br>

[![Lineage DAG](images/lineage.PNG)](images/lineage.PNG)

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture & Data Flow](#2-architecture--data-flow)
3. [Four Pipeline Models](#3-four-pipeline-models)
4. [CSV External Stages (✅ LIVE)](#4-csv-external-stages-✅-live)
5. [Data Sources](#5-data-sources)
6. [Quick Start Guide](#6-quick-start-guide)
7. [STAR Story (Interview Ready)](#7-star-story-interview-ready)
8. [dbt Models & Lineage](#8-dbt-models--lineage)

---

## 1. Project Overview

**Multi-Strategy Healthcare Analytics Pipeline** showcasing 4 enterprise ETL patterns.

<br>

**Key Metrics**:

- **34 dbt models** (bronze→silver→gold) compiled & tested
- **19 FHIR bronze tables** (allergies→supplies)  
- **48+ tests** passing (PKs, not_null, coverage)
- **8 production SQL scripts** for zero-downtime CSV pipeline

<br>

**Privacy-Safe**: Synthea synthetic data (no PHI/PII) - GitHub & interview ready.

<br>

**🎯 4 Pipeline Strategies**:

✅ CSV → External Stages → dbt (LIVE)

⏳ JSON → SPs/Tasks DAG → dbt

⏳ JSON src → dbt-native flattening

⏳ Python 100k → clinical tables → dbt

text

---

## 2. Architecture & Data Flow

### Medallion Architecture

RAW CSV/JSON → HEALTHCARERAW.bronze (19 tables)
↓
dbt healthcare_csv/bronze → silver/dims&facts → gold/summaries
↓ (future)
JSON SPs/Python → unified silver → star schema marts

text

**Source-Specific Bronze** | **Unified Silver/Gold**:

models/
├── healthcare_csv/bronze/ # stg_patients.sql (19)
├── silver/ # dim_patient (CSV+JSON)
└── gold/ # encounter_summary

text

---

## 3. Four Pipeline Models

| Pipeline | Strategy | Status | Bronze | dbt Role |
|----------|----------|--------|--------|----------|
| **CSV** | External stages + COPY | ✅ LIVE | 19 tables | Silver/Gold |
| **JSON SPs** | Tasks + Stored Procs DAG | ⏳ | Clinical | Facts/Dims |
| **dbt JSON** | Native flattening | ⏳ | Clinical | Full stack |
| **Python** | 100k patients flattened | ⏳ | Clinical | Marts |

---

## 4. CSV External Stages (✅ LIVE)

**8 SQL Scripts** in `sql_scripts/` → Production CSV pipeline:

<br>

**Step 1: Environment & Stages**
```bash
snowsql -f sql_scripts/01_setup_healthcare_env.sql
snowsql -f sql_scripts/02_External_stages.sql

Step 2: PUT CSVs (One-by-One)

bash
PUT file://C:/path/to/allergies.csv @healthcareraw.externalstages.stageallergies;
# Repeat for 19 files (careplans.csv → supplies.csv)

Step 3: Load & Transform

bash
snowsql -f sql_scripts/03_raw_table_definitions.sql
snowsql -f sql_scripts/05_copy_data_stage_to_table.sql
snowsql -f sql_scripts/06_get_table_data.sql      # JS preview  
snowsql -f sql_scripts/07_infer_data_type.sql     # Regex types
snowsql -f sql_scripts/08_create_temp_files.sql

✨ Innovations:

JavaScript preview proc (3 rows/column)

Regex inference (VARCHAR→NUMBER/DATE/BOOLEAN)

Resilient COPY ON_ERROR=CONTINUE

5. Data Sources
Primary: Synthea CSVs

Bronze Tables (19): allergies, careplans, claims, conditions, devices, encounters, immunizations, medications, patients, procedures, providers, supplies + 8 more

6. Quick Start Guide
bash
# Clone & Setup
git clone <repo>
snowsql -f sql_scripts/01_setup_healthcare_env.sql

# CSV Pipeline (~10 mins)
snowsql -f sql_scripts/02_External_stages.sql
# PUT 19 CSVs → stages
snowsql -f sql_scripts/03_raw_table_definitions.sql  # ... 08_*.sql

# dbt (~2 mins)  
dbt deps && dbt run --full-refresh && dbt test
dbt docs:serve
7. STAR Story (Interview Ready)
Situation: Scalable healthcare pipeline for Warner Bros
Task: 4 ETL strategies + medallion architecture
Action: CSV→stages→34 dbt models (production scripts)
Result: 19 tables → star schema → 48+ tests → clean lineage

8. dbt Models & Lineage
34 Models: Bronze (19), Silver dims/facts, Gold summaries
Tests: 48+ passing

bash
dbt test                    # ✅ All passing
dbt docs:serve              # Interactive lineage
Tests

