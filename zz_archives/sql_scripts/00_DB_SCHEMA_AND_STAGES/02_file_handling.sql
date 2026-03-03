-------------------------------------------------------------------------------
-- 5) CREATE FILE FORMAT
-------------------------------------------------------------------------------
CREATE OR REPLACE FILE FORMAT SYNTHEA_RAW.BRONZE_STAGES.json_format
  TYPE = JSON
  COMPRESSION = AUTO
  STRIP_OUTER_ARRAY = TRUE;

  USE ROLE LOADING;
-------------------------------------------------------------------------------
-- 6) CREATE EXTERNAL STAGE (for JSON upload)
-------------------------------------------------------------------------------
CREATE OR REPLACE STAGE SYNTHEA_RAW.BRONZE_STAGES.stage_synthea
  FILE_FORMAT = SYNTHEA_RAW.BRONZE_STAGES.json_format;
-------------------------------------------------------------------------------

CREATE OR REPLACE STAGE SYNTHEA_RAW.BRONZE_STAGES.stage_synthea_STREAM_100_PATS FILE_FORMAT = SYNTHEA_RAW.BRONZE_STAGES.json_format;
CREATE OR REPLACE STAGE SYNTHEA_RAW.BRONZE_STAGES.stage_synthea_batch_02 FILE_FORMAT = SYNTHEA_RAW.BRONZE_STAGES.json_format;
CREATE OR REPLACE STAGE SYNTHEA_RAW.BRONZE_STAGES.stage_synthea_batch_03 FILE_FORMAT = SYNTHEA_RAW.BRONZE_STAGES.json_format;
CREATE OR REPLACE STAGE SYNTHEA_RAW.BRONZE_STAGES.stage_synthea_batch_04 FILE_FORMAT = SYNTHEA_RAW.BRONZE_STAGES.json_format;
CREATE OR REPLACE STAGE SYNTHEA_RAW.BRONZE_STAGES.stage_synthea_batch_05 FILE_FORMAT = SYNTHEA_RAW.BRONZE_STAGES.json_format;
CREATE OR REPLACE STAGE SYNTHEA_RAW.BRONZE_STAGES.stage_synthea_batch_06 FILE_FORMAT = SYNTHEA_RAW.BRONZE_STAGES.json_format;
CREATE OR REPLACE STAGE SYNTHEA_RAW.BRONZE_STAGES.stage_synthea_batch_07 FILE_FORMAT = SYNTHEA_RAW.BRONZE_STAGES.json_format;
CREATE OR REPLACE STAGE SYNTHEA_RAW.BRONZE_STAGES.stage_synthea_batch_08 FILE_FORMAT = SYNTHEA_RAW.BRONZE_STAGES.json_format;
CREATE OR REPLACE STAGE SYNTHEA_RAW.BRONZE_STAGES.stage_synthea_batch_09 FILE_FORMAT = SYNTHEA_RAW.BRONZE_STAGES.json_format;
CREATE OR REPLACE STAGE SYNTHEA_RAW.BRONZE_STAGES.stage_synthea_batch_10 FILE_FORMAT = SYNTHEA_RAW.BRONZE_STAGES.json_format;


-- this needs to be done in the terminal as follows: 

-- change .snowsql config file present in C:\Users\MY-PC\.snowsql 

/* 
[connections.synthea_conn1]
account = "PL41839"
user = "HEALTHCARE"
password = "Healthcare_User123"
host = "NVVISFB-PL41839.snowflakecomputing.com"
region = "AWS_AP_SOUTHEAST_1"
database = "SYNTHEA_RAW"
schema = "RAW_DATA"
warehouse = "TRANSFORMING"
role = "LOADING"
authenticator = "SNOWFLAKE"

snowsql --connection=synthea_conn1
*/



PUT file://C:/dbt_projects/healthcare_db/json/batch_01/*.json @SYNTHEA_RAW.BRONZE_STAGES.stage_synthea AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/json/stream_100_pats/*.json @SYNTHEA_RAW.BRONZE_STAGES.stage_synthea_STREAM_100_PATS AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/json/batch_01/*.json @SYNTHEA_RAW.BRONZE_STAGES.stage_synthea AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/json/batch_02/*.json @SYNTHEA_RAW.BRONZE_STAGES.stage_synthea_batch_02 AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/json/batch_03/*.json @SYNTHEA_RAW.BRONZE_STAGES.stage_synthea_batch_03 AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/json/batch_04/*.json @SYNTHEA_RAW.BRONZE_STAGES.stage_synthea_batch_04 AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/json/batch_05/*.json @SYNTHEA_RAW.BRONZE_STAGES.stage_synthea_batch_05 AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/json/batch_06/*.json @SYNTHEA_RAW.BRONZE_STAGES.stage_synthea_batch_06 AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/json/batch_07/*.json @SYNTHEA_RAW.BRONZE_STAGES.stage_synthea_batch_07 AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/json/batch_08/*.json @SYNTHEA_RAW.BRONZE_STAGES.stage_synthea_batch_08 AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/json/batch_09/*.json @SYNTHEA_RAW.BRONZE_STAGES.stage_synthea_batch_09 AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/json/batch_10/*.json @SYNTHEA_RAW.BRONZE_STAGES.stage_synthea_batch_10 AUTO_COMPRESS=TRUE;