CREATE  OR REPLACE TABLE SYNTHEA_RAW.RAW_DATA.AllergyIntolerance(
PATIENT_ID VARCHAR(16777216) ,
"category" ARRAY,
"clinicalStatus" OBJECT,
"code" OBJECT,
"criticality" VARCHAR,
"id" VARCHAR,
"patient" OBJECT,
"recordedDate" VARCHAR,
"resourceType" VARCHAR,
"type" VARCHAR,
"verificationStatus" OBJECT);
CREATE  OR REPLACE TABLE SYNTHEA_RAW.RAW_DATA.CarePlan(
PATIENT_ID VARCHAR(16777216) ,
"activity" ARRAY,
"addresses" ARRAY,
"category" ARRAY,
"encounter" OBJECT,
"goal" ARRAY,
"id" VARCHAR,
"intent" VARCHAR,
"period" OBJECT,
"resourceType" VARCHAR,
"status" VARCHAR,
"subject" OBJECT,
"text" OBJECT);
CREATE  OR REPLACE TABLE SYNTHEA_RAW.RAW_DATA.Claim(
PATIENT_ID VARCHAR(16777216) ,
"billablePeriod" OBJECT,
"created" VARCHAR,
"diagnosis" ARRAY,
"id" VARCHAR,
"insurance" ARRAY,
"item" ARRAY,
"patient" OBJECT,
"prescription" OBJECT,
"priority" OBJECT,
"procedure" ARRAY,
"provider" OBJECT,
"resourceType" VARCHAR,
"status" VARCHAR,
"supportingInfo" ARRAY,
"total" OBJECT,
"type" OBJECT,
"use" VARCHAR);
CREATE  OR REPLACE TABLE SYNTHEA_RAW.RAW_DATA.Condition(
PATIENT_ID VARCHAR(16777216) ,
"abatementDateTime" VARCHAR,
"clinicalStatus" OBJECT,
"code" OBJECT,
"encounter" OBJECT,
"id" VARCHAR,
"onsetDateTime" VARCHAR,
"recordedDate" VARCHAR,
"resourceType" VARCHAR,
"subject" OBJECT,
"verificationStatus" OBJECT);
CREATE  OR REPLACE TABLE SYNTHEA_RAW.RAW_DATA.DiagnosticReport(
PATIENT_ID VARCHAR(16777216) ,
"category" ARRAY,
"code" OBJECT,
"effectiveDateTime" VARCHAR,
"encounter" OBJECT,
"id" VARCHAR,
"issued" VARCHAR,
"resourceType" VARCHAR,
"result" ARRAY,
"status" VARCHAR,
"subject" OBJECT);
CREATE  OR REPLACE TABLE SYNTHEA_RAW.RAW_DATA.Encounter(
PATIENT_ID VARCHAR(16777216) ,
"class" OBJECT,
"hospitalization" OBJECT,
"id" VARCHAR,
"participant" ARRAY,
"period" OBJECT,
"reasonCode" ARRAY,
"resourceType" VARCHAR,
"serviceProvider" OBJECT,
"status" VARCHAR,
"subject" OBJECT,
"type" ARRAY);
CREATE  OR REPLACE TABLE SYNTHEA_RAW.RAW_DATA.ExplanationOfBenefit(
PATIENT_ID VARCHAR(16777216) ,
"billablePeriod" OBJECT,
"careTeam" ARRAY,
"claim" OBJECT,
"contained" ARRAY,
"created" VARCHAR,
"diagnosis" ARRAY,
"id" VARCHAR,
"identifier" ARRAY,
"insurance" ARRAY,
"insurer" OBJECT,
"item" ARRAY,
"outcome" VARCHAR,
"patient" OBJECT,
"payment" OBJECT,
"provider" OBJECT,
"referral" OBJECT,
"resourceType" VARCHAR,
"status" VARCHAR,
"total" ARRAY,
"type" OBJECT,
"use" VARCHAR);
CREATE  OR REPLACE TABLE SYNTHEA_RAW.RAW_DATA.Goal(
PATIENT_ID VARCHAR(16777216) ,
"achievementStatus" OBJECT,
"description" OBJECT,
"id" VARCHAR,
"lifecycleStatus" VARCHAR,
"resourceType" VARCHAR,
"subject" OBJECT);
CREATE  OR REPLACE TABLE SYNTHEA_RAW.RAW_DATA.ImagingStudy(
PATIENT_ID VARCHAR(16777216) ,
"encounter" OBJECT,
"id" VARCHAR,
"identifier" ARRAY,
"numberOfInstances" INTEGER,
"numberOfSeries" INTEGER,
"resourceType" VARCHAR,
"series" ARRAY,
"started" VARCHAR,
"status" VARCHAR,
"subject" OBJECT);
CREATE  OR REPLACE TABLE SYNTHEA_RAW.RAW_DATA.Immunization(
PATIENT_ID VARCHAR(16777216) ,
"encounter" OBJECT,
"id" VARCHAR,
"occurrenceDateTime" VARCHAR,
"patient" OBJECT,
"primarySource" BOOLEAN,
"resourceType" VARCHAR,
"status" VARCHAR,
"vaccineCode" OBJECT);
CREATE  OR REPLACE TABLE SYNTHEA_RAW.RAW_DATA.MedicationRequest(
PATIENT_ID VARCHAR(16777216) ,
"authoredOn" VARCHAR,
"dosageInstruction" ARRAY,
"encounter" OBJECT,
"id" VARCHAR,
"intent" VARCHAR,
"medicationCodeableConcept" OBJECT,
"reasonReference" ARRAY,
"requester" OBJECT,
"resourceType" VARCHAR,
"status" VARCHAR,
"subject" OBJECT);
CREATE  OR REPLACE TABLE SYNTHEA_RAW.RAW_DATA.Observation(
PATIENT_ID VARCHAR(16777216) ,
"category" ARRAY,
"code" OBJECT,
"component" ARRAY,
"effectiveDateTime" VARCHAR,
"encounter" OBJECT,
"id" VARCHAR,
"issued" VARCHAR,
"resourceType" VARCHAR,
"status" VARCHAR,
"subject" OBJECT,
"valueCodeableConcept" OBJECT,
"valueQuantity" OBJECT);
CREATE  OR REPLACE TABLE SYNTHEA_RAW.RAW_DATA.Organization(
PATIENT_ID VARCHAR(16777216) ,
"active" BOOLEAN,
"address" ARRAY,
"id" VARCHAR,
"identifier" ARRAY,
"name" VARCHAR,
"resourceType" VARCHAR,
"telecom" ARRAY,
"type" ARRAY);
CREATE  OR REPLACE TABLE SYNTHEA_RAW.RAW_DATA.Patient(
PATIENT_ID VARCHAR(16777216) ,
"address" ARRAY,
"birthDate" VARCHAR,
"communication" ARRAY,
"extension" ARRAY,
"gender" VARCHAR,
"id" VARCHAR,
"identifier" ARRAY,
"maritalStatus" OBJECT,
"multipleBirthBoolean" BOOLEAN,
"multipleBirthInteger" INTEGER,
"name" ARRAY,
"resourceType" VARCHAR,
"telecom" ARRAY,
"text" OBJECT);
CREATE  OR REPLACE TABLE SYNTHEA_RAW.RAW_DATA.Practitioner(
PATIENT_ID VARCHAR(16777216) ,
"active" BOOLEAN,
"address" ARRAY,
"gender" VARCHAR,
"id" VARCHAR,
"identifier" ARRAY,
"name" ARRAY,
"resourceType" VARCHAR);
CREATE  OR REPLACE TABLE SYNTHEA_RAW.RAW_DATA.Procedure(
PATIENT_ID VARCHAR(16777216) ,
"code" OBJECT,
"encounter" OBJECT,
"id" VARCHAR,
"performedPeriod" OBJECT,
"reasonReference" ARRAY,
"resourceType" VARCHAR,
"status" VARCHAR,
"subject" OBJECT);


