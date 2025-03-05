import json
import os
import numpy as np
from autorewrite.plan_summarizer import PlanSummarizer
from autorewrite.gpt import O3Mini
from autorewrite.utils import *
from datetime import datetime
from transformers import BertTokenizer, BertModel
import torch


m = O3Mini()
model = m.model

tokenizer = BertTokenizer.from_pretrained('bert-base-uncased')
bert_model = BertModel.from_pretrained('bert-base-uncased')

json_folder = 'run_time_results/tpcds-0225-original-queries-cleaned'
json_files = os.listdir(json_folder)

benchmark_name = "tpcds"
log_dir = "logs/plan_summary/" + benchmark_name + "/"
if not os.path.exists(log_dir):
    os.makedirs(log_dir)

timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
timestamp = timestamp[4:13]
results_dir = "query_plan_summary"

id_list = []
plan_list = []
log_files = []

for json_file in json_files:
    with open(os.path.join(json_folder, json_file)) as f:
        # check if the file is empty or if it is a .json file
        if os.stat(os.path.join(json_folder, json_file)).st_size == 0 or not json_file.endswith('.json'):
            # print(f"Skipping {json_file}")
            continue
        
        id = json_file.split('.')[0]
        # include model and timestamp in the log file name
        log_file = f"{log_dir}{id}_{model}_{timestamp}.log"
        plan_data = json.load(f)
        # convert the plan_data to a string and format it
        plan_data = json.dumps(plan_data, indent=2)
        
        id_list.append(id)
        plan_list.append(plan_data)
        log_files.append(log_file)
        
# Initialize the PlanSummarizer
ps = PlanSummarizer(m, plan_list, log_files)
# Summarize the plans
summaries, costs = ps.summarize()

bottleneck_descriptions = []
for i in range(len(id_list)):
    per_query_results_dir = f"{results_dir}/{id_list[i]}"
    if not os.path.exists(per_query_results_dir):
        os.makedirs(per_query_results_dir)
        
    summary = summaries[i]
    bottleneck_description = extract_plan_summary_from_summary_string(summary)
    rewrite_rules = extract_rewrite_rules_from_summary_string(summary)
    
    file1 = f"{per_query_results_dir}/{id_list[i]}_{model}_{timestamp}_summary.txt"
    file2 = f"{per_query_results_dir}/{id_list[i]}_{model}_{timestamp}_rewrite_rules.txt"
    with open(file1, 'w') as f:
        f.write(f"{bottleneck_description}")
    with open(file2, 'w') as f:
        f.write(f"{rewrite_rules}")
    
    result_file = f"{per_query_results_dir}/{id_list[i]}_{model}_{timestamp}_whole.txt"
    with open(result_file, 'w') as f:
        f.write(f"Original query plan: {plan_list[i]}\n")
        f.write(f"Summary: {summaries[i]}\n")
        f.write(f"Cost: {costs[i]}\n")
    
    bottleneck_descriptions.append(bottleneck_description)
    
encoded_bottleneck_descriptions = [tokenizer(bottleneck_description, return_tensors='pt') for bottleneck_description in bottleneck_descriptions]
with torch.no_grad():
    embeddings = [bert_model(**bd)['last_hidden_state'].mean(dim=1).squeeze().numpy() for bd in encoded_bottleneck_descriptions]
embeddings = np.array(embeddings)
# write the embeddings to a file
embedding_file = f"{results_dir}/{benchmark_name}_{model}_{timestamp}_embeddings.npy"
np.save(embedding_file, embeddings)
# write the ids to a file
id_file = f"{results_dir}/{benchmark_name}_{model}_{timestamp}_ids.txt"
with open(id_file, 'w') as f:
    f.write("\n".join(id_list))
            
    
        
        
    