CREATE OR REPLACE TABLE SYNTHEA_RAW.RAW_DATA.master_json
(
    raw VARIANT,
    filename STRING,
    load_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


COPY INTO SYNTHEA_RAW.RAW_DATA.master_json (raw, filename)
FROM (
    SELECT $1,
           METADATA$FILENAME
    FROM @SYNTHEA_RAW.EXTERNAL_STAGES.stage_synthea
)
FILE_FORMAT = (TYPE = JSON)
ON_ERROR = 'CONTINUE';

SELECT COUNT(*) FROM SYNTHEA_RAW.RAW_DATA.master_json;


SELECT
    DISTINCT
    OBJECT_KEYS(raw) AS top_level_keys
FROM SYNTHEA_RAW.RAW_DATA.master_json;


-- this script fetches the table names in the current data set

select distinct replace(resource_type, '"','') as tbl from 
(SELECT
    raw:entry[index]:resource:resourceType AS resource_type,
    raw:entry[index]:resource AS resource_json
FROM SYNTHEA_RAW.RAW_DATA.master_json,
     LATERAL FLATTEN(input => raw:entry) f);


-- general script to get table name and the respective json

SELECT
    raw:entry[index]:resource:resourceType AS resource_type,
    raw:entry[index]:resource AS resource_json
FROM SYNTHEA_RAW.RAW_DATA.master_json,
     LATERAL FLATTEN(input => raw:entry) f;

-- this is a variation where instead of querying dlattened data we query the json to fetch each row (we get this wiht index coming from flatten. like an array)
select count(*) as cnt, replace(raw:entry[index]:request:url, '"', '') as  tbl  
from SYNTHEA_RAW.RAW_DATA.master_json,  table(flatten(input => raw:entry)) f
group by tbl;
order by  tbl;


-- generic query to get patient name and patient sequence number. just a test. the number is not not unique
SELECT
    filename,
    REGEXP_SUBSTR(filename, '^[A-Za-z]+') AS pat_name,
    to_number(REGEXP_SUBSTR(filename, '[0-9]+')) AS pat_num,
    REGEXP_SUBSTR(filename, '^[A-Za-z]+[0-9]+') AS name_and_number
FROM SYNTHEA_RAW.RAW_DATA.master_json order by 3;





select 
    f.value:fullUrl::string patient_id
    , f.value resource_json
    , current_timestamp as load_ts
from 
    synthea_raw.raw_data.master_json
    , lateral flatten (input => raw:entry)f order by 1; 
