import yaml
import snowflake.connector
import pandas as pd
from pathlib import Path

def load_config(config_file="config_python.yaml"):
    with open(config_file, "r") as f:
        return yaml.safe_load(f)

def get_connection(config):
    sf = config["snowflake"]
    print(sf)
    return snowflake.connector.connect(
        account=sf["account"],
        user=sf["user"],
        password=sf["password"],
        warehouse=sf["warehouse"],
        role=sf["role"]
    )

def create_database_and_schema(cur, db_name, schema_name):
    cur.execute(f"CREATE DATABASE IF NOT EXISTS {db_name}")
    cur.execute(f"USE DATABASE {db_name}")
    cur.execute(f"CREATE SCHEMA IF NOT EXISTS {schema_name}")
    cur.execute(f"USE SCHEMA {schema_name}")
    print(f"✅ Using {db_name}.{schema_name}")

def get_csv_files(csv_dir):
    return list(Path(csv_dir).glob("*.csv"))

def create_table_from_csv_header(cur, csv_file, schema_name):
    table_name = csv_file.stem.upper()
    df = pd.read_csv(csv_file, nrows=0)
    columns = df.columns.tolist()
    columns_with_types = ", ".join([f'"{col}" VARCHAR(16777216)' for col in columns])

    sql = f'''
    CREATE TABLE IF NOT EXISTS {schema_name}.{table_name} (
        {columns_with_types}
    )
    '''
    cur.execute(sql)
    print(f"✅ Created table: {schema_name}.{table_name}")
    return(f"{table_name}")
    
def load_csv_to_table(cur, csv_file, table_name, schema_name):
    stage_name = "CSV_STAGE"

    cur.execute(f"CREATE STAGE IF NOT EXISTS {schema_name}.{stage_name}")

    local_path = str(csv_file).replace("\\", "/")

    cur.execute(
        f"PUT 'file://{local_path}' @{schema_name}.{stage_name} AUTO_COMPRESS=TRUE OVERWRITE=TRUE"
    )

    cur.execute(f"""
        COPY INTO {schema_name}.{table_name}
        FROM @{schema_name}.{stage_name}
        FILES = ('{csv_file.name}.gz')
        FILE_FORMAT = (
            TYPE = CSV
            SKIP_HEADER = 1
            FIELD_OPTIONALLY_ENCLOSED_BY = '\"'
        )
        ON_ERROR = 'CONTINUE'
    """)

    print(f"✅ Loaded {csv_file.name} into {schema_name}.{table_name}")

