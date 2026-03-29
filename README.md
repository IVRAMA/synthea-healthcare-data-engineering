
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
    subgraph SOURCES["Sources"]
        CSV_SRC["CSV<br/>17 Clinical Tables<br/>staging.csv_stages"]
        SFK_SRC["SFK/SDK<br/>master_json<br/>L1_json L2_json"]
        DBT_SRC["DBT Sources<br/>JSON processing"]
    end
    
    subgraph BRONZE["Bronze Layer"]
        CSV_BRONZE["HCB.CLINICAL_DATA_BRONZE.<br/>BRONZE_ALLERGIES<br/>etc."]
        SFK_BRONZE["HJB.CLINICAL_DATA_BRONZE.<br/>SFK_BRONZE__ALLERGYINTOLERANCE<br/>etc."]
        DBT_BRONZE["HDB.CLINICAL_DATA_BRONZE.<br/>DBT_BRONZE_ALLERGYINTOLERANCE<br/>etc."]
    end
    
    subgraph SILVER["Silver Views<br/>(Transformation Layer)"]
        CSV_SILVER["HCB.CLINICAL_DATA_SILVER.<br/>CSV_SILVER_CONDITIONS<br/>etc."]
        SFK_SILVER["HJB.CLINICAL_DATA_SILVER.<br/>SFK_SILVER__ENCOUNTERS<br/>etc."]
        DBT_SILVER["HDB.CLINICAL_DATA_SILVER.<br/>DBT_SILVER__ENCOUNTERS<br/>etc."]
    end
    
    subgraph MODELS["Healthcare Analytics<br/>NEW - Dimensions & Models"]
        UNION["Union All Sources<br/>dim_patient, etc."]
    end
    
    subgraph GOLD["Gold Layer"]
        ENCOUNTER_SUMMARY["encounter_summary"]
    end
    
    CSV_SRC -.->|Snowflake COPY| CSV_BRONZE
    SFK_SRC -.->|Snowflake Stages| SFK_BRONZE
    DBT_SRC -.->|dbt sources| DBT_BRONZE
    
    CSV_BRONZE -.->|Views| CSV_SILVER
    SFK_BRONZE -.->|Views| SFK_SILVER
    DBT_BRONZE -.->|Views| DBT_SILVER
    
    CSV_SILVER -.->|Union| UNION
    SFK_SILVER -.->|Union| UNION
    DBT_SILVER -.->|Union| UNION
    
    UNION --> ENCOUNTER_SUMMARY
    
    classDef yellow fill:#ffeb3b,stroke:#333,stroke-width:3px,color:#000
    classDef green fill:#c8e6c9,stroke:#333,stroke-width:3px,color:#000
    classDef orange fill:#ffcc80,stroke:#333,stroke-width:3px,color:#000
    classDef purple fill:#e1bee7,stroke:#333,stroke-width:3px,color:#000
    classDef blue fill:#bbdefb,stroke:#333,stroke-width:3px,color:#000
    
    class CSV_SRC,SFK_SRC,DBT_SRC yellow
    class CSV_BRONZE,SFK_BRONZE,DBT_BRONZE green
    class CSV_SILVER,SFK_SILVER,DBT_SILVER orange
    class UNION purple
    class ENCOUNTER_SUMMARY blue
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
