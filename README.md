Healthcare dbt Analytics Pipeline
Synthea Synthetic Patient Data - Complete Project Documentation

Author: Ivrama  
Database: healthcare_raw -> healthcare_analytics  
Tech: dbt + Snowflake + Python  
Status: CSV Pipeline LIVE | JSON SPs Next

QUICK METRICS:
- 34 dbt models  
- 19 bronze tables  
- 48+ tests passing  
- 8 production SQL scripts  

4 ETL STRATEGIES:

#1 CSV External Stages - LIVE
#2 JSON SPs + Tasks - Planned  
#3 dbt-Native JSON - Planned
#4 Python 100k Patients - Planned

CSV PIPELINE (LIVE):

sql_scripts/ folder - Run order:
1. 01_setup_healthcare_env.sql
2. 02_External_stages.sql 
3. PUT 19 CSVs -> stages (one-by-one)
4. 03_raw_table_definitions.sql
5. 05_copy_data_stage_to_table.sql
6. 06_get_table_data.sql (JS preview)
7. 07_infer_data_type.sql (regex types)
8. 08_create_temp_files.sql

dbt: dbt run --full-refresh && dbt test

FOLDER STRUCTURE:
sql_scripts/     # 8 SQL files
models/          # 34 dbt models
images/          # lineage.PNG

RUN IT:
# CSV -> Bronze -> dbt
snowsql -f sql_scripts/01_*.sql  # ... 08_*.sql
dbt run && dbt test && dbt docs:serve

Production Ready Portfolio Project - March 2026