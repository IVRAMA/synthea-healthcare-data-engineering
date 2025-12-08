-- this scipts gets the referentials in the json helpful for L4 table 
SELECT
    entry.value:resource:resourceType::string AS resource_type,
    lvl.key                                  AS level_key,
    lvl.value::string                        AS level_value
FROM SYNTHEA_RAW.RAW_DATA.master_json t,
     LATERAL FLATTEN(input => t.raw:entry) entry,
     LATERAL FLATTEN(input => entry.value:resource, recursive => TRUE) lvl
WHERE lvl.key = 'reference'
LIMIT 200;


CREATE OR REPLACE TEMP TABLE SYNTHEA_RAW.RAW_DATA.uuid_resource_map AS
SELECT
    entry.value:resource:id::string                 AS uuid,
    entry.value:resource:resourceType::string       AS resource_type
FROM SYNTHEA_RAW.RAW_DATA.master_json t,
     LATERAL FLATTEN(input => t.raw:entry) entry;


CREATE OR REPLACE TEMP TABLE SYNTHEA_RAW.RAW_DATA.uuid_reference_map AS
SELECT
    entry.value:resource:id::string AS source_uuid,
    entry.value:resource:resourceType::string AS source_resource,
    REGEXP_REPLACE(lvl.value::string, '^urn:uuid:', '') AS target_uuid
FROM SYNTHEA_RAW.RAW_DATA.master_json t,
     LATERAL FLATTEN(input => t.raw:entry) entry,
     LATERAL FLATTEN(input => entry.value:resource, recursive => TRUE) lvl
WHERE lvl.key = 'reference'
  AND lvl.value::string LIKE 'urn:uuid%';


CREATE OR REPLACE TABLE SYNTHEA_RAW.UTIL.synthea_flattened_L3 AS
SELECT DISTINCT
    r.source_resource,
    r.source_uuid,
    u.resource_type AS target_resource,
    r.target_uuid
FROM SYNTHEA_RAW.RAW_DATA.uuid_reference_map r
LEFT JOIN SYNTHEA_RAW.RAW_DATA.uuid_resource_map u
       ON r.target_uuid = u.uuid
WHERE u.resource_type IS NOT NULL;


select * from SYNTHEA_RAW.UTIL.synthea_flattened_L3;