USE ROLE transform_role;
USE WAREHOUSE TRANSFORMING;
USE DATABASE HEALTHCARE_JSON_RAW;
USE SCHEMA HEALTHCARE_JSON_RAW.STAGING;



COPY INTO MASTER_JSON (raw, filename)
FROM (
  SELECT 
      $1,
      METADATA$FILENAME
  FROM @stage_synthea_batch_02
)
FILE_FORMAT = (TYPE = JSON)
ON_ERROR = 'CONTINUE';


update MASTER_JSON set batch_seq  = (select max(batch_seq) +1  from MASTER_JSON) 
where batch_seq = 0;

update MASTER_JSON set batch_no   = 'Batch-' || batch_seq
where batch_no is null;


EXECUTE TASK HEALTHCARE_RAW.SILVER_UTIL.MASTER_TO_L1_MERGE;


select * from 
(SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(RESULT_LIMIT => 100)) 
ORDER BY SCHEDULED_TIME DESC)  where database_name  = 'HEALTHCARE_JSON_RAW';

select * from pipeline_audit where tot_row_count = batch_row_count;