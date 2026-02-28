import numpy as np
import pandas as pd
import json
import os
import matplotlib
import seaborn as sns
import matplotlib.pyplot as plt 
import warnings

warnings.filterwarnings('ignore')
pd.set_option('display.max_colwidth', 50)
from tqdm import tqdm

# transformation functions to get clinical dataframes from the json files

folder_path = r'D:\fhir\input'
sample_file_path = r'D:\fhir\input\00\000\0000e4c0-2057-4c43-a90e-33891c7bc097.json'
output_folder = r'D:\fhir\output\\'


file_path_list = []
for dirname, _, filenames in os.walk(folder_path):
    for filename in filenames:
        file_path_list.append((dirname, filename))
metadata_df = pd.DataFrame(file_path_list, columns=["folder", "file"])

# print(f"Files: {metadata_df.shape[0]}")
# print(f"Files: {metadata_df.head()}")

# Add group and subgroup information

def extract_subgroup(path): return path.split("\\")[-1]

def extract_group(path): return path.split("\\")[-2]

metadata_df["group"] = metadata_df["folder"].apply(lambda x: extract_group(x))
metadata_df["subgroup"] = metadata_df["folder"].apply(lambda x: extract_subgroup(x))

metadata_df = metadata_df[["folder", "group", "subgroup", "file"]]
metadata_df.head()
# print(metadata_df.head())

sample_df= pd.read_json(sample_file_path)
# print(sample_df.head())

patient_df = pd.DataFrame() 
careplan_df = pd.DataFrame() 
condition_df = pd.DataFrame() 
diagnostic_report_df = pd.DataFrame() 
encounter_df = pd.DataFrame() 
immunization_df = pd.DataFrame() 
observation_df = pd.DataFrame() 
procedure_df = pd.DataFrame() 

def process_one_file(sample_df,patient_df, careplan_df,condition_df,diagnostic_report_df,encounter_df,immunization_df,observation_df,procedure_df):
    
    dataframe_list = [patient_df, careplan_df, condition_df, diagnostic_report_df, encounter_df, immunization_df, observation_df, procedure_df]
    
    for index, row in sample_df.iterrows():
        # create an Empty set(). A set() is  an unordered collection of unique elements. No duplicate members. No indexing. Mutable and iterable.
        resourcetype=set()  
        #  create a data frame with json_normalize() function which is used to convert a nested JSON object into a flat table. It takes a JSON object as input and returns a DataFrame with the flattened data.
        tempdf=pd.json_normalize(row.entry)   
        resourcetype.add([str(x) for x in tempdf['resource.resourceType']][0])

        if str(tempdf['resource.resourceType'][0])=="Patient":
            frames = [patient_df, tempdf]
            patient_df = pd.concat(frames)

        elif str(tempdf['resource.resourceType'][0])=="CarePlan":
            frames = [careplan_df, tempdf]
            careplan_df = pd.concat(frames)

        elif str(tempdf['resource.resourceType'][0])=="Condition":
            frames = [condition_df, tempdf]
            condition_df = pd.concat(frames)

        elif str(tempdf['resource.resourceType'][0])=="DiagnosticReport":
            frames = [diagnostic_report_df, tempdf]
            diagnostic_report_df = pd.concat(frames)

        elif str(tempdf['resource.resourceType'][0])=="Encounter":
            frames = [encounter_df, tempdf]
            encounter_df = pd.concat(frames)

        elif str(tempdf['resource.resourceType'][0])=="Immunization":
            frames = [immunization_df, tempdf]
            immunization_df = pd.concat(frames)

        elif str(tempdf['resource.resourceType'][0])=="Observation":
            frames = [observation_df, tempdf]
            observation_df = pd.concat(frames)

        elif str(tempdf['resource.resourceType'][0])=="Procedure":
            frames = [procedure_df, tempdf]
            procedure_df = pd.concat(frames)   

    return patient_df,careplan_df,condition_df,diagnostic_report_df,encounter_df,immunization_df,observation_df,procedure_df

