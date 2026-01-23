{{ config(
    materialized='incremental',
    unique_key='patient_id',  
    incremental_strategy='delete+insert',
    database='SYNTHEA_RAW',
    schema='BRONZE_RAW'
) }}


WITH COL_DATA_FOR_AGG AS(
    SELECT  
      raw:entry[0].fullUrl::string AS patient_id,
      batch_no,
      f.value:resource:resourceType AS fkey,
      f.value:resource AS fval,
      g.key AS column_name,
      typeof(g.value) AS data_type_L1
    FROM {{ source('raw_data', 'MASTER_JSON') }}
    , LATERAL FLATTEN(INPUT => raw:entry) F
    , LATERAL FLATTEN(INPUT => FVAL) G ), 
  
  -- 2. ARRAY_AGG for L1 clinical JSON
  ARRAY_AGG_FLATTENED_JSON AS (
    SELECT 
      PATIENT_ID, FKEY,
      CAST(ARRAY_AGG(FVAL) AS VARIANT) AS FVAL 
    FROM COL_DATA_FOR_AGG  
    GROUP BY 1,2), 

  -- 3. COL_META for L1 schema metadata
  COL_META_JSON AS(
    SELECT PATIENT_ID, max(batch_no) as batch_no,
      ARRAY_AGG(OBJECT_CONSTRUCT(
        'TABLE', FKEY, 'COLUMN', COLUMN_NAME, 'DATATYPE', DATA_TYPE_L1
      ))::VARIANT AS COL_VAL
    FROM (
      SELECT DISTINCT PATIENT_ID, FKEY, COLUMN_NAME, DATA_TYPE_L1,batch_no
      FROM COL_DATA_FOR_AGG
    ) D
    GROUP BY PATIENT_ID),
    
  -- 4. L1 MERGE SOURCE (your temp approach - perfect for MERGE)
  TEMP_SYNTHEA_FLATTENED_L1 AS (
  SELECT
      A.PATIENT_ID,
      'Batch-01' as batch_no,
      CURRENT_TIMESTAMP AS LOAD_TS,
      ARRAY_AGG(A.FKEY) AS PAT_TABLES,
      MAX(C.COL_VAL) AS COL_META,
      OBJECT_AGG(A.FKEY, A.FVAL) AS CLINICAL_JSON
  FROM ARRAY_AGG_FLATTENED_JSON A
  JOIN COL_META_JSON C
    ON A.PATIENT_ID = C.PATIENT_ID
  GROUP BY A.PATIENT_ID)

SELECT * FROM TEMP_SYNTHEA_FLATTENED_L1