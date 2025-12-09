/*The aim of this script is to flatten the data in the master json file and retrieve clinical json from raw (variant) column
I am achieving this by first retrieving patient_id from the entry element
then flatten (lateral) to fetch  resouce_json
The resource_type corresponds to the table name in the json
I am giving the resource json as input for furthet flattening to retrieve the columns names.

to ensure each row contains compelte json for a patient and not explode into many rows i am aggregating jsons with object_agg and aggregating arraus with array_agg
I am also creating an array of  structure to store table, column, dataype for each patient. 


*/
CREATE OR REPLACE TEMP TABLE synthea_raw.util.flattened_json AS  
    (SELECT  
            raw:entry[0].fullUrl::string as  patient_id
            , f.value:resource:resourceType as fkey
            , f.value:resource  fval
            , g.key AS column_name
            , typeof(g.value) AS data_type_L1
    FROM 
            synthea_raw.raw_data.master_json
            , lateral flatten (input => raw:entry)f
            , lateral flatten (input => fval)g); 

CREATE OR REPLACE TEMP TABLE synthea_raw.util.array_agg_flattened_json AS
    (SELECT 
            patient_id,fkey
            ,CAST(ARRAY_AGG(fval) AS VARIANT) as fval from synthea_raw.util.flattened_json  group by 1,2); 

create or replace temp table synthea_raw.util.col_data_for_agg as 
WITH 
flat_L1 AS
    (SELECT  
            raw:entry[0].fullUrl::string as  patient_id
            , f.value:resource:resourceType::STRING as fkey
            , f.value:resource  fval
            , g.key AS column_name
            , typeof(g.value) AS data_type_L1
    FROM 
            synthea_raw.raw_data.master_json
            , lateral flatten (input => raw:entry)f
            , lateral flatten (input => fval)g
    WHERE data_type_L1 <>  'OBJECT'
    ),
flat_L2 AS
    (SELECT
        raw:entry[0].fullUrl::string as  patient_id
        , f.value:resource:resourceType::STRING as fkey
        , f.value:resource  fval
        , h.key as  column_name
        , typeof(h.value) AS data_type_L1
    FROM 
        synthea_raw.raw_data.master_json
        , LATERAL FLATTEN (INPUT => raw:entry)f
        , LATERAL FLATTEN (INPUT => fval)g
        ,  LATERAL FLATTEN (INPUT => g.value)h
    WHERE typeof(g.value) = 'OBJECT'
    )
SELECT * from flat_L1 union all select * from flat_l2
;

CREATE OR REPLACE TEMP TABLE synthea_raw.util.col_meta_json AS
(
    SELECT patient_id, ARRAY_AGG(OBJECT_CONSTRUCT(
                'table',  fkey,
                'column', column_name,
                'datatype', data_type_L1
            )
        )::VARIANT AS col_val
    FROM (
        SELECT DISTINCT
            patient_id,
            fkey,
            column_name,
            data_type_L1
        FROM synthea_raw.util.col_data_for_agg
    ) d
    GROUP BY
        patient_id
);


    
CREATE OR REPLACE TABLE synthea_raw.util.synthea_flattened_L1 AS
    (SELECT 
        a.patient_id
        , current_timestamp as load_ts
        , ARRAY_AGG(a.fkey) as pat_tables
        , min(col_val) as col_meta
        , OBJECT_AGG(a.fkey,a.fval) as clinical_json
    FROM synthea_raw.util.array_agg_flattened_json a INNER JOIN synthea_raw.util.col_meta_json c on a.patient_id = c.patient_id
    GROUP BY  a.patient_id) ;


select patient_id, pat_tables, col_meta from synthea_raw.util.synthea_flattened_L1;