INSERT INTO SYNTHEA_RAW.RAW_DATA.AllergyIntolerance(
"PATIENT_ID",
"category",
"clinicalStatus",
"code",
"criticality",
"id",
"patient",
"recordedDate",
"resourceType",
"type",
"verificationStatus"
)
SELECT
    l.PATIENT_ID AS "PATIENT_ID",
o.value:"category" AS "category",
o.value:"clinicalStatus" AS "clinicalStatus",
o.value:"code" AS "code",
o.value:"criticality" AS "criticality",
o.value:"id" AS "id",
o.value:"patient" AS "patient",
o.value:"recordedDate" AS "recordedDate",
o.value:"resourceType" AS "resourceType",
o.value:"type" AS "type",
o.value:"verificationStatus" AS "verificationStatus"
FROM SYNTHEA_RAW.UTIL.SYNTHEA_FLATTENED_L1 l,
     LATERAL FLATTEN (INPUT => l.CLINICAL_JSON:AllergyIntolerance) o
WHERE ARRAY_CONTAINS('AllergyIntolerance'::VARIANT, PAT_TABLES);
INSERT INTO SYNTHEA_RAW.RAW_DATA.CarePlan(
"PATIENT_ID",
"activity",
"addresses",
"category",
"encounter",
"goal",
"id",
"intent",
"period",
"resourceType",
"status",
"subject",
"text"
)
SELECT
    l.PATIENT_ID AS "PATIENT_ID",
