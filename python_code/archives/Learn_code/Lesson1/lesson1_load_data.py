import subprocess
import os
from pathlib import Path

def access_sql_scripts():
    current_folder = Path(__file__).parent
    sql_folder = current_folder.parent.parent / "sql_scripts"
    return sql_folder

def run_snowsql_commands(script_dir):
    print(subprocess.run(["dir", script_dir], shell=True, capture_output=True, text=True).stdout)
    cmd = [
        "snowsql",
        "--connection", "HEALTHCARE_CSV_RAW",
        "-f", str(script_dir / "00_clean_setup.sql")
    ]
    print(subprocess.run(cmd, shell=True, capture_output=True, text=True).stdout)
    # print(subprocess.run (["snowsql", "--version"], shell=True, capture_output=True, text=True).stdout)

def main():
    print("Starting ingestion...")
    sql_folder = access_sql_scripts()
    run_snowsql_commands(sql_folder)


if __name__ == "__main__":
    main()