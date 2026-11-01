import yaml
import subprocess
import datetime
from pathlib import Path
import os
import sys

from create_config_file import create_config_file
# project_root = Path(__file__).parents[4]
# sys.path.append(str(project_root))



def check_snowflake_account():
    with open("snowflake_account.yaml", "r") as yaml_file:
        config = yaml.safe_load(yaml_file)
        config_file = Path(config['config_file_location']['windows_path'])

        snowflake_account_code = config['snowflake_account']['account']
        print(f"Snowflake account Code: {snowflake_account_code}")

        print("comparing Snowflake account code with configuration file...")
        config_file_account_code = config_file.read_text().find(str(snowflake_account_code))
        if config_file_account_code != -1:
            print("Snowflake account code matches the configuration file.")
        else:
            print("Snowflake account code does not match the configuration file.")
            print("taking backup of configuration file...")
            create_config_file("HEALTHCARE_CSV_RAW_CONN")

def main():
    print("********************************************************************************* " \
              "\n -- Synthea CSV Data loading program with Snowflake started... --" \
              "\n *********************************************************************************")
    print(os.getcwd())
    print(" -- Checking Snowflake account information... --" \
          "\n *********************************************************************************")
    check_snowflake_account()


if __name__ == "__main__":
    main()
