--------------------------------------------------------------------------------------------------------------------
 -- 04) CREATE STORED PROCEDURES THAT WILL INSERT DATA FROM MASTER JSON TO THE DOWNSTREAM TABLES AND ALSO TO CLINICAL TABLES BASED ON BATCH
--------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE MASTER_TO_L1_MERGE(p_batch_no STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  -- 1. TEMP FLATTENED_JSON FROM MASTER_JSON STREAM (batch data only)
  CREATE OR REPLACE TEMP TABLE COL_DATA_FOR_AGG AS  
    SELECT  
      raw:entry[0].fullUrl::string AS patient_id,
      batch_no,
      f.value:resource:resourceType AS fkey,
      f.value:resource AS fval,
      g.key AS column_name,
      typeof(g.value) AS data_type_L1
    FROM STAGING.MASTER_JSON
    , LATERAL FLATTEN(INPUT => raw:entry) F
    , LATERAL FLATTEN(INPUT => FVAL) G
    WHERE batch_no =  :p_batch_no ; -- Get data for only the param batch defined
  
  -- 2. ARRAY_AGG for L1 clinical JSON

   
  CREATE OR REPLACE TEMP TABLE ARRAY_AGG_FLATTENED_JSON AS
    SELECT 
      PATIENT_ID, FKEY,
      CAST(ARRAY_AGG(FVAL) AS VARIANT) AS FVAL 
    FROM COL_DATA_FOR_AGG  
    GROUP BY 1,2; 


  -- 3. COL_META for L1 schema metadata
  CREATE OR REPLACE TEMP TABLE COL_META_JSON AS
    SELECT PATIENT_ID, max(batch_no) as batch_no,
      ARRAY_AGG(OBJECT_CONSTRUCT(
        'TABLE', FKEY, 'COLUMN', COLUMN_NAME, 'DATATYPE', DATA_TYPE_L1
      ))::VARIANT AS COL_VAL
    FROM (
      SELECT DISTINCT PATIENT_ID, FKEY, COLUMN_NAME, DATA_TYPE_L1,batch_no
      FROM COL_DATA_FOR_AGG WHERE batch_no =  :p_batch_no 
    ) D
    GROUP BY PATIENT_ID;
    
  -- 4. L1 MERGE SOURCE (your temp approach - perfect for MERGE)
CREATE OR REPLACE TEMP TABLE TEMP_SYNTHEA_FLATTENED_L1 AS
 SELECT
      A.PATIENT_ID,
      :p_batch_no  as batch_no,
      CURRENT_TIMESTAMP AS LOAD_TS,
      ARRAY_AGG(A.FKEY) AS PAT_TABLES,
      MAX(C.COL_VAL) AS COL_META,
      OBJECT_AGG(A.FKEY, A.FVAL) AS CLINICAL_JSON
  FROM ARRAY_AGG_FLATTENED_JSON A
  JOIN COL_META_JSON C
    ON A.PATIENT_ID = C.PATIENT_ID
  WHERE C.batch_no =  :p_batch_no 
  GROUP BY A.PATIENT_ID;

    INSERT INTO STAGING.SYNTHEA_FLATTENED_L1 (PATIENT_ID, LOAD_TS, PAT_TABLES, COL_META, CLINICAL_JSON,batch_no)
    SELECT source.PATIENT_ID, source.LOAD_TS, source.PAT_TABLES, source.COL_META, source.CLINICAL_JSON,:p_batch_no  FROM TEMP_SYNTHEA_FLATTENED_L1 source;

END;
$$;

CREATE OR REPLACE PROCEDURE L1_TO_L2_MERGE (p_batch_no STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN

CREATE OR REPLACE TEMP TABLE TEMP_SYNTHEA_FLATTENED_L2 AS
SELECT
    TABLE_NAME       AS TABLE_NAME,
    COLUMN_NAME      AS COLUMN_NAME,
    COL_DATA_TYPE    AS COLUMN_DATA_TYPE,
    batch_no
FROM (
    SELECT
        F.VALUE:COLUMN::STRING   AS COLUMN_NAME,
        F.VALUE:TABLE::STRING    AS TABLE_NAME,
        F.VALUE:DATATYPE::STRING AS COL_DATA_TYPE,
        :p_batch_no as batch_no
    FROM STAGING.SYNTHEA_FLATTENED_L1,
         LATERAL FLATTEN (INPUT => COL_META) F
    WHERE batch_no =  :p_batch_no 
    GROUP BY 1,2,3,4
    ORDER BY 1,2,3,4
) S;

MERGE INTO STAGING.SYNTHEA_FLATTENED_L2 AS target
  USING TEMP_SYNTHEA_FLATTENED_L2 AS source
  ON target.TABLE_NAME = source.TABLE_NAME AND target.COLUMN_NAME = source.COLUMN_NAME AND target.batch_no  = source.batch_no
  WHEN MATCHED THEN
    UPDATE SET 
      TABLE_NAME = source.TABLE_NAME,
      COLUMN_NAME = source.COLUMN_NAME,
      COLUMN_DATA_TYPE = source.COLUMN_DATA_TYPE, 
      batch_no     = source.batch_no
  WHEN NOT MATCHED THEN
    INSERT (TABLE_NAME,COLUMN_NAME,COLUMN_DATA_TYPE,batch_no)
    VALUES (source.TABLE_NAME,source.COLUMN_NAME,source.COLUMN_DATA_TYPE,source.batch_no);
END;
$$;

CREATE OR REPLACE PROCEDURE SP_PIPELINE_AUDIT(p_batch_no STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  res STRING DEFAULT 'Audit completed successfully';
BEGIN
  CREATE OR REPLACE TEMP TABLE TEMP_PIPELINE_AUDIT AS
 SELECT ROW_NUMBER() OVER (ORDER BY t.LAST_DDL DESC) AS seq_num,
       :p_batch_no AS batch_no,  -- Fixed!
       t.table_schema AS schema_name, 
       'TABLE' AS object_type,
       t.table_name AS object_name, 
       t.row_count::NUMBER(38,0) AS tot_row_count,  -- Cast!
       0::NUMBER(38,0) AS batch_row_count,
       CURRENT_TIMESTAMP() AS min_load_ts,
       CURRENT_TIMESTAMP() AS max_load_ts,
       0::NUMBER(38,0) AS latency_seconds,
       CURRENT_WAREHOUSE() AS warehouse_name,
       'X-Small' AS warehouse_size,
       CURRENT_TIMESTAMP() AS audit_ts
FROM information_schema.tables t
  WHERE t.table_schema IN ('BRONZE','STAGING') 
   AND TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME <> 'PIPELINE_AUDIT'
  ORDER BY t.LAST_DDL DESC;

  LET table_rs RESULTSET := (
    SELECT seq_num, schema_name, object_name
    FROM TEMP_PIPELINE_AUDIT
  );
  LET table_cursor CURSOR FOR table_rs;

  FOR rec IN table_cursor DO
    -- Copy rec to vars (fixes rec.field error)
    LET v_seq_num NUMBER := rec.seq_num;
    LET v_schema STRING := rec.schema_name;
    LET v_table STRING := rec.object_name;
    LET v_full_table STRING := '"' || v_schema || '"."' || v_table || '"';
    
    LET v_batch_count NUMBER := (
      SELECT COALESCE(COUNT(*), 0) 
      FROM IDENTIFIER(:v_full_table) 
      WHERE batch_no = :p_batch_no
    );
    LET v_min_ts TIMESTAMP := (
      SELECT COALESCE(MIN("LOAD_TS"), CURRENT_TIMESTAMP()) 
      FROM IDENTIFIER(:v_full_table) 
      WHERE batch_no = :p_batch_no
    );
    LET v_max_ts TIMESTAMP := (
      SELECT COALESCE(MAX("LOAD_TS"), CURRENT_TIMESTAMP()) 
      FROM IDENTIFIER(:v_full_table) 
      WHERE batch_no = :p_batch_no
    );
    
    -- Single UPDATE using vars only
    UPDATE TEMP_PIPELINE_AUDIT 
    SET batch_row_count = :v_batch_count,
        min_load_ts = :v_min_ts,
        max_load_ts = :v_max_ts,
        latency_seconds = DATEDIFF('second', :v_min_ts, :v_max_ts)
    WHERE seq_num = :v_seq_num;
  END FOR;

  INSERT INTO PIPELINE_AUDIT 
  SELECT * FROM TEMP_PIPELINE_AUDIT;
  
  RETURN res;
END;
$$;
