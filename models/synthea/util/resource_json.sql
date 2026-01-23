{{ config(
    materialized='incremental',
    unique_key='resource_md5',
    incremental_strategy='delete+insert'
) }}

WITH src AS (
    SELECT
        '<BUNDLE_001>' AS bundle_id,   -- static for now, can be dynamic later
        raw:entry[f.index]:resource AS resource_json,
        raw:entry[f.index]:resource:resourceType::string AS resource_type,
        md5(raw:entry[f.index]:resource::string) AS resource_md5,
        current_timestamp() AS load_ts,
        'synthea' AS record_source,
        raw:entry[f.index]:resource:id::string AS patient_uuid,
        raw:entry[f.index]:resource:encounter.reference::string AS encounter_ref_uuid,
        raw:entry[f.index]:resource:patient.reference::string AS patient_ref_uuid
    FROM {{ source('raw_data', 'MASTER_JSON') }},
         LATERAL FLATTEN(input => raw:entry) f
    {% if is_incremental() %}
        WHERE md5(raw:entry[f.index]:resource::string) NOT IN (SELECT resource_md5 FROM {{ this }})
    {% endif %}
)

SELECT *
FROM src
