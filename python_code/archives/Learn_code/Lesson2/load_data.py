import yaml
from pathlib import Path
import subprocess
import datetime


def access_config_file():
    with open("snowflake_account.yaml", "r") as yaml_file:
        config = yaml.safe_load(yaml_file)
        # print(f"Loaded configuration: {config}")
        config_file = Path(config['file_location']['windows_path'])
        print(config_file.name)
        # print(config_file.read_text())

def check_snowflake_account():

    with open("snowflake_account.yaml", "r") as yaml_file:
        config = yaml.safe_load(yaml_file)

        config_file = Path(config['file_location']['windows_path'])
        account = Path(config['snowflake_account']['account'])

        print(f"Snowflake account Code: {account}")

        print("comparing Snowflake account code with configuration file...")
        config_file_account_code = config_file.read_text().find(str(account))
        if config_file_account_code != -1:
            print("Snowflake account code matches the configuration file.")
        else:
            print("Snowflake account code does not match the configuration file.")
            print("taking backup of configuration file...")
            create_config_file()

def create_config_file():
    file_Date = datetime.date.today().strftime("%Y%m%d")

    print("renaming configuration file...")
    subprocess.run("ren c:\\Users\\MY-PC\\.snowsql\\config config" + file_Date, shell=True)
    print("creating new configuration file...")
    subprocess.run("type nul > c:\\Users\\MY-PC\\.snowsql\\config", shell=True)
    write_config_file()

def write_config_file():

    config_content = """
[connections.ACCOUNT_ROLE_CONN]
account = "RFLZWAX-GP68998"
user = "HEALTHCARE"
password = "Healthcare_User123"
host = "RFLZWAX-GP68998.snowflakecomputing.com"
region = "AWS_AP_SOUTHEAST_7"
#database = "HCB"
#schema = "BRONZE"
warehouse = "TRANSFORMING"
role = "transform_role"
authenticator = "SNOWFLAKE"

[connections.HEALTHCARE_CSV_RAW]
account = "RFLZWAX-GP68998"
user = "HEALTHCARE"
password = "Healthcare_User123"
host = "RFLZWAX-GP68998.snowflakecomputing.com"
region = "AWS_AP_SOUTHEAST_7"
database = "HCB"
schema = "BRONZE"
warehouse = "TRANSFORMING"
role = "transform_role"
authenticator = "SNOWFLAKE"

[connections.HEALTHCARE_JSON_RAW]
account = "RFLZWAX-GP68998"
user = "HEALTHCARE"
password = "Healthcare_User123"
host = "RFLZWAX-GP68998.snowflakecomputing.com"
region = "AWS_AP_SOUTHEAST_7"
database = "HJB"
schema = "STAGING"
warehouse = "TRANSFORMING"
role = "transform_role"
authenticator = "SNOWFLAKE"

[connections.HEALTHCARE_JSON_BRONZE]
account = "RFLZWAX-GP68998"
user = "HEALTHCARE"
password = "Healthcare_User123"
host = "RFLZWAX-GP68998.snowflakecomputing.com"
region = "AWS_AP_SOUTHEAST_7"
database = "HJB"
schema = "BRONZE"
warehouse = "TRANSFORMING"
role = "transform_role"
authenticator = "SNOWFLAKE"
    """
    with open("c:\\Users\\MY-PC\\.snowsql\\config", "w") as config_file:
        config_file.write(config_content)
    print("new configuration file created.")

def main():
    print("accessing configuration file...")
    access_config_file()

    print("checking Snowflake account...")
    check_snowflake_account()

if __name__ == "__main__":
    main()