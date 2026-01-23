CREATE OR REPLACE STREAM synthea_raw.util.synthea_flattened_L1_str
  ON TABLE synthea_raw.util.synthea_flattened_L1;


CREATE OR REPLACE  TASK synthea_raw.util.task_synthea_flattened_L2
  WAREHOUSE = TRANSFORMING
  AFTER synthea_raw.util.task_synthea_flattened_L1
AS
BEGIN
INSERT INTO synthea_raw.util.synthea_flattened_L2 (
    table_name,
    column_name,
    column_data_type
)
SELECT
    table_name       AS table_name,
    column_name      AS column_name,
    col_data_type    AS column_data_type
FROM (
    SELECT
        f.value:column::string   AS column_name,
        f.value:table::string    AS table_name,
        f.value:datatype::string AS col_data_type
    FROM synthea_raw.util.synthea_flattened_L1,
         LATERAL FLATTEN (INPUT => col_meta) f
)
GROUP BY 1,2,3
ORDER BY 1,2,3;

END;
select * from synthea_raw.util.master_json_str;


-- test task and stream functionality
ALTER TASK synthea_raw.util.task_synthea_flattened_L1 SUSPEND;
ALTER TASK synthea_raw.util.task_synthea_flattened_L2 RESUME;
ALTER TASK synthea_raw.util.task_synthea_flattened_L1 RESUME;

ALTER TASK synthea_raw.util.task_synthea_flattened_L1 SET SCHEDULE = 'USING CRON */5 * * * * Asia/Kolkata';

EXECUTE TASK synthea_raw.util.task_synthea_flattened_L1;

SHOW TASKS IN SCHEMA synthea_raw.util;


SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    TASK_NAME => 'TASK_SYNTHEA_FLATTENED_L1'
));


SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    TASK_NAME => 'task_synthea_flattened_L2'
));

select '01 master_json' as tbl, count(*) as cnt from synthea_raw.raw_data.master_json union all
select '02 synthea_flattened_l1' as tbl, count(*) as cnt from synthea_raw.util.synthea_flattened_l1 union all 
select '03 synthea_flattened_l2' as tbl, count(*) as cnt from  synthea_raw.util.synthea_flattened_l2 ;