o.value:"activity" AS "activity",
o.value:"addresses" AS "addresses",
o.value:"category" AS "category",
o.value:"encounter" AS "encounter",
o.value:"goal" AS "goal",
o.value:"id" AS "id",
o.value:"intent" AS "intent",
o.value:"period" AS "period",
o.value:"resourceType" AS "resourceType",
o.value:"status" AS "status",
o.value:"subject" AS "subject",
o.value:"text" AS "text"
FROM SYNTHEA_RAW.UTIL.SYNTHEA_FLATTENED_L1 l,
     LATERAL FLATTEN (INPUT => l.CLINICAL_JSON:CarePlan) o
WHERE ARRAY_CONTAINS('CarePlan'::VARIANT, PAT_TABLES);
INSERT INTO SYNTHEA_RAW.RAW_DATA.Claim(
"PATIENT_ID",
"billablePeriod",
"created",
"diagnosis",
"id",
"insurance",
"item",
"patient",
"prescription",
"priority",
"procedure",
"provider",
"resourceType",
"status",
"supportingInfo",
"total",
"type",
"use"
)
SELECT
    l.PATIENT_ID AS "PATIENT_ID",
o.value:"billablePeriod" AS "billablePeriod",
o.value:"created" AS "created",
o.value:"diagnosis" AS "diagnosis",
o.value:"id" AS "id",
o.value:"insurance" AS "insurance",
o.value:"item" AS "item",
o.value:"patient" AS "patient",
o.value:"prescription" AS "prescription",
o.value:"priority" AS "priority",
o.value:"procedure" AS "procedure",
o.value:"provider" AS "provider",
o.value:"resourceType" AS "resourceType",
o.value:"status" AS "status",
o.value:"supportingInfo" AS "supportingInfo",
o.value:"total" AS "total",
o.value:"type" AS "type",
o.value:"use" AS "use"
FROM SYNTHEA_RAW.UTIL.SYNTHEA_FLATTENED_L1 l,
     LATERAL FLATTEN (INPUT => l.CLINICAL_JSON:Claim) o
