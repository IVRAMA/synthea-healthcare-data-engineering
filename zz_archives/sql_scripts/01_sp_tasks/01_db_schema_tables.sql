-------------------------------------------------------------------------------
-- 01) DATABASE,SCHEMA, TABLES  AND RBACs
-------------------------------------------------------------------------------
CREATE OR REPLACE  DATABASE MEDALLION_LAB;

-------------------------------------------------------------------------------
-- 02) CREATE SCHEMAS
-------------------------------------------------------------------------------
-- RAW LAYER
CREATE SCHEMA IF NOT EXISTS MEDALLION_LAB.BRONZE;
CREATE SCHEMA IF NOT EXISTS MEDALLION_LAB.SILVER;
CREATE SCHEMA IF NOT EXISTS MEDALLION_LAB.SILVER_UTIL;

--------------------------------------------------------------------------------------------------------------------
 -- 03) CREATE METADATA TABLES WHICH WILL PRODUCE THE CLINICAL TABLES
--------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE MEDALLION_LAB.BRONZE.MASTER_JSON
(
    RAW VARIANT,
    FILENAME STRING,
    batch_seq NUMBER default 0,
    batch_no VARCHAR(16777216), 
    LOAD_TS TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE TABLE MEDALLION_LAB.BRONZE.SYNTHEA_FLATTENED_L1 (
	PATIENT_ID VARCHAR(16777216),
	BATCH_NO VARCHAR(16777216),
	LOAD_TS TIMESTAMP_LTZ(9),
	PAT_TABLES ARRAY,
	COL_META VARIANT,
	CLINICAL_JSON OBJECT
);
CREATE OR REPLACE TABLE  MEDALLION_LAB.SILVER_UTIL.SYNTHEA_FLATTENED_L2 (
	TABLE_NAME VARCHAR(16777216),
	COLUMN_NAME VARCHAR(16777216),
	COLUMN_DATA_TYPE VARCHAR(16777216),
	BATCH_NO VARCHAR(16777216),
    LOAD_TS TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE OR REPLACE TABLE MEDALLION_LAB.SILVER_UTIL.PIPELINE_AUDIT (
  seq_num NUMBER(38,0),
  batch_no STRING,
  schema_name STRING,
  object_type STRING,
  object_name STRING,
  tot_row_count NUMBER(38,0),
  batch_row_count NUMBER(38,0),
  min_load_ts TIMESTAMP,
  max_load_ts TIMESTAMP,
  latency_seconds NUMBER(38,0),
  warehouse_name STRING,
  warehouse_size STRING,
  audit_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
