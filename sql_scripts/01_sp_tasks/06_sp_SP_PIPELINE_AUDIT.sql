CREATE OR REPLACE PROCEDURE MEDALLION_LAB.SILVER_UTIL.SP_PIPELINE_AUDIT(p_batch_no STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  res STRING DEFAULT 'Audit completed successfully';
BEGIN
  CREATE OR REPLACE TEMP TABLE MEDALLION_LAB.SILVER_UTIL.TEMP_PIPELINE_AUDIT AS
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
  WHERE t.table_schema IN ('BRONZE','SILVER_UTIL','SILVER') 
    AND t.table_catalog = 'MEDALLION_LAB'  AND TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME <> 'PIPELINE_AUDIT'
  ORDER BY t.LAST_DDL DESC;

  LET table_rs RESULTSET := (
    SELECT seq_num, schema_name, object_name
    FROM MEDALLION_LAB.SILVER_UTIL.TEMP_PIPELINE_AUDIT
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
    UPDATE MEDALLION_LAB.SILVER_UTIL.TEMP_PIPELINE_AUDIT 
    SET batch_row_count = :v_batch_count,
        min_load_ts = :v_min_ts,
        max_load_ts = :v_max_ts,
        latency_seconds = DATEDIFF('second', :v_min_ts, :v_max_ts)
    WHERE seq_num = :v_seq_num;
  END FOR;

  INSERT INTO MEDALLION_LAB.SILVER_UTIL.PIPELINE_AUDIT 
  SELECT * FROM MEDALLION_LAB.SILVER_UTIL.TEMP_PIPELINE_AUDIT;
  
  RETURN res;
END;
$$;