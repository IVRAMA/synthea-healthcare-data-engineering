COPY INTO MASTER_JSON (raw, filename)
FROM (
  SELECT 
      $1,
      METADATA$FILENAME
  FROM @STAGING.stage_synthea_STREAM_100_PATS 
)
FILE_FORMAT = (TYPE = JSON)
ON_ERROR = 'CONTINUE';

update MASTER_JSON set batch_no   = 'Batch-00' where batch_no is null;