WHERE ARRAY_CONTAINS('Claim'::VARIANT, PAT_TABLES);
INSERT INTO SYNTHEA_RAW.RAW_DATA.Condition(
"PATIENT_ID",
"abatementDateTime",
"clinicalStatus",
"code",
"encounter",
"id",
"onsetDateTime",
"recordedDate",
"resourceType",
"subject",
"verificationStatus"
)
SELECT
    l.PATIENT_ID AS "PATIENT_ID",
o.value:"abatementDateTime" AS "abatementDateTime",
o.value:"clinicalStatus" AS "clinicalStatus",
o.value:"code" AS "code",
o.value:"encounter" AS "encounter",
o.value:"id" AS "id",
o.value:"onsetDateTime" AS "onsetDateTime",
o.value:"recordedDate" AS "recordedDate",
o.value:"resourceType" AS "resourceType",
o.value:"subject" AS "subject",
o.value:"verificationStatus" AS "verificationStatus"
FROM SYNTHEA_RAW.UTIL.SYNTHEA_FLATTENED_L1 l,
     LATERAL FLATTEN (INPUT => l.CLINICAL_JSON:Condition) o
WHERE ARRAY_CONTAINS('Condition'::VARIANT, PAT_TABLES);
INSERT INTO SYNTHEA_RAW.RAW_DATA.DiagnosticReport(
"PATIENT_ID",
"category",
"code",
"effectiveDateTime",
"encounter",
"id",
"issued",
"resourceType",
"result",
"status",
"subject"
)
SELECT
    l.PATIENT_ID AS "PATIENT_ID",
o.value:"category" AS "category",
o.value:"code" AS "code",
o.value:"effectiveDateTime" AS "effectiveDateTime",
o.value:"encounter" AS "encounter",
o.value:"id" AS "id",
o.value:"issued" AS "issued",
o.value:"resourceType" AS "resourceType",
o.value:"result" AS "result",
o.value:"status" AS "status",
o.value:"subject" AS "subject"
FROM SYNTHEA_RAW.UTIL.SYNTHEA_FLATTENED_L1 l,
     LATERAL FLATTEN (INPUT => l.CLINICAL_JSON:DiagnosticReport) o
WHERE ARRAY_CONTAINS('DiagnosticReport'::VARIANT, PAT_TABLES);
INSERT INTO SYNTHEA_RAW.RAW_DATA.Encounter(
"PATIENT_ID",
"class",
"hospitalization",
"id",
"participant",
"period",
"reasonCode",
"resourceType",
"serviceProvider",
"status",
"subject",
"type"
)
SELECT
    l.PATIENT_ID AS "PATIENT_ID",
o.value:"class" AS "class",
o.value:"hospitalization" AS "hospitalization",
o.value:"id" AS "id",
o.value:"participant" AS "participant",
o.value:"period" AS "period",
o.value:"reasonCode" AS "reasonCode",
o.value:"resourceType" AS "resourceType",
o.value:"serviceProvider" AS "serviceProvider",
o.value:"status" AS "status",
o.value:"subject" AS "subject",
o.value:"type" AS "type"
FROM SYNTHEA_RAW.UTIL.SYNTHEA_FLATTENED_L1 l,
     LATERAL FLATTEN (INPUT => l.CLINICAL_JSON:Encounter) o
WHERE ARRAY_CONTAINS('Encounter'::VARIANT, PAT_TABLES);
INSERT INTO SYNTHEA_RAW.RAW_DATA.ExplanationOfBenefit(
"PATIENT_ID",
"billablePeriod",
"careTeam",
"claim",
"contained",
"created",
"diagnosis",
"id",
"identifier",
"insurance",
"insurer",
"item",
"outcome",
"patient",
"payment",
"provider",
"referral",
"resourceType",
"status",
"total",
"type",
"use"
)
SELECT
    l.PATIENT_ID AS "PATIENT_ID",
