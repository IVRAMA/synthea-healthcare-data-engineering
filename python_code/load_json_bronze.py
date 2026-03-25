#!/usr/bin/env python3
"""JSON bronze load: FHIR → Snowflake Bronze Layer."""
import yaml
from pathlib import Path
import subprocess
import pandas as pd
import sys

# 2D array: [filename, schema] - business logic
JSON_SQL_FILES = [
    ["01_setup_databases.sql", "STAGING"],
    ["02_Create_stages.sql", "STAGING"],
    ["03_snowsql_put_commands.sql", "STAGING"],
    ["04_Create_tables.sql", "STAGING"],
    ["05_Copy_data_stage_to_table.sql", "STAGING"],
    ["06_stored_procedure_for_Meta_Data.sql", "STAGING"],
    ["06a_metadata_staging_sp.sql", "BRONZE"],  # ← BRONZE SPs
    ["07_Create_snowflake_tasks.sql", "BRONZE"],
    ["08_execute_snowflake_tasks.sql", "BRONZE"]
]

# BRONZE files get special connection
BRONZE_SQL_FILES = {"06a_metadata_staging_sp.sql", "07_Create_snowflake_tasks.sql","08_execute_snowflake_tasks.sql"}

def get_snowsql_cmd(sql_file, script_dir, config):
    """Dynamic command based on file type."""
    connection = "HEALTHCARE_JSON_BRONZE" if sql_file in BRONZE_SQL_FILES else "HEALTHCARE_JSON_RAW"
    
    return [
        "snowsql",
        "--connection", connection,
        "-w", config['wh'],
        "-f", str(script_dir / sql_file),
        "-D", f"ACCOUNT_ROLE={config['account_role']}",
        "-D", f"DB_JSON={config['db_json']}",
        "-D", f"WH={config['wh']}"
    ]

def main():
    with open("config.yaml") as f:
        config = yaml.safe_load(f)
    
    json_script_dir = Path(config['paths']['json_scripts'])
    json_log_dir = Path("C:\\dbt_projects\\healthcare_db\\json_logs") / f"load_{pd.Timestamp.now().strftime('%Y%m%d_%H%M')}"
    json_log_dir.mkdir(parents=True, exist_ok=True)
    
    print("🚀 Starting JSON Bronze Pipeline...")
    
    for sql_file_info in JSON_SQL_FILES:
        sql_file, schema = sql_file_info
        log_path = json_log_dir / f"{Path(sql_file).stem}.log"
        
        # Determine connection and emoji
        if sql_file in BRONZE_SQL_FILES:
            emoji, conn = "🟫 BRONZE", "HEALTHCARE_JSON_BRONZE"
        else:
            emoji, conn = "🟦 STAGING", "HEALTHCARE_JSON_RAW"
        
        print(f"{emoji} {conn} → {sql_file}...")
        
        cmd = get_snowsql_cmd(sql_file, json_script_dir, config)
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
        
        # Write full log
        with open(log_path, "w") as f:
            f.write(result.stdout)
            if result.stderr:
                f.write("\n--- STDERR ---\n" + result.stderr)
        
        # Error handling
        if result.returncode != 0:
            error_dir = json_log_dir / "errors"
            error_dir.mkdir(exist_ok=True)
            error_path = error_dir / f"{Path(sql_file).stem}.error"
            subprocess.run("copy {} {}".format(log_path, error_path), shell=True)
            print(f"❌ {sql_file} FAILED → {error_path}")
            sys.exit(1)
        
        print(f"✅ {emoji} {sql_file} → {log_path}")
    
    print(f"\n🎉 JSON BRONZE PIPELINE COMPLETE!")
    print(f"📂 Logs: {json_log_dir}")
    subprocess.Popen(["explorer", str(json_log_dir)])

if __name__ == "__main__":
    main()
