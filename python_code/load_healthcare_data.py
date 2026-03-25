#!/usr/bin/env python3
"""Unified CSV + JSON Bronze Load → Snowflake. Vars centralized in config.yaml."""
import subprocess
from pathlib import Path
import sys
import pandas as pd
import yaml
import argparse


SHARED_SQL_FILES = ["00_create_databases.sql"]  # Common DB/Schema setup

CSV_SQL_FILES = [
    "02_Create_stages.sql",
    "03_snowsql_put_commands.sql",
    "04_Create_tables.sql",
    "05_Copy_data_stage_to_table.sql",
    "06_Stored_procedure_for_Meta_Data.sql",
    "07_infer_column_datatype.sql"
]

JSON_SQL_FILES = [
    ["02_Create_stages.sql", "STAGING"],
    ["03_snowsql_put_commands.sql", "STAGING"],
    ["04_Create_tables.sql", "STAGING"],
    ["05_Copy_data_stage_to_table.sql", "STAGING"],
    ["06_stored_procedure_for_Meta_Data.sql", "STAGING"],
    ["06a_metadata_staging_sp.sql", "BRONZE"],
    ["07_Create_snowflake_tasks.sql", "BRONZE"],
    ["08_execute_snowflake_tasks.sql", "BRONZE"]
]

BRONZE_SQL_FILES = {"06a_metadata_staging_sp.sql", "07_Create_snowflake_tasks.sql", "08_execute_snowflake_tasks.sql"}


def run_snowsql(cmd, log_path, error_root, label):
    """Run SnowSQL + log + error handling."""
    result = subprocess.run(cmd, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, universal_newlines=True)

    log_path.parent.mkdir(parents=True, exist_ok=True)
    with open(log_path, "w") as f:
        f.write(result.stdout)
        if result.stderr:
            f.write("\n--- STDERR ---\n" + result.stderr)

    if result.returncode != 0:
        error_dir = error_root / "errors"
        error_dir.mkdir(exist_ok=True)
        error_path = error_dir / f"{log_path.stem}.error"
        with open(error_path, "w") as f:
            f.write(f"LABEL: {label}\nRETURN: {result.returncode}\nSTDERR:\n{result.stderr}")
        print(f"❌ {label} → {error_path}")
        sys.exit(1)

    print(f"✅ {label} → {log_path}")


def get_csv_snowsql_cmd(sql_file, script_dir, config):
    return [
        "snowsql", "--connection", "HEALTHCARE_CSV_RAW",
        "-w", config['wh'], "-f", str(script_dir / sql_file),
        "-D", f"ACCOUNT_ROLE={config['account_role']}",
        "-D", f"HCB_DB={config['db_csv']}",
        "-D", f"HCB_SCHEMA={config['schema_csv']}",
        "-D", f"WH={config['wh']}"
    ]


def get_json_snowsql_cmd(sql_file, script_dir, config):
    conn = "HEALTHCARE_JSON_BRONZE" if sql_file in BRONZE_SQL_FILES else "HEALTHCARE_JSON_RAW"
    return [
        "snowsql", "--connection", conn,
        "-w", config['wh'], "-f", str(script_dir / sql_file),
        "-D", f"ACCOUNT_ROLE={config['account_role']}",
        "-D", f"HJB_DB={config['db_json']}",
        "-D", f"WH={config['wh']}"
    ]


def get_shared_snowsql_cmd(sql_file, script_dir, config):
    return [
        "snowsql", "--connection", "HEALTHCARE_CSV_RAW",  # Neutral conn for admin tasks
        "-w", config['wh'], "-f", str(script_dir / sql_file),
        "-D", f"HCB_DB={config['db_csv']}",
        "-D", f"HJB_DB={config['db_json']}",
        "-D", f"HCB_SCHEMA={config['schema_csv']}",
        "-D", f"HJB_STAGING_SCHEMA={config['schema_staging']}",
        "-D", f"HJB_BRONZE_SCHEMA={config['schema_bronze']}",
        "-D", f"WH={config['wh']}"
    ]


def run_shared_pipeline(config):
    shared_script_dir = Path("C:\\dbt_projects\\healthcare_db\\scripts\\shared_scripts")  # New shared dir
    shared_log_dir = Path("C:\\dbt_projects\\healthcare_db\\logs\\shared_logs") / \
                     f"load_{pd.Timestamp.now().strftime('%Y%m%d_%H%M')}"
    
    print("🏗️ Creating Databases/Schemas...")
    for sql_file in SHARED_SQL_FILES:
        cmd = get_shared_snowsql_cmd(sql_file, shared_script_dir, config)
        log_path = shared_log_dir / f"{Path(sql_file).stem}.log"
        run_snowsql(cmd, log_path, shared_log_dir, f"SHARED {sql_file}")


def run_csv_pipeline(config):
    csv_script_dir = Path(config['paths']['csv_scripts'])
    csv_log_dir = Path(config['paths']['csv_logs']) / \
                  f"load_{pd.Timestamp.now().strftime('%Y%m%d_%H%M')}"
    
    print("📁 Loading CSV Pipeline...")
    for sql_file in CSV_SQL_FILES:
        cmd = get_csv_snowsql_cmd(sql_file, csv_script_dir, config)
        log_path = csv_log_dir / f"{Path(sql_file).stem}.log"
        run_snowsql(cmd, log_path, csv_log_dir, f"CSV {sql_file}")
    
    print(f"All CSV tables bronze-loaded! Logs: {csv_log_dir}")
    subprocess.Popen(["explorer", str(csv_log_dir)])


def run_json_pipeline(config):
    json_script_dir = Path(config['paths']['json_scripts'])
    json_log_dir = Path(config['paths']['json_logs']) / \
                   f"load_{pd.Timestamp.now().strftime('%Y%m%d_%H%M')}"
    json_log_dir.mkdir(parents=True, exist_ok=True)
    
    print("🚀 Starting JSON Bronze Pipeline...")
    for sql_file_info in JSON_SQL_FILES:
        sql_file, schema = sql_file_info
        log_path = json_log_dir / f"{Path(sql_file).stem}.log"
        
        cmd = get_json_snowsql_cmd(sql_file, json_script_dir, config)
        label = f"JSON {schema} {sql_file}"
        run_snowsql(cmd, log_path, json_log_dir, label)
    
    print(f"\n🎉 JSON BRONZE PIPELINE COMPLETE! Logs: {json_log_dir}")
    subprocess.Popen(["explorer", str(json_log_dir)])


def main():
    parser = argparse.ArgumentParser(description="Load Healthcare CSV/JSON to Snowflake")
    parser.add_argument("--config", default="config.yaml", help="Config file")
    args = parser.parse_args()
    
    with open(args.config) as f:
        config = yaml.safe_load(f)
    
    run_shared_pipeline(config)
    run_csv_pipeline(config)
    run_json_pipeline(config)
    print("🎊 FULL PIPELINE COMPLETE!")


if __name__ == "__main__":
    main()
