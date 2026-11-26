{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='ID',
    database='HEALTHCARE_ANALYTICS_NEW',
    schema='SILVER',
    alias='dim_patients'
) }}

{{ deduplicate_silver_entity(
    sources=[
        'csv_bronze__patients',
        'json_bronze__patients',
        'dbt_bronze__patients'
    ],
    unique_key='ID',
    columns=[
        'BIRTHDATE', 'DEATHDATE', 'SSN', 'DRIVERS', 'PASSPORT',
        'PREFIX', 'FIRST', 'MIDDLE', 'LAST', 'SUFFIX', 'MAIDEN',
        'MARITAL', 'RACE', 'ETHNICITY', 'GENDER', 'BIRTHPLACE',
        'ADDRESS', 'CITY', 'STATE', 'COUNTY', 'FIPS', 'ZIP',
        'LAT', 'LON', 'HEALTHCARE_EXPENSES', 'HEALTHCARE_COVERAGE', 'INCOME'
    ]
) }}