o.value:"billablePeriod" AS "billablePeriod",
o.value:"careTeam" AS "careTeam",
o.value:"claim" AS "claim",
o.value:"contained" AS "contained",
o.value:"created" AS "created",
o.value:"diagnosis" AS "diagnosis",
o.value:"id" AS "id",
o.value:"identifier" AS "identifier",
o.value:"insurance" AS "insurance",
o.value:"insurer" AS "insurer",
o.value:"item" AS "item",
o.value:"outcome" AS "outcome",
o.value:"patient" AS "patient",
o.value:"payment" AS "payment",
o.value:"provider" AS "provider",
o.value:"referral" AS "referral",
o.value:"resourceType" AS "resourceType",
o.value:"status" AS "status",
o.value:"total" AS "total",
o.value:"type" AS "type",
o.value:"use" AS "use"
FROM SYNTHEA_RAW.UTIL.SYNTHEA_FLATTENED_L1 l,
     LATERAL FLATTEN (INPUT => l.CLINICAL_JSON:ExplanationOfBenefit) o
WHERE ARRAY_CONTAINS('ExplanationOfBenefit'::VARIANT, PAT_TABLES);
INSERT INTO SYNTHEA_RAW.RAW_DATA.Goal(
"PATIENT_ID",
"achievementStatus",
"description",
"id",
"lifecycleStatus",
"resourceType",
"subject"
)
SELECT
    l.PATIENT_ID AS "PATIENT_ID",
o.value:"achievementStatus" AS "achievementStatus",
o.value:"description" AS "description",
o.value:"id" AS "id",
o.value:"lifecycleStatus" AS "lifecycleStatus",
o.value:"resourceType" AS "resourceType",
o.value:"subject" AS "subject"
FROM SYNTHEA_RAW.UTIL.SYNTHEA_FLATTENED_L1 l,
     LATERAL FLATTEN (INPUT => l.CLINICAL_JSON:Goal) o
WHERE ARRAY_CONTAINS('Goal'::VARIANT, PAT_TABLES);
INSERT INTO SYNTHEA_RAW.RAW_DATA.ImagingStudy(
"PATIENT_ID",
"encounter",
"id",
"identifier",
"numberOfInstances",
"numberOfSeries",
"resourceType",
"series",
"started",
"status",
"subject"
)
SELECT
    l.PATIENT_ID AS "PATIENT_ID",
o.value:"encounter" AS "encounter",
o.value:"id" AS "id",
o.value:"identifier" AS "identifier",
o.value:"numberOfInstances" AS "numberOfInstances",
o.value:"numberOfSeries" AS "numberOfSeries",
o.value:"resourceType" AS "resourceType",
o.value:"series" AS "series",
o.value:"started" AS "started",
o.value:"status" AS "status",
o.value:"subject" AS "subject"
FROM SYNTHEA_RAW.UTIL.SYNTHEA_FLATTENED_L1 l,
     LATERAL FLATTEN (INPUT => l.CLINICAL_JSON:ImagingStudy) o
WHERE ARRAY_CONTAINS('ImagingStudy'::VARIANT, PAT_TABLES);
INSERT INTO SYNTHEA_RAW.RAW_DATA.Immunization(
"PATIENT_ID",
"encounter",
"id",
"occurrenceDateTime",
"patient",
"primarySource",
"resourceType",
"status",
"vaccineCode"
)
SELECT
    l.PATIENT_ID AS "PATIENT_ID",
o.value:"encounter" AS "encounter",
o.value:"id" AS "id",
o.value:"occurrenceDateTime" AS "occurrenceDateTime",
o.value:"patient" AS "patient",
o.value:"primarySource" AS "primarySource",
o.value:"resourceType" AS "resourceType",
o.value:"status" AS "status",
o.value:"vaccineCode" AS "vaccineCode"
FROM SYNTHEA_RAW.UTIL.SYNTHEA_FLATTENED_L1 l,
     LATERAL FLATTEN (INPUT => l.CLINICAL_JSON:Immunization) o