def infer_table_and_columns(cur, table_name, schema_name):
    # 1. Create preview table
    cur.execute(f"""
        CREATE TABLE IF NOT EXISTS {schema_name}.TABLE_COLUMN_PREVIEW (
            TABLE_NAME VARCHAR,
            COLUMN_NAME VARCHAR,
            ORDINAL_POSITION INT,
            DATA1 VARCHAR, DATA2 VARCHAR, DATA3 VARCHAR, DATA4 VARCHAR,
            DATA5 VARCHAR, DATA6 VARCHAR, DATA7 VARCHAR, DATA8 VARCHAR,
            DATA9 VARCHAR, DATA10 VARCHAR
        )
    """)

    # 2. Get columns
    cur.execute(f"""
        SELECT COLUMN_NAME, ORDINAL_POSITION 
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_NAME = '{table_name}' 
        AND TABLE_SCHEMA = '{schema_name}' 
        ORDER BY ORDINAL_POSITION
    """)
    columns = cur.fetchall()

    # 3. For each column, get first 5 non-null rows
    for col_name, ordinal_pos in columns:
        cur.execute(f"""
            SELECT DATA_VALUE FROM (
                SELECT IDENTIFIER('\"{col_name}\"') as DATA_VALUE
                FROM {schema_name}.{table_name} 
                WHERE IDENTIFIER('\"{col_name}\"') IS NOT NULL
                ORDER BY IDENTIFIER('\"{col_name}\"')
                LIMIT 10
            )
        """)
        sample_data = [row[0] or '' for row in cur.fetchall()]
        padded_data = sample_data + [''] * (10 - len(sample_data))

        # 4. Insert into preview table
        data1, data2, data3, data4, data5, data6, data7, data8, data9, data10  = padded_data
        insert_sql = f"""
            INSERT INTO {schema_name}.TABLE_COLUMN_PREVIEW
            (
                TABLE_NAME, COLUMN_NAME, ORDINAL_POSITION,
                DATA1, DATA2, DATA3, DATA4, DATA5,
                DATA6, DATA7, DATA8, DATA9, DATA10
            )
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cur.execute(
            insert_sql,
            (
                table_name,
                col_name,
                ordinal_pos,
                data1, data2, data3, data4, data5,
                data6, data7, data8, data9, data10
            )
        )
        # print(f"✅ Previewed {col_name}")

    print(f"✅ Preview complete for {table_name}")

def infer_datatypes(cur, schema_name):
    cur.execute(f"""
        CREATE OR REPLACE TABLE {schema_name}.INFERRED_COLUMN_TYPES AS
        SELECT
            table_name,
            column_name,
            ordinal_position,
            CASE
                WHEN COALESCE(REGEXP_LIKE(data1, '^-?[0-9]+$'), TRUE)
                 AND COALESCE(REGEXP_LIKE(data2, '^-?[0-9]+$'), TRUE)
                 AND COALESCE(REGEXP_LIKE(data3, '^-?[0-9]+$'), TRUE)
                 AND COALESCE(REGEXP_LIKE(data4, '^-?[0-9]+$'), TRUE)
                 AND COALESCE(REGEXP_LIKE(data5, '^-?[0-9]+$'), TRUE)
                THEN 'NUMBER'

                WHEN COALESCE(REGEXP_LIKE(data1, '^-?[0-9]+(\\.[0-9]+)?([eE]-?[0-9]+)?$'), TRUE)
                 AND COALESCE(REGEXP_LIKE(data2, '^-?[0-9]+(\\.[0-9]+)?([eE]-?[0-9]+)?$'), TRUE)
                 AND COALESCE(REGEXP_LIKE(data3, '^-?[0-9]+(\\.[0-9]+)?([eE]-?[0-9]+)?$'), TRUE)
                 AND COALESCE(REGEXP_LIKE(data4, '^-?[0-9]+(\\.[0-9]+)?([eE]-?[0-9]+)?$'), TRUE)
                 AND COALESCE(REGEXP_LIKE(data5, '^-?[0-9]+(\\.[0-9]+)?([eE]-?[0-9]+)?$'), TRUE)
                THEN 'FLOAT'

                WHEN COALESCE(REGEXP_LIKE(data1, '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'), TRUE)
                 AND COALESCE(REGEXP_LIKE(data2, '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'), TRUE)
                 AND COALESCE(REGEXP_LIKE(data3, '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'), TRUE)
                 AND COALESCE(REGEXP_LIKE(data4, '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'), TRUE)
                 AND COALESCE(REGEXP_LIKE(data5, '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'), TRUE)
                THEN 'DATE'

                WHEN COALESCE(REGEXP_LIKE(data1, '^[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}:[0-9]{2}(\\.[0-9]+)?Z?$', 'i'), TRUE)
                 AND COALESCE(REGEXP_LIKE(data2, '^[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}:[0-9]{2}(\\.[0-9]+)?Z?$', 'i'), TRUE)
                 AND COALESCE(REGEXP_LIKE(data3, '^[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}:[0-9]{2}(\\.[0-9]+)?Z?$', 'i'), TRUE)
                 AND COALESCE(REGEXP_LIKE(data4, '^[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}:[0-9]{2}(\\.[0-9]+)?Z?$', 'i'), TRUE)
                 AND COALESCE(REGEXP_LIKE(data5, '^[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}:[0-9]{2}(\\.[0-9]+)?Z?$', 'i'), TRUE)
                THEN 'TIMESTAMP_NTZ'

                WHEN COALESCE(REGEXP_LIKE(data1, '^(true|false|t|f|yes|no|y|n|on|off|0|1)$', 'i'), TRUE)
                 AND COALESCE(REGEXP_LIKE(data2, '^(true|false|t|f|yes|no|y|n|on|off|0|1)$', 'i'), TRUE)
                 AND COALESCE(REGEXP_LIKE(data3, '^(true|false|t|f|yes|no|y|n|on|off|0|1)$', 'i'), TRUE)
                 AND COALESCE(REGEXP_LIKE(data4, '^(true|false|t|f|yes|no|y|n|on|off|0|1)$', 'i'), TRUE)
                 AND COALESCE(REGEXP_LIKE(data5, '^(true|false|t|f|yes|no|y|n|on|off|0|1)$', 'i'), TRUE)
                THEN 'BOOLEAN'
                
                WHEN TRY_TO_DATE(data1, 'MM/DD/YYYY') IS NOT NULL
                    AND TRY_TO_DATE(data2, 'MM/DD/YYYY') IS NOT NULL
                    AND TRY_TO_DATE(data3, 'MM/DD/YYYY') IS NOT NULL
                    AND TRY_TO_DATE(data4, 'MM/DD/YYYY') IS NOT NULL
                    AND TRY_TO_DATE(data5, 'MM/DD/YYYY') IS NOT NULL
                THEN 'DATE'
                
                WHEN TRY_TO_DATE(data1, 'YYYY/MM/DD') IS NOT NULL
                    AND TRY_TO_DATE(data2, 'YYYY/MM/DD') IS NOT NULL
                    AND TRY_TO_DATE(data3, 'YYYY/MM/DD') IS NOT NULL
                    AND TRY_TO_DATE(data4, 'YYYY/MM/DD') IS NOT NULL
                    AND TRY_TO_DATE(data5, 'YYYY/MM/DD') IS NOT NULL
                THEN 'DATE'
                WHEN TRY_TO_DATE(data1, 'YYYY-MM-DD') IS NOT NULL
                    AND TRY_TO_DATE(data2, 'YYYY-MM-DD') IS NOT NULL
                    AND TRY_TO_DATE(data3, 'YYYY-MM-DD') IS NOT NULL
                    AND TRY_TO_DATE(data4, 'YYYY-MM-DD') IS NOT NULL
                    AND TRY_TO_DATE(data5, 'YYYY-MM-DD') IS NOT NULL
                THEN 'DATE'
                WHEN TRY_TO_TIMESTAMP(data1) IS NOT NULL
                    AND TRY_TO_DATE(data2) IS NOT NULL
                    AND TRY_TO_DATE(data3) IS NOT NULL
                    AND TRY_TO_DATE(data4) IS NOT NULL
                    AND TRY_TO_DATE(data5) IS NOT NULL
                THEN 'TIMESTAMP_NTZ'
                WHEN COALESCE(REGEXP_LIKE(data1, '^([0-9]{4}-[0-9]{2}-[0-9]{2}|[0-9]{2}/[0-9]{2}/[0-9]{4})$'), TRUE)
                AND COALESCE(REGEXP_LIKE(data2, '^([0-9]{4}-[0-9]{2}-[0-9]{2}|[0-9]{2}/[0-9]{2}/[0-9]{4})$'), TRUE)
                AND COALESCE(REGEXP_LIKE(data3, '^([0-9]{4}-[0-9]{2}-[0-9]{2}|[0-9]{2}/[0-9]{2}/[0-9]{4})$'), TRUE)
                AND COALESCE(REGEXP_LIKE(data4, '^([0-9]{4}-[0-9]{2}-[0-9]{2}|[0-9]{2}/[0-9]{2}/[0-9]{4})$'), TRUE)
                AND COALESCE(REGEXP_LIKE(data5, '^([0-9]{4}-[0-9]{2}-[0-9]{2}|[0-9]{2}/[0-9]{2}/[0-9]{4})$'), TRUE)
                THEN 'DATE'

                ELSE 'VARCHAR'
            END AS inferred_datatype,
            data1, data2, data3, data4, data5
        FROM {schema_name}.TABLE_COLUMN_PREVIEW
        QUALIFY ROW_NUMBER() OVER (
            PARTITION BY table_name, column_name
            ORDER BY ordinal_position
        ) = 1
        ORDER BY table_name, ordinal_position
    """)
    print("✅ Generated INFERRED_COLUMN_TYPES table")

def main():
    config = load_config()

    db_name = config["pipeline"]["csv_database"]
    schema_name = config["pipeline"]["csv_schema"]
    csv_dir = config["paths"]["csv_dir"]

    conn = get_connection(config)
    cur = conn.cursor()

    try:
        create_database_and_schema(cur, db_name, schema_name)
        csv_files = get_csv_files(csv_dir)
        for csv_file in csv_files:
            print(f"Processing {csv_file.name}...")
            table_name = create_table_from_csv_header(cur, csv_file, schema_name)
            load_csv_to_table(cur, csv_file, table_name, schema_name)
            infer_table_and_columns(cur, table_name, schema_name)
        infer_datatypes(cur, schema_name)
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    main()