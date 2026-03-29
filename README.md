
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
graph TD
    subgraph SOURCES["SOURCES"]
        CSV[Synthea CSV<br/>17 Clinical Tables]
        JSON_SF[Snowflake JSON<br/>Master JSON]
        DBT_JSON[dbt JSON<br/>Direct src]
        PYTHON[Python Script<br/>100k Patients Direct]
    end

    subgraph STAGING["STAGING"]
        CSV_STG[staging.csv_stages<br/>External + COPY]
        JSON_RAW[staging.master_json]
        L1[staging.L1_json<br/>Explode arrays]
        L2[staging.L2_json<br/>Normalize]
    end

    subgraph BRONZE["BRONZE - Clinical Raw<br/>17 Tables Each"]
        CSV_B[bronze.csv_clinical_*]
        JSON_B[bronze.sf_json_clinical_*]
        DBT_B[bronze.dbt_json_clinical_*]
        PY_B[bronze.python_clinical_*]
    end

    subgraph SILVER_VIEWS["SILVER Views<br/>Source-Specific stg_*"]
        CSV_STG_V[stg_csv_patients<br/>VIEW from csv bronze]
        JSON_STG_V[stg_sf_patients<br/>VIEW from sf_json bronze]
        DBT_STG_V[stg_dbt_patients<br/>VIEW from dbt bronze]
        PY_STG_V[stg_python_patients<br/>VIEW from python bronze]
    end

    subgraph SILVER["SILVER Tables<br/>Unified Modeling"]
        MODEL[dim_patient, fact_encounter<br/>TABLES<br/>UNION stg_* + SCD]
    end

    subgraph GOLD["GOLD"]
        SUMMARY[encounter_summary<br/>Denormalized marts]
    end

    %% Flows
    CSV --> CSV_STG --> CSV_B --> CSV_STG_V
    JSON_SF --> JSON_RAW --> L1 --> L2 --> JSON_B --> JSON_STG_V
    DBT_JSON --> DBT_B --> DBT_STG_V
    PYTHON --> PY_B --> PY_STG_V
    
    CSV_STG_V -.-> MODEL
    JSON_STG_V -.-> MODEL
    DBT_STG_V -.-> MODEL
    PY_STG_V -.-> MODEL
    
    MODEL --> SUMMARY

    classDef source fill:#ffeaa7
    classDef staging fill:#fdcb6e
    classDef bronze fill:#00b894
    classDef silver_view fill:#74b9ff
    classDef silver fill:#0984e3
    classDef gold fill:#e17055

    class CSV,JSON_SF,DBT_JSON,PYTHON source
    class CSV_STG,JSON_RAW,L1,L2 staging
    class CSV_B,JSON_B,DBT_B,PY_B bronze
    class CSV_STG_V,JSON_STG_V,DBT_STG_V,PY_STG_V silver_view
    class MODEL silver
    class SUMMARY gold
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