WHERE ARRAY_CONTAINS('Immunization'::VARIANT, PAT_TABLES);
INSERT INTO SYNTHEA_RAW.RAW_DATA.MedicationRequest(
"PATIENT_ID",
"authoredOn",
"dosageInstruction",
"encounter",
"id",
"intent",
"medicationCodeableConcept",
"reasonReference",
"requester",
"resourceType",
"status",
"subject"
)
SELECT
    l.PATIENT_ID AS "PATIENT_ID",
o.value:"authoredOn" AS "authoredOn",
o.value:"dosageInstruction" AS "dosageInstruction",
o.value:"encounter" AS "encounter",
o.value:"id" AS "id",
o.value:"intent" AS "intent",
o.value:"medicationCodeableConcept" AS "medicationCodeableConcept",
o.value:"reasonReference" AS "reasonReference",
o.value:"requester" AS "requester",
o.value:"resourceType" AS "resourceType",
o.value:"status" AS "status",
o.value:"subject" AS "subject"
FROM SYNTHEA_RAW.UTIL.SYNTHEA_FLATTENED_L1 l,
     LATERAL FLATTEN (INPUT => l.CLINICAL_JSON:MedicationRequest) o
WHERE ARRAY_CONTAINS('MedicationRequest'::VARIANT, PAT_TABLES);
INSERT INTO SYNTHEA_RAW.RAW_DATA.Observation(
"PATIENT_ID",
"category",
"code",
"component",
"effectiveDateTime",
"encounter",
"id",
"issued",
"resourceType",
"status",
"subject",
"valueCodeableConcept",
"valueQuantity"
)
SELECT
    l.PATIENT_ID AS "PATIENT_ID",
o.value:"category" AS "category",
o.value:"code" AS "code",
o.value:"component" AS "component",
o.value:"effectiveDateTime" AS "effectiveDateTime",
o.value:"encounter" AS "encounter",
o.value:"id" AS "id",
o.value:"issued" AS "issued",
o.value:"resourceType" AS "resourceType",
o.value:"status" AS "status",
o.value:"subject" AS "subject",
o.value:"valueCodeableConcept" AS "valueCodeableConcept",
o.value:"valueQuantity" AS "valueQuantity"
FROM SYNTHEA_RAW.UTIL.SYNTHEA_FLATTENED_L1 l,
     LATERAL FLATTEN (INPUT => l.CLINICAL_JSON:Observation) o
WHERE ARRAY_CONTAINS('Observation'::VARIANT, PAT_TABLES);
INSERT INTO SYNTHEA_RAW.RAW_DATA.Organization(
"PATIENT_ID",
"active",
"address",
"id",
"identifier",
"name",
"resourceType",
"telecom",
"type"
)
SELECT
    l.PATIENT_ID AS "PATIENT_ID",
o.value:"active" AS "active",
o.value:"address" AS "address",
o.value:"id" AS "id",
o.value:"identifier" AS "identifier",
o.value:"name" AS "name",
o.value:"resourceType" AS "resourceType",
o.value:"telecom" AS "telecom",
o.value:"type" AS "type"
FROM SYNTHEA_RAW.UTIL.SYNTHEA_FLATTENED_L1 l,
     LATERAL FLATTEN (INPUT => l.CLINICAL_JSON:Organization) o
WHERE ARRAY_CONTAINS('Organization'::VARIANT, PAT_TABLES);
INSERT INTO SYNTHEA_RAW.RAW_DATA.Patient(
"PATIENT_ID",
"address",
"birthDate",
"communication",
"extension",
"gender",
"id",
"identifier",
"maritalStatus",
"multipleBirthBoolean",
"multipleBirthInteger",
"name",
"resourceType",
"telecom",
"text"
)
SELECT
    l.PATIENT_ID AS "PATIENT_ID",
