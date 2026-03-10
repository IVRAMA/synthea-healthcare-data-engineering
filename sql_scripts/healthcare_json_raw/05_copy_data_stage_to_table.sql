USE ROLE transform_role;
USE WAREHOUSE TRANSFORMING;
USE DATABASE HEALTHCARE_JSON_RAW;
USE SCHEMA HEALTHCARE_JSON_RAW.STAGING;

COPY INTO MASTER_JSON (raw, filename)
FROM (
  SELECT 
      $1,
      METADATA$FILENAME
  FROM @HEALTHCARE_JSON_RAW.STAGING.stage_synthea_STREAM_100_PATS 
)
FILE_FORMAT = (TYPE = JSON)
ON_ERROR = 'CONTINUE';

update MASTER_JSON set batch_seq  = (select max(batch_seq) +1  from MASTER_JSON) 
where batch_seq = 0;

update MASTER_JSON set batch_no   = 'Batch-00' where batch_no is null;