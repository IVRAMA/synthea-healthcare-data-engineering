#!/usr/bin/env python3
"""One-time CSV bronze load: 17 Synthea tables → Snowflake."""
import subprocess
from pathlib import Path
import sys
import pandas as pd  # Timestamp
import yaml

CSV_SQL_FILES = [
    "01_setup_databases.sql",
    "02_Create_stages.sql",
    "03_snowsql_put_commands.sql",
    "04_Create_tables.sql",
    "05_Copy_data_stage_to_table.sql",
    "06_Stored_procedure_for_Meta_Data.sql",
    "07_infer_column_datatype.sql"
]

def main():
    # Load config
    with open("config.yaml") as f:
        config = yaml.safe_load(f)
    
    csv_script_dir = Path(r"C:\\dbt_projects\\healthcare_db\\csv_scripts")
    csv_log_dir = Path("C:\\dbt_projects\\healthcare_db\\csv_logs") / f"load_{pd.Timestamp.now().strftime('%Y%m%d_%H%M')}"
    csv_log_dir.mkdir(parents=True, exist_ok=True)
    
    for sql_file in CSV_SQL_FILES:
        log_path = csv_log_dir / f"{Path(sql_file).stem}.log"
        print(f"Loading {sql_file}...")
        cmd = [
            "snowsql",
            "--connection", "HEALTHCARE_CSV_RAW",
            "-w", config['wh'],
            "-f", str(csv_script_dir / sql_file),
            "-D", f"ACCOUNT_ROLE={config['account_role']}",
            "-D", f"DB_CSV={config['db_csv']}",
            "-D", f"SCHEMA_CSV={config['schema_csv']}",
            "-D", f"WH={config['wh']}"
        ]
        
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)

        # Full log always
        with open(log_path, "w") as f:
            f.write(result.stdout)
            if result.stderr:
                f.write("\nSTDERR:\n" + result.stderr)

        # Errors → subfolder
        error_dir = csv_log_dir / "errors"
        error_dir.mkdir(exist_ok=True)
        if result.returncode != 0 or result.stderr:
            error_path = error_dir / f"{Path(sql_file).stem}.error"
            with open(error_path, "w") as f:
                f.write(f"SQL: {sql_file}\nRETURN: {result.returncode}\n")
                if result.stderr: f.write("STDERR:\n" + result.stderr)
            print(f"❌ {sql_file} → {error_path}")
            sys.exit(1)
        print(f"✅ {sql_file} → {log_path}")

    print(f"All 17 tables bronze-loaded! Logs: {csv_log_dir}")
    subprocess.Popen(["explorer", str(csv_log_dir)])

if __name__ == "__main__":
    main()
