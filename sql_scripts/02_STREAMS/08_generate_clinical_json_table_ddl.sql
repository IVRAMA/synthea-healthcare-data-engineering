-- table ddl creator
WITH raw_ddl AS ( 
    SELECT DISTINCT
        column_name,
        column_data_type,
        table_name
    FROM synthea_raw.util.synthea_flattened_l2
)
SELECT 
    table_name,
      'CREATE  OR REPLACE TABLE SYNTHEA_RAW.RAW_DATA.'  || table_name || '(
PATIENT_ID VARCHAR(16777216) ,
' ||
      RTRIM(
        LISTAGG('"' || column_name || '" ' || column_data_type || ',\n')
          WITHIN GROUP (ORDER BY column_name),
        ',\n'
      ) || ');'  AS create_construct
,      'INSERT INTO SYNTHEA_RAW.RAW_DATA.'  || table_name || '(
"PATIENT_ID",
' ||
      RTRIM(
        LISTAGG('"' || column_name || '"', ',\n')
          WITHIN GROUP (ORDER BY column_name),
        ',\n'
      ) || '
)
SELECT
    l.PATIENT_ID AS "PATIENT_ID",
' ||
      RTRIM(
        LISTAGG('o.value:"' || column_name || '" AS "' || column_name || '"', ',\n')
          WITHIN GROUP (ORDER BY column_name),
        ',\n'
      ) || '
FROM SYNTHEA_RAW.UTIL.SYNTHEA_FLATTENED_L1 l,
     LATERAL FLATTEN (INPUT => l.CLINICAL_JSON:' || table_name || ') o
WHERE ARRAY_CONTAINS(''' || table_name || '''::VARIANT, PAT_TABLES);'
    AS insert_construct
, 'select ''' || table_name || ''' as table_name, count(*) as cnt  from ' || table_name || ' union all' as cnts
, 'TRUNCATE TABLE SYNTHEA_RAW.RAW_DATA."' || upper(table_name) || '";' AS truncate_statement
FROM raw_ddl
GROUP BY table_name
ORDER BY table_name;