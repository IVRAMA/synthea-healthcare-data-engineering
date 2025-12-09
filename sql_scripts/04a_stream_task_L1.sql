
CREATE OR REPLACE STREAM synthea_raw.util.master_json_str
  ON TABLE synthea_raw.raw_data.master_json;

SELECT * FROM synthea_raw.util.master_json_str;


CREATE OR REPLACE  TASK synthea_raw.util.task_synthea_flattened_L1
  WAREHOUSE = TRANSFORMING
  SCHEDULE = 'USING CRON */5 * * * * Asia/Kolkata' -- example: hourly
  WHEN SYSTEM$STREAM_HAS_DATA('synthea_raw.util.master_json_str')
AS
BEGIN
 
  -- 1. Temp flattened_json from stream
  CREATE OR REPLACE TEMP TABLE synthea_raw.util.flattened_json AS
  SELECT  
      raw:entry[0].fullUrl::string        AS patient_id,
      f.value:resource:resourceType       AS fkey,
      f.value:resource                    AS fval,
      g.key                                AS column_name,
      TYPEOF(g.value)                      AS data_type_L1
  FROM synthea_raw.util.master_json_str  -- STREAM
       , LATERAL FLATTEN(input => raw:entry) AS f
       , LATERAL FLATTEN(input => fval)      AS g;

  -- 2. Temp array_agg_flattened_json
  CREATE OR REPLACE TEMP TABLE synthea_raw.util.array_agg_flattened_json AS
  SELECT
      patient_id,
      fkey,
      ARRAY_AGG(fval)::VARIANT AS fval
  FROM synthea_raw.util.flattened_json
  GROUP BY
      patient_id,
      fkey;

  -- 3. Temp col_meta_json
  CREATE OR REPLACE TEMP TABLE synthea_raw.util.col_meta_json AS
  SELECT
      patient_id,
      ARRAY_AGG(
        OBJECT_CONSTRUCT(
          'table',    fkey,
          'column',   column_name,
          'datatype', data_type_L1
        )
      )::VARIANT AS col_val
  FROM synthea_raw.util.flattened_json
  GROUP BY
      patient_id;

  -- 4. Insert incremental rows into L1 table
  INSERT INTO synthea_raw.util.synthea_flattened_L1 (
      patient_id,
      load_ts,
      pat_tables,
      col_meta,
      clinical_json
  )
  SELECT
      a.patient_id,
      CURRENT_TIMESTAMP                         AS load_ts,
      ARRAY_AGG(a.fkey)                         AS pat_tables,
      MAX(c.col_val)                            AS col_meta,
      OBJECT_AGG(a.fkey, a.fval)                AS clinical_json
  FROM synthea_raw.util.array_agg_flattened_json a
  JOIN synthea_raw.util.col_meta_json      c
    ON a.patient_id = c.patient_id
  GROUP BY
      a.patient_id;

END;
