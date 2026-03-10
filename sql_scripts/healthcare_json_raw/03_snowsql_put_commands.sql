PUT file://C:/dbt_projects/healthcare_db/json/stream_100_pats/*.json @HEALTHCARE_JSON_RAW.STAGING.stage_synthea_STREAM_100_PATS AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/json/batch_01/*.json @HEALTHCARE_JSON_RAW.STAGING.stage_synthea_batch_01 AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/json/batch_02/*.json @HEALTHCARE_JSON_RAW.STAGING.stage_synthea_batch_02 AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/json/batch_03/*.json @HEALTHCARE_JSON_RAW.STAGING.stage_synthea_batch_03 AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/json/batch_04/*.json @HEALTHCARE_JSON_RAW.STAGING.stage_synthea_batch_04 AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/json/batch_05/*.json @HEALTHCARE_JSON_RAW.STAGING.stage_synthea_batch_05 AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/json/batch_06/*.json @HEALTHCARE_JSON_RAW.STAGING.stage_synthea_batch_06 AUTO_COMPRESS=TRUE;