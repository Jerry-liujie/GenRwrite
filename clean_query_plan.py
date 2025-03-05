import json
import os
from autorewrite.utils import *

def remove_fields(data, fields):
    if isinstance(data, dict):
        return {k: remove_fields(v, fields) for k, v in data.items() if k not in fields}
    elif isinstance(data, list):
        return [remove_fields(item, fields) for item in data]
    return data

# Join Type
# Alias
# Sort Method

field_list = [
    "Async Capable",
    "Plan Width",
    "Total Cost",
    "Parallel Aware",
    "Startup Cost",
    "Parent Relationship",
    "Subplans Removed",
    "Partial Mode",
    "Strategy",
    "Workers Planned",
    "Workers Launched",
    "Workers",
    "Hash Batches",
    "Hash Buckets",
    "Original Hash Buckets",
    "Original Hash Batches",
    "Scan Direction",
    "Subplan Name",
    "Rows Removed by Index Recheck",
    "Inner Unique",
    "Join Type",
    "Sort Method"]

input_json_folder = 'query_plans/tpcds'
output_json_folder = 'query_plans/tpcds_cleaned'
json_files = os.listdir(input_json_folder)

if not os.path.exists(output_json_folder):
    os.makedirs(output_json_folder)

for json_file in json_files:
    with open(os.path.join(input_json_folder, json_file)) as f:
        # check if the file is empty or if it is a .json file
        if os.stat(os.path.join(input_json_folder, json_file)).st_size == 0 or not json_file.endswith('.json'):
            # print(f"Skipping {json_file}")
            continue
        
        
        plan_data = json.load(f)
        cleaned_json = remove_fields(plan_data, field_list)
        plan_data_str = json.dumps(plan_data, indent=2)
        cleaned_json_str = json.dumps(cleaned_json, indent=2)
        # print the number of tokens before and after cleaning
        before = count_tokens(plan_data_str)
        after = count_tokens(cleaned_json_str)
        print(f"{json_file}, Before: {before}, After: {after}")
        
        output_file = os.path.join(output_json_folder, json_file)
        with open(output_file, 'w') as f:
            json.dump(cleaned_json, f, indent=2)
