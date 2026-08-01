--------------------------------------------------------------------------------------------------------------------
 -- 04) CREATE STORED PROCEDURES THAT WILL INSERT DATA FROM MASTER JSON TO THE DOWNSTREAM TABLES AND ALSO TO CLINICAL TABLES BASED ON BATCH
--------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE LOADING.SP_APPLY_SCHEMA_CHANGES(p_batch_no STRING)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
  V_SQL STRING;
  C_NEW_TABLES CURSOR FOR
       WITH def as (
       SELECT DISTINCT L2.COLUMN_NAME, T.TABLE_NAME, L2.COLUMN_DATA_TYPE
    FROM NEW_TABLES T
    JOIN LOADING.SYNTHEA_FLATTENED_L2 L2
      ON T.TABLE_NAME = L2.TABLE_NAME 
   )
   
    SELECT TABLE_NAME,
           LISTAGG('"' || COLUMN_NAME || '" ' || COLUMN_DATA_TYPE, ', ')
             WITHIN GROUP (ORDER BY COLUMN_NAME) AS COL_DEF
    FROM def  GROUP BY TABLE_NAME;

  C_NEW_COLS CURSOR FOR
    SELECT TABLE_NAME, COLUMN_NAME, COLUMN_DATA_TYPE
    FROM NEW_COLUMNS;
BEGIN
  --------------------------------------------------------------------
  -- 1. BUILD TEMP METADATA TABLES
  --------------------------------------------------------------------
  CREATE OR REPLACE TEMP TABLE NEW_TABLES AS
  WITH DIFF_RAW AS (
    SELECT DISTINCT TABLE_NAME
    FROM   LOADING.SYNTHEA_FLATTENED_L2
    WHERE batch_no =  :p_batch_no
    MINUS
    SELECT DISTINCT TABLE_NAME
    FROM   LOADING.SYNTHEA_FLATTENED_L2
    WHERE batch_no = CONCAT('Batch-',TO_NUMBER(replace(:p_batch_no,'Batch-','')-1))
  )
  SELECT TABLE_NAME FROM DIFF_RAW;

  CREATE OR REPLACE TEMP TABLE NEW_COLUMNS AS
  WITH DIFF_RAW AS (
    SELECT DISTINCT COLUMN_NAME, COLUMN_DATA_TYPE, TABLE_NAME
    FROM   LOADING.SYNTHEA_FLATTENED_L2
    MINUS
    SELECT DISTINCT COLUMN_NAME, COLUMN_DATA_TYPE, TABLE_NAME
    FROM   LOADING.SYNTHEA_FLATTENED_L2
    WHERE batch_no = CONCAT('Batch-',TO_NUMBER(replace(:p_batch_no,'Batch-','')-1))
  )
  SELECT *
  FROM DIFF_RAW
  WHERE TABLE_NAME NOT IN (SELECT TABLE_NAME FROM NEW_TABLES);

  --------------------------------------------------------------------
  -- 2. LOOP #1: CREATE NEW  TABLES
  --------------------------------------------------------------------
  FOR REC IN C_NEW_TABLES DO
    V_SQL := 'CREATE OR REPLACE TABLE STAGING."' || REC.TABLE_NAME || '" (' ||
             'LOAD_TS TIMESTAMP, batch_no VARCHAR(16777216), ' || REC.COL_DEF || ');';

    EXECUTE IMMEDIATE V_SQL;
  END FOR;

  --------------------------------------------------------------------
  -- 3. LOOP #2: ADD NEW COLUMNS TO EXISTING SILVER TABLES
  --------------------------------------------------------------------
  FOR REC2 IN C_NEW_COLS DO
    V_SQL := 'ALTER TABLE STAGING."' || REC2.TABLE_NAME || '"' ||
             ' ADD COLUMN IF NOT EXISTS "' || REC2.COLUMN_NAME || '" ' ||
             REC2.COLUMN_DATA_TYPE || ';';

    EXECUTE IMMEDIATE V_SQL;
  END FOR;

  DROP TABLE IF EXISTS NEW_TABLES;
  DROP TABLE IF EXISTS NEW_COLUMNS;

  RETURN 'OK';
END;
$$;

CREATE OR REPLACE PROCEDURE LOADING.SP_LOAD_SILVER_DATA(p_batch_no STRING)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
  V_SQL STRING;
  
  C_INS CURSOR FOR
    SELECT 
      TABLE_NAME,
      'INSERT INTO STAGING."' || TABLE_NAME || '"(
  "LOAD_TS",
  "BATCH_NO",
  ' ||
      RTRIM(
        LISTAGG('"' || COLUMN_NAME || '"', ',\n'), 
        ',\n'
      ) || '
)
SELECT  
  CURRENT_TIMESTAMP() AS "LOAD_TS", 
  L.batch_no,
  ' ||
      RTRIM(
        LISTAGG('O.VALUE:"' || COLUMN_NAME || '" AS "' || COLUMN_NAME || '"', ',\n'), 
        ',\n'
      ) || '
FROM TMP_SYNTHEA_FLATTENED_L1 L,
     LATERAL FLATTEN(INPUT => L.CLINICAL_JSON:' || TABLE_NAME || ') O
WHERE ARRAY_CONTAINS(''' || TABLE_NAME || '''::VARIANT, L.PAT_TABLES);'
        AS INSERT_CONSTRUCT
    FROM TMP_SYNTHEA_FLATTENED_L2
    GROUP BY TABLE_NAME;
    
BEGIN
  -- Create filtered temp tables BEFORE cursor opens (static names)
  EXECUTE IMMEDIATE 'CREATE OR REPLACE TEMP TABLE TMP_SYNTHEA_FLATTENED_L1 
                     AS SELECT * FROM LOADING.SYNTHEA_FLATTENED_L1 WHERE BATCH_NO = ''' || :p_batch_no || '''';
                     
  EXECUTE IMMEDIATE 'CREATE OR REPLACE TEMP TABLE TMP_SYNTHEA_FLATTENED_L2 
                     AS SELECT * FROM LOADING.SYNTHEA_FLATTENED_L2 WHERE BATCH_NO = ''' || :p_batch_no || '''';

  FOR REC IN C_INS DO
    V_SQL := REC.INSERT_CONSTRUCT;
    EXECUTE IMMEDIATE V_SQL;
  END FOR;

  RETURN 'SUCCESS - Loaded batch: ' || :p_batch_no;
END;
$$;
