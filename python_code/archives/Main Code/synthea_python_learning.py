## this program is a simple example of how to use the Synthea Python library to generate synthetic patient data. 
## demonstrates how to create a patient, add some basic demographic information, and generate a synthetic medical record for that patient. 

import yaml
from pathlib import Path
import subprocess

print("Starting Synthea Python Learning Example...")

def run_pipeline(pipeline_name):
    print(f"Running pipeline: {pipeline_name}")


run_pipeline("json")

with open("tiny.yaml", "r") as yaml_file:
    config = yaml.safe_load(yaml_file)
    print(f"Loaded configuration: {config}")

    print(f"Type of config: {type(config)}")
    print(f"Keys in config: {config.keys()}\n")

    print(f"Type of config['pipeline']: {type(config['pipeline'])}")
    print(f"Keys in pipeline: {config['pipeline'].keys()} \n")
counter = 0
script_dir = Path(config['paths']['csv_scripts'])
for file in script_dir.iterdir():
    print(file.name)
    # print(file.read_text())
    # print(file.open().read())
    if file.suffix == ".sql":
        counter += 1
print(f"Total SQL scripts found: {counter}")
print(subprocess.run(["dir", script_dir], shell=True, capture_output=True, text=True).stdout)