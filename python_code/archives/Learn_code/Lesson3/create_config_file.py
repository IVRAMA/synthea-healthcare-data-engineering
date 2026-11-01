import datetime
import yaml
import subprocess
from pathlib import Path
import os

    
def create_config_file(connection_name):
    backup_config_file()
    # Load the Snowflake account information from the YAML file
    with open("snowflake_account.yaml", "r") as yaml_file:
        config = yaml.safe_load(yaml_file)
        config_file_location = Path(config['config_file_location']['windows_path'])
        # snowflake_account_conn = config['snowflake_account']['ACCOUNT_ROLE_CONN']
        snowflake_account_conn = connection_name
        snowflake_account_code = config['snowflake_account']['account']
        snowflake_user = config['snowflake_account']['user']
        snowflake_region = config['snowflake_account']['region']
        snowflake_warehouse = config['snowflake_account']['warehouse']
        snowflake_role = config['snowflake_account']['role']
        snowflake_authenticator = config['snowflake_account']['authenticator']
        HCB_DATABASE = config['snowflake_account']['HCB_DATABASE']
        HCB_SCHEMA = config['snowflake_account']['HCB_SCHEMA']
        HJB_DATABASE = config['snowflake_account']['HJB_DATABASE']
        HJB_SCHEMA = config['snowflake_account']['HJB_SCHEMA']
        HDB_DATABASE = config['snowflake_account']['HDB_DATABASE']
        HDB_SCHEMA = config['snowflake_account']['HDB_SCHEMA']  
    database_name = None
    schema_name = None
    if connection_name == "HEALTHCARE_CSV_RAW_CONN":
        database_name = HCB_DATABASE
    elif connection_name == "HEALTHCARE_JSON_RAW_CONN":
        database_name = HJB_DATABASE
    elif connection_name == "HEALTHCARE_JSON_BRONZE_CONN":
        database_name = HDB_DATABASE
    else:
        database_name = None

    if connection_name == "HEALTHCARE_CSV_RAW_CONN":
        schema_name = HCB_SCHEMA
    elif connection_name == "HEALTHCARE_JSON_RAW_CONN":
        schema_name = HJB_SCHEMA
    elif connection_name == "HEALTHCARE_JSON_BRONZE_CONN":
        schema_name = HDB_SCHEMA
    else:
        schema_name = None

    if database_name is None:
        database_schema = "# database and schema are not defined for this connection"
    else:
        database_schema = f"""database = {database_name}
schema = {schema_name}"""
# Create the configuration file content
    config_content = f"""
[connections.{snowflake_account_conn}]
account = {snowflake_account_code}
user = {snowflake_user}
password = {config['snowflake_account']['password']}
host = {config['snowflake_account']['host']}
region = {snowflake_region}
warehouse = {snowflake_warehouse}
role = {snowflake_role}
authenticator = {snowflake_authenticator}
{database_schema}
"""

    with open("c:\\Users\\MY-PC\\.snowsql\\config", "w") as config_file:
        config_file.write(config_content)
    print("new configuration file created.")

def backup_config_file():
    file_Date = datetime.date.today().strftime("%Y%m%d")    
    print("renaming configuration file...")
    subprocess.run("ren c:\\Users\\MY-PC\\.snowsql\\config config" + file_Date, shell=True)
    print("creating new configuration file...")
    subprocess.run("type nul > c:\\Users\\MY-PC\\.snowsql\\config", shell=True)
