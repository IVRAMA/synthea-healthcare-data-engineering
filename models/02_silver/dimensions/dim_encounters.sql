with silver_data as (

    select
        encounter_id,
        patient_id,
        "ENCOUNTERCLASS",
        "REASONCODE",
        "REASONDESCRIPTION"
    from {{ ref('csv_silver__encounters') }}

    union all

    select
        "ID" as encounter_id,
        "PATIENT" as patient_id,
        "ENCOUNTERCLASS",
        "REASONCODE",
        "REASONDESCRIPTION"
    from {{ ref('sfk_silver__encounters') }}

    union all

    select
        "ID" as encounter_id,
        "PATIENT" as patient_id,
        "ENCOUNTERCLASS",
        "REASONCODE",
        "REASONDESCRIPTION"
    from {{ ref('dbt_silver__encounters') }}
),

deduped as (
    select distinct
        encounter_id,
        patient_id,
        "ENCOUNTERCLASS",
        "REASONCODE",
        "REASONDESCRIPTION"
    from silver_data
)

select *
from deduped
