-------------------------------------------------------------------------------
-- 5) CREATE FILE FORMAT
-------------------------------------------------------------------------------
CREATE OR REPLACE FILE FORMAT SYNTHEA_RAW.EXTERNAL_STAGES.json_format
  TYPE = JSON
  COMPRESSION = AUTO
  STRIP_OUTER_ARRAY = TRUE;

  USE ROLE LOADING;
-------------------------------------------------------------------------------
-- 6) CREATE EXTERNAL STAGE (for JSON upload)
-------------------------------------------------------------------------------
CREATE OR REPLACE STAGE SYNTHEA_RAW.EXTERNAL_STAGES.stage_synthea
  FILE_FORMAT = SYNTHEA_RAW.EXTERNAL_STAGES.json_format;
-------------------------------------------------------------------------------


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



PUT file://C:/dbt_projects/healthcare_db/json/batch_01/*.json @SYNTHEA_RAW.EXTERNAL_STAGES.stage_synthea AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/json/allergies.csv  @healthcare_raw.external_stages.stage_allergies AUTO_COMPRESS=TRUE;

LIST @SYNTHEA_RAW.EXTERNAL_STAGES.stage_synthea;

