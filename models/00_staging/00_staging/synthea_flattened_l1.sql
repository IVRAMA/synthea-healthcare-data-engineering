{{ config (
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='patient_id',
    database='HDB',
    schema='BRONZE', 
    alias='SYNTHEA_FLATTENED_L1'
) }}


WITH COL_DATA_FOR_AGG AS  
    (SELECT  
      raw:entry[0].fullUrl::string AS patient_id,
      batch_no,
      LOAD_TS,
      f.value:resource:resourceType AS fkey,
      f.value:resource AS fval,
      g.key AS column_name,
      typeof(g.value) AS data_type_L1
    FROM   {{ source('synthea', 'master_json') }}
    , LATERAL FLATTEN(INPUT => raw:entry) F
    , LATERAL FLATTEN(INPUT => FVAL) G)
  
  -- 2. ARRAY_AGG for L1 clinical JSON
  , ARRAY_AGG_FLATTENED_JSON AS
    (SELECT 
      PATIENT_ID, FKEY,max(LOAD_TS) as LOAD_TS,
      CAST(ARRAY_AGG(FVAL) AS VARIANT) AS FVAL 
    FROM COL_DATA_FOR_AGG  
    GROUP BY 1,2) 

, COL_META_JSON AS
    (SELECT PATIENT_ID, max(batch_no) as batch_no,
      ARRAY_AGG(OBJECT_CONSTRUCT(
        'TABLE', FKEY, 'COLUMN', COLUMN_NAME, 'DATATYPE', DATA_TYPE_L1
      ))::VARIANT AS COL_VAL
    FROM (
      SELECT DISTINCT PATIENT_ID, FKEY, COLUMN_NAME, DATA_TYPE_L1,batch_no
      FROM COL_DATA_FOR_AGG
    ) D
    GROUP BY PATIENT_ID)
    
  -- 4. L1 MERGE SOURCE (your temp approach - perfect for MERGE)
SELECT
      A.PATIENT_ID,
        MAX(C.batch_no)  as batch_no,
      max(A.LOAD_TS) AS LOAD_TS,
      ARRAY_AGG(A.FKEY) AS PAT_TABLES,
      MAX(C.COL_VAL) AS COL_META,
      OBJECT_AGG(A.FKEY, A.FVAL) AS CLINICAL_JSON
  FROM ARRAY_AGG_FLATTENED_JSON A
  JOIN COL_META_JSON C
    ON A.PATIENT_ID = C.PATIENT_ID
{% if is_incremental() %}
  WHERE LOAD_TS > (SELECT MAX(load_ts) FROM {{ this }})
{% endif %}
  GROUP BY A.PATIENT_ID