o.value:"address" AS "address",
o.value:"birthDate" AS "birthDate",
o.value:"communication" AS "communication",
o.value:"extension" AS "extension",
o.value:"gender" AS "gender",
o.value:"id" AS "id",
o.value:"identifier" AS "identifier",
o.value:"maritalStatus" AS "maritalStatus",
o.value:"multipleBirthBoolean" AS "multipleBirthBoolean",
o.value:"multipleBirthInteger" AS "multipleBirthInteger",
o.value:"name" AS "name",
o.value:"resourceType" AS "resourceType",
o.value:"telecom" AS "telecom",
o.value:"text" AS "text"
FROM SYNTHEA_RAW.UTIL.SYNTHEA_FLATTENED_L1 l,
     LATERAL FLATTEN (INPUT => l.CLINICAL_JSON:Patient) o
WHERE ARRAY_CONTAINS('Patient'::VARIANT, PAT_TABLES);
INSERT INTO SYNTHEA_RAW.RAW_DATA.Practitioner(
"PATIENT_ID",
"active",
"address",
"gender",
"id",
"identifier",
"name",
"resourceType"
)
SELECT
    l.PATIENT_ID AS "PATIENT_ID",
o.value:"active" AS "active",
o.value:"address" AS "address",
o.value:"gender" AS "gender",
o.value:"id" AS "id",
o.value:"identifier" AS "identifier",
o.value:"name" AS "name",
o.value:"resourceType" AS "resourceType"
FROM SYNTHEA_RAW.UTIL.SYNTHEA_FLATTENED_L1 l,
     LATERAL FLATTEN (INPUT => l.CLINICAL_JSON:Practitioner) o
WHERE ARRAY_CONTAINS('Practitioner'::VARIANT, PAT_TABLES);
INSERT INTO SYNTHEA_RAW.RAW_DATA.Procedure(
"PATIENT_ID",
"code",
"encounter",
"id",
"performedPeriod",
"reasonReference",
"resourceType",
"status",
"subject"
)
SELECT
    l.PATIENT_ID AS "PATIENT_ID",
o.value:"code" AS "code",
o.value:"encounter" AS "encounter",
o.value:"id" AS "id",
o.value:"performedPeriod" AS "performedPeriod",
o.value:"reasonReference" AS "reasonReference",
o.value:"resourceType" AS "resourceType",
o.value:"status" AS "status",
o.value:"subject" AS "subject"
FROM SYNTHEA_RAW.UTIL.SYNTHEA_FLATTENED_L1 l,
     LATERAL FLATTEN (INPUT => l.CLINICAL_JSON:Procedure) o
WHERE ARRAY_CONTAINS('Procedure'::VARIANT, PAT_TABLES);

select 'AllergyIntolerance' as table_name, count(*) as cnt  from AllergyIntolerance union all
select 'CarePlan' as table_name, count(*) as cnt  from CarePlan union all
select 'Claim' as table_name, count(*) as cnt  from Claim union all
select 'Condition' as table_name, count(*) as cnt  from Condition union all
select 'DiagnosticReport' as table_name, count(*) as cnt  from DiagnosticReport union all
select 'Encounter' as table_name, count(*) as cnt  from Encounter union all
select 'ExplanationOfBenefit' as table_name, count(*) as cnt  from ExplanationOfBenefit union all
select 'Goal' as table_name, count(*) as cnt  from Goal union all
select 'ImagingStudy' as table_name, count(*) as cnt  from ImagingStudy union all
select 'Immunization' as table_name, count(*) as cnt  from Immunization union all
select 'MedicationRequest' as table_name, count(*) as cnt  from MedicationRequest union all
select 'Observation' as table_name, count(*) as cnt  from Observation union all
select 'Organization' as table_name, count(*) as cnt  from Organization union all
select 'Patient' as table_name, count(*) as cnt  from Patient union all
select 'Practitioner' as table_name, count(*) as cnt  from Practitioner union all
select 'Procedure' as table_name, count(*) as cnt  from Procedure;