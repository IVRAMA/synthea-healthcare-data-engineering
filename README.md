
# Healthcare dbt Analytics Pipeline
## Synthea Synthetic Patient Data - Complete Project Documentation


---

**Author**: Ivrama  
**Database**: healthcare_raw (source) → healthcare_analytics (target)  
**Tech Stack**: dbt, Snowflake, Synthea, Python  
**Date**: February 2026  
**Purpose**: DBT Pipeline for FHIR JSON Data

![Lineage DAG](images/lineage_full.png)

---

## Table of Contents

1. Project Overview
2. Mermaid Architecture & Data Flow
3. Detailed Layer Implementation ← NEW (above tree)
4.  4 Pipeline Strategies
5. Data Sources
6. Quick Start Guide
7. STAR Story (Interview Ready)
8. Sample Queries
9. Lineage & Documentation

---

## 1. Project Overview

This dbt project demonstrates end-to-end healthcare analytics pipelines, evolving from simple CSV ingestion to advanced Synthea JSON processing. Built to showcase senior data engineering skills: hybrid medallion and staging‑TFM architecture, incremental loads, schema evolution, hybrid orchestration (Snowflake SPs + pure dbt), and complete lineage traceability.

**Key Metrics**:
- 53+ dbt models compiled successfully
- 17 FHIR silver tables (patients, encounters, conditions, medications, observations, procedures, etc.)
- 10,000 synthetic patients across 6 batches
- 3 distinct pipeline paradigms in one repository

**Privacy-Safe**: Uses Synthea synthetic data (no PHI/PII) - perfect for GitHub portfolios and interviews.

---
**Lineage**: [View DAG](images/lineage.png) – JSON batches → gold summaries across all pipelines.

## 2. Architecture & Data Flow
### Hybrid Medallion and Staging Transformation Architecture

``` mermaid
flowchart TD
    subgraph SOURCES["SOURCES"]
        CSV_SRC["Synthea CSV<br/>17 Clinical Tables"]
        SFK_SRC["Snowflake JSON<br/>Master JSON"]
        DBT_SRC["dbt JSON<br/>Direct src"]
        PY_SRC["Python Script<br/>100k Patients Direct"]
    end

    subgraph STAGING["STAGING"]
        CSV_STAGE["staging.csv_stages<br/>External + COPY"]
        SFK_L1["L1_synthea"]
        SFK_L2["L2_synthea"]
        DBT_L1["L1_synthea"]
        DBT_L2["L2_synthea"]
    end

    subgraph BRONZE["BRONZE - Clinical Raw"]
        CSV_BRONZE["bronze.csv_clinical_*"]
        SFK_BRONZE["bronze.sf_json_clinical_*"]
        DBT_BRONZE["bronze.dbt_json_clinical_*"]
        PY_BRONZE["bronze.python_clinical_*"]
    end

    subgraph SILVER_VIEWS["SILVER Views"]
        CSV_SILVER["stg_csv_patients<br/>VIEW from csv bronze"]
        SFK_SILVER["stg_sf_patients<br/>VIEW from sf_json bronze"]
        DBT_SILVER["stg_dbt_patients<br/>VIEW from dbt bronze"]
        PY_SILVER["stg_python_patients<br/>VIEW from python bronze"]
    end

    subgraph SILVER_TABLES["SILVER Tables"]
        MODELS["dim_patient,<br/>fact_encounter<br/>TABLES<br/>UNION stg_* + SCD"]
    end

    subgraph GOLD["GOLD"]
        ENCOUNTER["encounter_summary<br/>Denormalized marts"]
    end

    CSV_SRC --> CSV_STAGE --> CSV_BRONZE --> CSV_SILVER
    SFK_SRC --> SFK_L1 --> SFK_L2 --> SFK_BRONZE --> SFK_SILVER
    DBT_SRC --> DBT_L1 --> DBT_L2 --> DBT_BRONZE --> DBT_SILVER
    PY_SRC --> PY_BRONZE --> PY_SILVER

    CSV_SILVER -.-> MODELS
    SFK_SILVER -.-> MODELS
    DBT_SILVER -.-> MODELS
    PY_SILVER -.-> MODELS
    MODELS --> ENCOUNTER

    classDef source fill:#fff7cc,stroke:#c9b458,stroke-width:1.5px,color:#000
    classDef stage fill:#ffd89a,stroke:#c98b2f,stroke-width:1.5px,color:#000
    classDef bronze fill:#19b5a5,stroke:#0d6f66,stroke-width:1.5px,color:#fff
    classDef silver fill:#7fb5ff,stroke:#3367b7,stroke-width:1.5px,color:#000
    classDef model fill:#0d84d8,stroke:#075b94,stroke-width:1.5px,color:#fff
    classDef gold fill:#e7896d,stroke:#b45a43,stroke-width:1.5px,color:#000
    classDef sourceYellow fill:#fff7cc,stroke:#c9b458,stroke-width:1.5px,color:#000
    classDef sourcePlain fill:#f5f5f5,stroke:#999,stroke-width:1.5px,color:#000
    
    class SFK_SRC,DBT_SRC sourceYellow
    class CSV_SRC sourcePlain
    class CSV_SRC,SFK_SRC,DBT_SRC,PY_SRC source
    class CSV_STAGE,SFK_L1,SFK_L2,DBT_L1,DBT_L2 stage
    class CSV_BRONZE,SFK_BRONZE,DBT_BRONZE,PY_BRONZE bronze
    class CSV_SILVER,SFK_SILVER,DBT_SILVER,PY_SILVER silver
    class MODELS model
    class ENCOUNTER gold
```

## 3.  Detailed Layer Implementation
```
STAGING (JSON Raw Ingestion)
├─ healthcare_json_raw.master_json (JSON batches via external stages)
├─ healthcare_sfk_raw.Synthea_Flattened_L1: Flattened variant columns (patient-level JSON)
├─ healthcare_sfk_raw.Synthea_Flattened_L2: Metadata extraction (table_name, column_name, data_type)
├─ healthcare_dbt_raw.Synthea_Flattened_L1: Flattened variant columns (patient-level JSON)
└─ healthcare_dbt_raw.Synthea_Flattened_L2: Metadata extraction (table_name, column_name, data_type)
↓
BRONZE (Raw Ingestion)
├─ healthcare_csv_raw.(patients, encounters, claims, allergies, etc.)
├─ healthcare_sfk_raw.(patients, encounters, claims, allergies, etc.)
├─ healthcare_dbt_raw.(patients, encounters, claims, allergies, etc.)
└─ healthcare_pyt_raw.(patients, encounters, claims, allergies, etc.)

↓
SILVER (Cleaned/Conformed/combined data)
├─ dim_patients
├─ dim_dates
├─ dim_medications
├─ dim_encounter
├─ fact_medications
└─ fact_procedures
↓
GOLD (Analytics Marts)
└─  encounter_summary
```
