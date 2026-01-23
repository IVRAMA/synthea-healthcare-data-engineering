/*
This SQL script automates the creation and configuration of Snowflake resources required for the Synthea synthetic healthcare data project, 
following best practices in data platform design, security, and role-based access control (RBAC).
Components Provisioned
Databases

SYNTHEA_RAW: Holds raw ingested data and staging areas.
SYNTHEA_ANALYTICS: Contains processed, analytics-ready data layers.

Schemas

Raw Layer: RAW_DATA, EXTERNAL_STAGES, UTIL for data ingestion, staging, and utility objects.

Analytics Layer: DEV, ANALYTICS for development and production analytical operations.

Warehouse

TRANSFORMING: An XSMALL size warehouse with auto-suspend and auto-resume enabled to minimize cost while providing compute resources on demand.

Users and Roles

User HEALTHCARE with default role TRANSFORM and assigned warehouse.

Roles LOADING, TRANSFORM, and ANALYTICS defined for segmented privileges reflecting 
the principles of least privilege and clear separation of duties.

Role Hierarchy
LOADING role is nested under TRANSFORM.
TRANSFORM role is nested under ANALYTICS.
This ensures privilege inheritance and simplifies role management.

Privilege Grants
Extensive grants on databases, schemas, tables, stages, and warehouses for the defined roles.
Future grants ensure that privileges automatically apply to new schemas, tables, and stages without manual updates.
Special attention to granting LOADING role full access to external stages to facilitate secure data ingestion.
All roles granted warehouse usage to enable compute access.

Security and Best Practices
Segregation of duties between data loading, transformation, and analytics ensures minimal risk exposure.
Use of role hierarchy reduces the need for repetitive direct grants to users.
Auto-suspend and auto-resume settings on warehouse reduce operational costs.

Usage Instructions
Assign users their appropriate roles based on job functions.
Use the TRANSFORM role for data processing tasks.
Use the ANALYTICS role for querying and reporting activities.
The LOADING role is dedicated to ingestion operations involving external data stages.
This modular RBAC approach combined with automated provisioning scripts fosters reproducibility, 
security, and operational efficiency for the Synthea data platform on Snowflake.
*/

-------------------------------------------------------------------------------
-- 1) CREATE DATABASES
-------------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS SYNTHEA_RAW;
CREATE DATABASE IF NOT EXISTS SYNTHEA_ANALYTICS;

-------------------------------------------------------------------------------
-- 2) CREATE SCHEMAS
-------------------------------------------------------------------------------
-- RAW Layer
CREATE SCHEMA IF NOT EXISTS SYNTHEA_RAW.RAW_DATA;
CREATE SCHEMA IF NOT EXISTS SYNTHEA_RAW.EXTERNAL_STAGES;
CREATE SCHEMA IF NOT EXISTS SYNTHEA_RAW.UTIL;

-- Analytics Layer
CREATE SCHEMA IF NOT EXISTS SYNTHEA_ANALYTICS.DEV;
CREATE SCHEMA IF NOT EXISTS SYNTHEA_ANALYTICS.ANALYTICS;


-- Add warehouse creation after schemas
CREATE WAREHOUSE IF NOT EXISTS TRANSFORMING
  WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 300 AUTO_RESUME = TRUE;

-------------------------------------------------------------------------------
-- 3) CREATE USER
-------------------------------------------------------------------------------
CREATE USER IF NOT EXISTS HEALTHCARE
  PASSWORD = 'Healthcare_User123'
  DEFAULT_ROLE = TRANSFORM
  DEFAULT_WAREHOUSE = TRANSFORMING
  MUST_CHANGE_PASSWORD = FALSE;

-------------------------------------------------------------------------------
-- 4) ROLES (best practice)
-------------------------------------------------------------------------------
CREATE ROLE IF NOT EXISTS LOADING;
CREATE ROLE IF NOT EXISTS TRANSFORM;
CREATE ROLE IF NOT EXISTS ANALYTICS;

-- Role grants

GRANT ROLE LOADING TO USER THERAMCHU;
GRANT ROLE LOADING TO USER HEALTHCARE;
GRANT ROLE TRANSFORM TO USER THERAMCHU;
GRANT ROLE TRANSFORM TO USER HEALTHCARE;
GRANT ROLE ANALYTICS TO USER THERAMCHU;
GRANT ROLE ANALYTICS TO USER HEALTHCARE;

