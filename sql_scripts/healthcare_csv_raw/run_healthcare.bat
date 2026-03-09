@echo off
set CONNECTION=HEALTHCARE_CSV_RAW
set SCRIPT_DIR=C:\dbt_projects\healthcare_db\csv_scripts
set LOG_DIR=logs\%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%
mkdir "%LOG_DIR%" 2>nul

echo Pipeline starting...

snowsql --connection=%CONNECTION% -w TRANSFORMING -f "%SCRIPT_DIR%\01_setup_databases.sql"           > "%LOG_DIR%\01_setup.txt"  2>&1
snowsql --connection=%CONNECTION% -w TRANSFORMING -f "%SCRIPT_DIR%\02_Create_stages.sql"             > "%LOG_DIR%\02_stages.txt"  2>&1
snowsql --connection=%CONNECTION% -w TRANSFORMING -f "%SCRIPT_DIR%\03_snowsql_put_commands.sql"      > "%LOG_DIR%\03_put.txt"     2>&1
snowsql --connection=%CONNECTION% -w TRANSFORMING -f "%SCRIPT_DIR%\04_Create_tables.sql"             > "%LOG_DIR%\04_tables.txt"  2>&1
snowsql --connection=%CONNECTION% -w TRANSFORMING -f "%SCRIPT_DIR%\05_Copy_data_stage_to_table.sql"  > "%LOG_DIR%\05_copy.txt"    2>&1
snowsql --connection=%CONNECTION% -w TRANSFORMING -f "%SCRIPT_DIR%\06_Stored_procedure_for_Meta_Data.sql" > "%LOG_DIR%\06_sp.txt"  2>&1
snowsql --connection=%CONNECTION% -w TRANSFORMING -f "%SCRIPT_DIR%\07_infer_column_datatype.sql"     > "%LOG_DIR%\07_infer.txt"   2>&1

echo Complete! Output logs: %LOG_DIR%\
explorer "%LOG_DIR%"
