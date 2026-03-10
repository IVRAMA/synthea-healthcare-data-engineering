#!/usr/bin/env python3
"""One-time CSV bronze load: 17 Synthea tables → Snowflake."""
import subprocess
from pathlib import Path
import sys
import pandas as pd  # Timestamp

SQL_FILES = [
    "01_setup_databases.sql",
    "02_Create_stages.sql",
    "03_snowsql_put_commands.sql",
    "04_Create_tables.sql",
    "05_Copy_data_stage_to_table.sql",
    "06_Stored_procedure_for_Meta_Data.sql",
    "07_infer_column_datatype.sql"
]

def main():
    script_dir = Path(r"C:\dbt_projects\healthcare_db\csv_scripts")
    log_dir = Path("C:\dbt_projects\healthcare_db\csv_logs") / f"load_{pd.Timestamp.now().strftime('%Y%m%d_%H%M')}"
    log_dir.mkdir(parents=True, exist_ok=True)
    
    for sql_file in SQL_FILES:  # Loop each file
        log_path = log_dir / f"{Path(sql_file).stem}.log"
        print(f"Loading {sql_file}...")
        
        # 3.6 compat: stdout + stderr
        result = subprocess.run([ # Run snowsql command
            "snowsql", "--connection", "HEALTHCARE_CSV_RAW", 
            "-w", "TRANSFORMING", "-f", str(script_dir / sql_file)
        ], stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True) # Capture output
        
        with open(log_path, "w") as f: # Save stdout to log
            f.write(result.stdout)
            if result.stderr:
                f.write("\nSTDERR:\n" + result.stderr)
        
        if result.returncode != 0: # Check exit code
            print(f"❌ {sql_file} failed. See {log_path}")
            sys.exit(1) # Fail fast
        print(f"✅ {sql_file} → {log_path}") # Success!
    
    print(f"All 17 tables bronze-loaded! Logs: {log_dir}")
    subprocess.Popen(["explorer", str(log_dir)])

if __name__ == "__main__":
    main()