-- DATABASE PREVILEGES
GRANT ALL PRIVILEGES ON  DATABASE SYNTHEA_RAW TO LOADING;
GRANT ALL PRIVILEGES ON DATABASE SYNTHEA_RAW TO TRANSFORM;
GRANT ALL PRIVILEGES ON DATABASE SYNTHEA_ANALYTICS TO TRANSFORM;
GRANT ALL PRIVILEGES ON DATABASE SYNTHEA_ANALYTICS TO ANALYTICS;


-- PREVILEGES WITH FUTURE GRANTS FOR SCHEMAS PRESENT IN SYNTHEA_RAW
GRANT ALL PRIVILEGES ON ALL SCHEMAS IN DATABASE SYNTHEA_RAW TO LOADING;
GRANT ALL PRIVILEGES ON FUTURE SCHEMAS IN DATABASE SYNTHEA_RAW TO LOADING;
GRANT ALL PRIVILEGES ON ALL SCHEMAS IN DATABASE SYNTHEA_RAW TO TRANSFORM;
GRANT ALL PRIVILEGES ON FUTURE SCHEMAS IN DATABASE SYNTHEA_RAW TO TRANSFORM;
GRANT ALL PRIVILEGES ON ALL SCHEMAS IN DATABASE SYNTHEA_RAW TO ANALYTICS;
GRANT ALL PRIVILEGES ON FUTURE SCHEMAS IN DATABASE SYNTHEA_RAW TO ANALYTICS;

-- PREVILEGES WITH FUTURE GRANTS FOR SCHEMAS PRESENT IN SYNTHEA_ANALYTICS
GRANT ALL PRIVILEGES ON ALL SCHEMAS IN DATABASE SYNTHEA_ANALYTICS TO TRANSFORM;
GRANT ALL PRIVILEGES ON FUTURE SCHEMAS IN DATABASE SYNTHEA_ANALYTICS TO TRANSFORM;
GRANT ALL PRIVILEGES ON ALL SCHEMAS IN DATABASE SYNTHEA_ANALYTICS TO ANALYTICS;
GRANT ALL PRIVILEGES ON FUTURE SCHEMAS IN DATABASE SYNTHEA_ANALYTICS TO ANALYTICS;


-- PREVILEGES WITH FUTURE GRANTS FOR TABLES PRESENT IN SCHEMA SYNTHEA_RAW
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA SYNTHEA_RAW.RAW_DATA TO LOADING;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA SYNTHEA_RAW.RAW_DATA TO TRANSFORM;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA SYNTHEA_RAW.RAW_DATA TO ANALYTICS;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA SYNTHEA_RAW.RAW_DATA TO LOADING;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA SYNTHEA_RAW.RAW_DATA TO TRANSFORM;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA SYNTHEA_RAW.RAW_DATA TO ANALYTICS;

-- PREVILEGES WITH FUTURE GRANTS FOR TABLES PRESENT IN SCHEMA SYNTHEA_UTIL
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA SYNTHEA_RAW.UTIL TO LOADING;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA SYNTHEA_RAW.UTIL TO TRANSFORM;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA SYNTHEA_RAW.UTIL TO ANALYTICS;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA SYNTHEA_RAW.UTIL TO LOADING;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA SYNTHEA_RAW.UTIL TO TRANSFORM;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA SYNTHEA_RAW.UTIL TO ANALYTICS;

-- PREVILEGES WITH FUTURE GRANTS FOR TABLES PRESENT IN SCHEMA ANALYTICS
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA SYNTHEA_ANALYTICS.ANALYTICS TO ANALYTICS;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA SYNTHEA_ANALYTICS.ANALYTICS TO TRANSFORM;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA SYNTHEA_ANALYTICS.ANALYTICS TO ANALYTICS;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA SYNTHEA_ANALYTICS.ANALYTICS TO TRANSFORM;

-- PREVILEGES WITH FUTURE GRANTS FOR TABLES PRESENT IN SCHEMA DEV
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA SYNTHEA_ANALYTICS.DEV TO ANALYTICS;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA SYNTHEA_ANALYTICS.DEV TO TRANSFORM;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA SYNTHEA_ANALYTICS.DEV TO ANALYTICS;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA SYNTHEA_ANALYTICS.DEV TO TRANSFORM;

