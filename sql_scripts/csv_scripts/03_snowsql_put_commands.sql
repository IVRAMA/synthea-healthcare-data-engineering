PUT file://D:/dbt_projects/healthcare_db/csvs/allergies.csv  @stage_allergies AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/csvs/careplans.csv  @stage_careplans AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/csvs/claims.csv  @stage_claims AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/csvs/claims_transactions.csv  @stage_claims_transactions AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/csvs/conditions.csv  @stage_conditions AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/csvs/devices.csv  @stage_devices AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/csvs/encounters.csv  @stage_encounters AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/csvs/imaging_studies.csv  @stage_imaging_studies AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/csvs/immunizations.csv  @stage_immunizations AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/csvs/medications.csv  @stage_medications AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/csvs/observations.csv  @stage_observations AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/csvs/organizations.csv  @stage_organizations AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/csvs/patients.csv  @stage_patients AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/csvs/payer_transitions.csv  @stage_payer_transitions AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/csvs/payers.csv  @stage_payers AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/csvs/procedures.csv  @stage_procedures AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/csvs/providers.csv  @stage_providers AUTO_COMPRESS=TRUE;

PUT file://D:/dbt_projects/healthcare_db/csvs/supplies.csv  @stage_supplies AUTO_COMPRESS=TRUE;
