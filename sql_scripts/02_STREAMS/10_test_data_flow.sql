ALTER TASK synthea_raw.util.task_data_insert RESUME;
ALTER TASK synthea_raw.util.task_synthea_table_ddl RESUME;
ALTER TASK synthea_raw.util.task_synthea_flattened_L2 RESUME;
ALTER TASK synthea_raw.util.task_synthea_flattened_L1 RESUME;

truncate table SYNTHEA_RAW.RAW_DATA.master_json;
truncate table SYNTHEA_RAW.UTIL.synthea_flattened_l1;
truncate table SYNTHEA_RAW.UTIL.synthea_flattened_l2;
TRUNCATE TABLE SYNTHEA_RAW.RAW_DATA."ALLERGYINTOLERANCE";
TRUNCATE TABLE SYNTHEA_RAW.RAW_DATA."CAREPLAN";
TRUNCATE TABLE SYNTHEA_RAW.RAW_DATA."CLAIM";
TRUNCATE TABLE SYNTHEA_RAW.RAW_DATA."CONDITION";
TRUNCATE TABLE SYNTHEA_RAW.RAW_DATA."DIAGNOSTICREPORT";
TRUNCATE TABLE SYNTHEA_RAW.RAW_DATA."ENCOUNTER";
TRUNCATE TABLE SYNTHEA_RAW.RAW_DATA."EXPLANATIONOFBENEFIT";
TRUNCATE TABLE SYNTHEA_RAW.RAW_DATA."GOAL";
TRUNCATE TABLE SYNTHEA_RAW.RAW_DATA."IMAGINGSTUDY";
TRUNCATE TABLE SYNTHEA_RAW.RAW_DATA."IMMUNIZATION";
TRUNCATE TABLE SYNTHEA_RAW.RAW_DATA."MEDICATIONREQUEST";
TRUNCATE TABLE SYNTHEA_RAW.RAW_DATA."OBSERVATION";
TRUNCATE TABLE SYNTHEA_RAW.RAW_DATA."ORGANIZATION";
TRUNCATE TABLE SYNTHEA_RAW.RAW_DATA."PATIENT";
TRUNCATE TABLE SYNTHEA_RAW.RAW_DATA."PRACTITIONER";
TRUNCATE TABLE SYNTHEA_RAW.RAW_DATA."PROCEDURE";


COPY INTO SYNTHEA_RAW.RAW_DATA.master_json (raw, filename) FROM (SELECT $1, METADATA$FILENAME FROM @SYNTHEA_RAW.EXTERNAL_STAGES.stage_synthea_STREAM_100_PATS) FILE_FORMAT = (TYPE = JSON) ON_ERROR = 'CONTINUE';

EXECUTE TASK synthea_raw.util.task_synthea_flattened_L1;

SHOW TASKS IN SCHEMA synthea_raw.util;


SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    TASK_NAME => 'task_synthea_flattened_L1'
));


SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    TASK_NAME => 'task_synthea_flattened_L2'
));

SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    TASK_NAME => 'task_synthea_table_ddl'
));

SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    TASK_NAME => 'task_data_insert'
));

select '01 master_json' as table_name, count(*) as cnt from synthea_raw.raw_data.master_json union all
select '02 synthea_flattened_l1' as table_name, count(*) as cnt from synthea_raw.util.synthea_flattened_l1 union all 
select '03 synthea_flattened_l2' as table_name, count(*) as cnt from  synthea_raw.util.synthea_flattened_l2 UNION ALL
select '04 AllergyIntolerance' as table_name, count(*) as cnt  from SYNTHEA_RAW.RAW_DATA.ALLERGYINTOLERANCE union all
select '05 CarePlan' as table_name, count(*) as cnt  from SYNTHEA_RAW.RAW_DATA.CAREPLAN union all
select '06 Claim' as table_name, count(*) as cnt  from SYNTHEA_RAW.RAW_DATA.CLAIM union all
select '07 Condition' as table_name, count(*) as cnt  from SYNTHEA_RAW.RAW_DATA.CONDITION union all
select '08 DiagnosticReport' as table_name, count(*) as cnt  from SYNTHEA_RAW.RAW_DATA.DIAGNOSTICREPORT union all
select '09 Encounter' as table_name, count(*) as cnt  from SYNTHEA_RAW.RAW_DATA.ENCOUNTER union all
select '10 ExplanationOfBenefit' as table_name, count(*) as cnt  from SYNTHEA_RAW.RAW_DATA.EXPLANATIONOFBENEFIT union all
select '11 Goal' as table_name, count(*) as cnt  from SYNTHEA_RAW.RAW_DATA.GOAL union all
select '12 ImagingStudy' as table_name, count(*) as cnt  from SYNTHEA_RAW.RAW_DATA.IMAGINGSTUDY union all
select '13 Immunization' as table_name, count(*) as cnt  from SYNTHEA_RAW.RAW_DATA.IMMUNIZATION union all
select '14 MedicationRequest' as table_name, count(*) as cnt  from SYNTHEA_RAW.RAW_DATA.MEDICATIONREQUEST union all
select '15 Observation' as table_name, count(*) as cnt  from SYNTHEA_RAW.RAW_DATA.OBSERVATION union all
select '16 Organization' as table_name, count(*) as cnt  from SYNTHEA_RAW.RAW_DATA.ORGANIZATION union all
select '17 Patient' as table_name, count(*) as cnt  from SYNTHEA_RAW.RAW_DATA.PATIENT union all
select '18 Practitioner' as table_name, count(*) as cnt  from SYNTHEA_RAW.RAW_DATA.PRACTITIONER union all
select '19 Procedure' as table_name, count(*) as cnt  from SYNTHEA_RAW.RAW_DATA.PROCEDURE;
