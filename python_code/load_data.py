#!/usr/bin/env python3
"""Run healthcare CSV + JSON pipelines via SnowSQL, driven by YAML config."""

import argparse
import subprocess
from pathlib import Path
import sys
import pandas as pd
import yaml


def load_yaml(path):
    with open(path) as f:
        return yaml.safe_load(f)


def get_snowsql_cmd(source, sql_file, script_dir, config, pipelines_cfg):
    """
    Build a SnowSQL command based on pipeline 'source'
    (shared / csv / json_staging / json_bronze / clean, etc.).
    """
    pipe = pipelines_cfg[source]

    connection = pipe.get("connection")
    dbname = pipe.get("dbname")
    schemaname = pipe.get("schemaname")

    cmd = ["snowsql", "--connection", connection]

    if dbname:
        cmd.extend(["-d", dbname])
    if schemaname:
        cmd.extend(["-s", schemaname])

    cmd.extend([
        "-w", config["wh"],
        "-f", str(script_dir / sql_file)
    ])

    # Common -D variables (extend if needed)
    common_vars = [
        ("ACCOUNT_ROLE", config["account_role"]),
        ("HCB_DB", config["db_csv"]),
        ("HJB_DB", config["db_json"]),
        ("WH", config["wh"])
    ]
    for key, val in common_vars:
        cmd.extend(["-D", f"{key}={val}"])

    return cmd


def run_snowsql(cmd, log_path, error_root, label):
    """Execute SnowSQL, write logs, and fail fast on error."""
    result = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True,
    )

    log_path.parent.mkdir(parents=True, exist_ok=True)
    with open(log_path, "w", encoding="utf-8") as f:
        f.write(result.stdout)
        if result.stderr:
            f.write("\n--- STDERR ---\n")
            f.write(result.stderr)

    if result.returncode != 0:
        error_dir = error_root / "errors"
        error_dir.mkdir(parents=True, exist_ok=True)
        error_path = error_dir / f"{log_path.stem}.error"
        with open(error_path, "w", encoding="utf-8") as f:
            f.write(f"LABEL: {label}\nRETURN: {result.returncode}\n")
            if result.stderr:
                f.write("STDERR:\n")
                f.write(result.stderr)
        print(f"❌ {label} → {error_path}")
        sys.exit(1)

    print(f"✅ {label} → {log_path}")


def run_pipeline(pipeline_name, config, pipelines_cfg, base_log_dir):
    """Generic runner for any pipeline defined in pipeline.yaml."""
    pipe = pipelines_cfg[pipeline_name]

    script_dir_key = pipe["script_dir"]          # e.g. csv_scripts / json_scripts / shared_scripts
    script_dir = Path(config["paths"][script_dir_key])

    timestamp = pd.Timestamp.now().strftime("%Y%m%d_%H%M")
    log_root = Path(base_log_dir) / pipeline_name / f"load_{timestamp}"

    sql_files = pipe["sql_files"]

    print(f"\n▶ Running pipeline: {pipeline_name}")
    for sql_file in sql_files:
        label = f"{pipeline_name} {sql_file}"
        log_path = log_root / f"{Path(sql_file).stem}.log"
        cmd = get_snowsql_cmd(pipeline_name, sql_file, script_dir, config, pipelines_cfg)
        run_snowsql(cmd, log_path, log_root, label)

    print(f"📂 Logs for {pipeline_name}: {log_root}")
    # Optional: open Explorer for each pipeline
    # subprocess.Popen(["explorer", str(log_root)])


def main():
    parser = argparse.ArgumentParser(description="Healthcare CSV/JSON loader via SnowSQL + YAML config")
    parser.add_argument(
        "--config",
        default="config.yaml",
        help="Path to config.yaml (DBs, paths, etc.)",
    )
    parser.add_argument(
        "--pipeline-config",
        default="pipeline.yaml",
        help="Path to pipeline.yaml (SQL lists, connections)",
    )
    parser.add_argument(
        "--clean",
        action="store_true",
        help="Run the 'clean' pipeline (if defined) before others",
    )
    args = parser.parse_args()

    config = load_yaml(args.config)
    pipelines_cfg = load_yaml(args.pipeline_config)["pipelines"]

    base_log_dir = config.get("paths", {}).get("logs_root", "D:\\dbt_projects\\healthcare_db\\logs")

    # Optional clean step
    if args.clean and "clean" in pipelines_cfg:
        run_pipeline("clean", config, pipelines_cfg, base_log_dir)

    # Core pipelines – adjust order as defined in your pipeline.yaml
    for name in ["shared", "csv", "json_loading", "json_staging"]:
        if name in pipelines_cfg:
            run_pipeline(name, config, pipelines_cfg, base_log_dir)

    print("\n🎊 FULL PIPELINE COMPLETE!")


if __name__ == "__main__":
    main()