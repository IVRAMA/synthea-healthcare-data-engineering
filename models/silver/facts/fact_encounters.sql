{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='ID',
    database='HEALTHCARE_ANALYTICS_NEW',
    schema='SILVER', 
    alias='fact_encounters'
) }}

with csv_source as (
    select 
        "ID",
        "START",
        "STOP",
        "PATIENT",
        "ORGANIZATION",
        "PROVIDER",
        "PAYER",
        "ENCOUNTERCLASS",
        "CODE",
        "DESCRIPTION",
        "BASE_ENCOUNTER_COST",
        "TOTAL_CLAIM_COST",
        "PAYER_COVERAGE",
        "REASONCODE",
        "REASONDESCRIPTION",
        "LOAD_TS",
        'CSV' as source_stream
    from {{ ref('csv_bronze__encounters') }}
    {% if is_incremental() %}
    where "LOAD_TS" > (select max("LOAD_TS") from {{ this }})
    {% endif %}
),

json_source as (
    select  
        "ID",
        "START",
        "STOP",
        "PATIENT",
        "ORGANIZATION",
        "PROVIDER",
        "PAYER",
        "ENCOUNTERCLASS",
        "CODE",
        "DESCRIPTION",
        "BASE_ENCOUNTER_COST",
        "TOTAL_CLAIM_COST",
        "PAYER_COVERAGE",
        "REASONCODE",
        "REASONDESCRIPTION",
        "LOAD_TS",
        'JSON' as source_stream
    from {{ ref('json_bronze__encounters') }}-- Using the updated uppercase table name
    {% if is_incremental() %}
    where "LOAD_TS" > (select max("LOAD_TS") from {{ this }})
    {% endif %}
),


unified_streams as (
    select * from csv_source
    union all
    select * from json_source
),

deduplicated_and_coalesced as (
    select 
        "ID",
        -- Use max_by or window-based tracking to retain the latest tracking records
        max_by("START", "LOAD_TS") as "START",
        max_by("STOP", "LOAD_TS") as "STOP",
        max_by("PATIENT", "LOAD_TS") as "PATIENT",
        max_by("ORGANIZATION", "LOAD_TS") as "ORGANIZATION",
        
        -- The Fallback/Coalesce Core: Pull max non-null value across the matching IDs
        max("PROVIDER") as "PROVIDER",
        max("PAYER") as "PAYER",
        max("BASE_ENCOUNTER_COST") as "BASE_ENCOUNTER_COST",
        max("TOTAL_CLAIM_COST") as "TOTAL_CLAIM_COST",
        max("PAYER_COVERAGE") as "PAYER_COVERAGE",
        
        max_by("ENCOUNTERCLASS", "LOAD_TS") as "ENCOUNTERCLASS",
        max_by("CODE", "LOAD_TS") as "CODE",
        max_by("DESCRIPTION", "LOAD_TS") as "DESCRIPTION",
        max_by("REASONCODE", "LOAD_TS") as "REASONCODE",
        max_by("REASONDESCRIPTION", "LOAD_TS") as "REASONDESCRIPTION",
        max("LOAD_TS") as "LOAD_TS"
    from unified_streams
    group by "ID"
)

select * from deduplicated_and_coalesced
