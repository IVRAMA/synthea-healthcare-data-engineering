{{
    config(
        materialized='incremental',
        database='HDB',
        schema='STAGING'
    )
}}

{{ unpack_fhir_staging('Location') }}
