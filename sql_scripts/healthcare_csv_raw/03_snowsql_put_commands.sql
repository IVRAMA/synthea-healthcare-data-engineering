snowsql --connection=HEALTHCARE_CSV_RAW



PUT file://C:/dbt_projects/healthcare_db/csvs/allergies.csv  @HEALTHCARE_CSV_RAW.BRONZE.stage_allergies AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/csvs/careplans.csv  @HEALTHCARE_CSV_RAW.BRONZE.stage_careplans AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/csvs/claims.csv  @HEALTHCARE_CSV_RAW.BRONZE.stage_claims AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/csvs/claims_transactions.csv  @HEALTHCARE_CSV_RAW.BRONZE.stage_claims_transactions AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/csvs/conditions.csv  @HEALTHCARE_CSV_RAW.BRONZE.stage_conditions AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/csvs/devices.csv  @HEALTHCARE_CSV_RAW.BRONZE.stage_devices AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/csvs/encounters.csv  @HEALTHCARE_CSV_RAW.BRONZE.stage_encounters AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/csvs/imaging_studies.csv  @HEALTHCARE_CSV_RAW.BRONZE.stage_imaging_studies AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/csvs/immunizations.csv  @HEALTHCARE_CSV_RAW.BRONZE.stage_immunizations AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/csvs/medications.csv  @HEALTHCARE_CSV_RAW.BRONZE.stage_medications AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/csvs/observations.csv  @HEALTHCARE_CSV_RAW.BRONZE.stage_observations AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/csvs/organizations.csv  @HEALTHCARE_CSV_RAW.BRONZE.stage_organizations AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/csvs/patients.csv  @HEALTHCARE_CSV_RAW.BRONZE.stage_patients AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/csvs/payer_transitions.csv  @HEALTHCARE_CSV_RAW.BRONZE.stage_payer_transitions AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/csvs/payers.csv  @HEALTHCARE_CSV_RAW.BRONZE.stage_payers AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/csvs/procedures.csv  @HEALTHCARE_CSV_RAW.BRONZE.stage_procedures AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/csvs/providers.csv  @HEALTHCARE_CSV_RAW.BRONZE.stage_providers AUTO_COMPRESS=TRUE;

PUT file://C:/dbt_projects/healthcare_db/csvs/supplies.csv  @HEALTHCARE_CSV_RAW.BRONZE.stage_supplies AUTO_COMPRESS=TRUE;