def clean_and_rename(patient_df, careplan_df,condition_df,diagnostic_report_df,encounter_df,immunization_df,observation_df,procedure_df):
    for df in [patient_df, careplan_df, condition_df, diagnostic_report_df,
                 encounter_df, immunization_df, observation_df, procedure_df]:
        df.columns = df.columns.str.replace(".", "_")
        df.columns = df.columns.str.replace("resource_", "")
    
    for df in [patient_df, observation_df, encounter_df]:
        df['fullUrl']= df['fullUrl'].str.replace('urn:uuid:', '')
        
    #for df in [careplan_df, condition_df, diagnostic_report_df]:
    #    df['subject_reference']=df['subject_reference'].str.replace('urn:uuid:', '')
    #    df['context_reference']=df['context_reference'].str.replace('urn:uuid:', '')
    
    for df in [encounter_df, immunization_df]:
        df['patient_reference'] = df['patient_reference'].str.replace('urn:uuid:', '')
        
    for df in [immunization_df]:
        df['encounter_reference'] = df['encounter_reference'].str.replace('urn:uuid:', '')
        
    for df in [observation_df, procedure_df]:
        df['subject_reference'] = df['subject_reference'].str.replace('urn:uuid:', '')
        df['encounter_reference'] = df['encounter_reference'].str.replace('urn:uuid:', '')
        
    return patient_df, careplan_df, condition_df, diagnostic_report_df, encounter_df, immunization_df, observation_df, procedure_df


patient_df, careplan_df, condition_df, diagnostic_report_df, encounter_df, immunization_df, observation_df, procedure_df =  \
    process_one_file(sample_df,patient_df, careplan_df,condition_df,diagnostic_report_df,encounter_df,immunization_df,observation_df,procedure_df)

patient_df, careplan_df, condition_df, diagnostic_report_df, encounter_df, immunization_df, observation_df, procedure_df =  \
    clean_and_rename(patient_df, careplan_df,condition_df,diagnostic_report_df,encounter_df,immunization_df,observation_df,procedure_df)

print(f"Folders: {metadata_df.folder.nunique()}")
print(f"Groups: {metadata_df.group.nunique()}")
print(f"Subgroups: {metadata_df.subgroup.nunique()}")
print(f"Files: {metadata_df.file.nunique()}")

sel_index = list(metadata_df.group.value_counts()[0:2].index)
print(sel_index)

group_df = metadata_df.loc[metadata_df.group.isin(sel_index)]
group_df.shape[0], group_df.shape[0] / metadata_df.shape[0]


for index, row in tqdm(group_df.iterrows(), total=len(group_df), desc="Processing JSONs"):
    folder = row["folder"]
    file = row["file"]
    sample_df = pd.read_json(os.path.join(folder, file))
    patient_df, careplan_df, condition_df, diagnostic_report_df, encounter_df, immunization_df, observation_df, procedure_df =  \
        process_one_file(sample_df, patient_df, careplan_df, condition_df, diagnostic_report_df, encounter_df, immunization_df, observation_df, procedure_df)
    # patient_df, careplan_df, condition_df, diagnostic_report_df, encounter_df, immunization_df, observation_df, procedure_df =  \
    #     clean_and_rename(patient_df, careplan_df, condition_df, diagnostic_report_df,   encounter_df, immunization_df, observation_df, procedure_df)

print(f"Patient DataFrame shape: {patient_df.shape}")
print(f"CarePlan DataFrame shape: {careplan_df.shape}")
print(f"Condition DataFrame shape: {condition_df.shape}")
print(f"DiagnosticReport DataFrame shape: {diagnostic_report_df.shape}")
print(f"Encounter DataFrame shape: {encounter_df.shape}")
print(f"Immunization DataFrame shape: {immunization_df.shape}")
print(f"Observation DataFrame shape: {observation_df.shape}")
print(f"Procedure DataFrame shape: {procedure_df.shape}")

for df in [patient_df, careplan_df, condition_df, diagnostic_report_df, encounter_df, immunization_df, observation_df,procedure_df]:
    print(df.columns)


print("\n Patient DataFrame")
print(patient_df.head())
print("\n Careplan DataFrame")
print(careplan_df.head())
print("\n Condition DataFrame")
print(condition_df.head())
print("\n Observation DataFrame")
print(observation_df.head())
print("\n Procedure DataFrame")
print(procedure_df.head())


patient_df.to_csv(output_folder + 'patient_df.csv', index=False, header=True)
careplan_df.to_csv(output_folder + 'careplan_df.csv', index=False, header=True)
condition_df.to_csv(output_folder + 'condition_df.csv', index=False, header=True)
observation_df.to_csv(output_folder + 'observation_df.csv', index=False, header=True)
procedure_df.to_csv(output_folder + 'procedure_df.csv', index=False, header=True)