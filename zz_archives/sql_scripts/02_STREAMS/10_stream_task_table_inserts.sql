ALTER TASK synthea_raw.util.task_synthea_flattened_L1 SUSPEND;
ALTER TASK synthea_raw.util.task_synthea_flattened_L2 SUSPEND;
ALTER TASK synthea_raw.util.task_synthea_table_ddl SUSPEND;

  
CREATE OR REPLACE  TASK synthea_raw.util.task_data_insert
  WAREHOUSE = TRANSFORMING
  AFTER synthea_raw.util.task_synthea_flattened_L2
AS
BEGIN


END;

ALTER TASK synthea_raw.util.task_data_insert RESUME;
ALTER TASK synthea_raw.util.task_synthea_table_ddl RESUME;
ALTER TASK synthea_raw.util.task_synthea_flattened_L2 RESUME;
ALTER TASK synthea_raw.util.task_synthea_flattened_L1 RESUME;
