{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='ID',
    database='HEALTHCARE_ANALYTICS_NEW',
    schema='SILVER', 
    alias='fact_encounters'
) }}

{{ deduplicate_silver_entity(
    sources=[
        'csv_bronze__encounters',
        'json_bronze__encounters',
        'dbt_bronze__encounters' 
    ],
    unique_key='ID',
    columns=[
        'START','STOP','PATIENT','ORGANIZATION','PROVIDER','PAYER','ENCOUNTERCLASS',
        'CODE','DESCRIPTION','BASE_ENCOUNTER_COST','TOTAL_CLAIM_COST','PAYER_COVERAGE',
        'REASONCODE','REASONDESCRIPTION'
    ]
) }}