import json
import pandas as pd
import os

file_path = r'C:\dbt_projects\healthcare_db\pat1.json'

# Read raw JSON
with open(file_path, 'r') as f:
    data = json.load(f)

print("Raw data keys:", data.keys())  # Check structure (e.g., FHIR Patient resource)

# Normalize to DataFrame (handles nested Synthea/FHIR JSON)
df = pd.json_normalize(data)
print(df.head())
print("Shape:", df.shape)

# Save flattened CSV for Snowflake/Google export test
df.to_csv('pat1_flattened.csv', index=False)
print("Saved to pat1_flattened.csv")
