# p1: get the initial rewrites and rules involved

from autorewrite.openai import Gpt4
import os
from datetime import datetime


m = Gpt4()
model = m.model

timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
# extract date from timestamp, format: mmdd
date = timestamp[4:8] + 'xxx'


query_dir = "benchmark/tpcds/formatted_queries/"
log_dir = "logs/"
result_dir = "exp_results/"

query_list = []
query_id_list = []

for file in os.listdir(query_dir):
    f_p = os.path.join(query_dir, file)
    id = file.split(".")[0]

    if '_' in id:
        continue
    if os.path.isfile(f_p):
        with open(f_p) as f:
            query = f.read()
            query_list.append(query)
            query_id_list.append(id)

round_1_prompt = "\n\n" + "Rewrite this query to improve performance. Describe the rewrite rules you are using (you must not include any specific query details in the rules, e.g., table names, column names, etc; For each rule, separate rule itself and its benefit with ':'). Be concise.\n"
round_1_prompt += "\nOutput template: \n\n" + "Rewritten query:\n...\n\nRewrite rules:\n1. xxx\n2. xxx\n..."
extract_constraint_prompt = "For each rule, identify the condition to apply the rule. One sentence for each rule.\nExample output: \n1. Filter data as early as possible: This rule can be applied when there are conditions that can be used to filter the data in the early stages of the query.\n2. xxx\n"

query_list = [x + round_1_prompt for x in query_list]

for round in range(4):
    print("Round " + str(round) + " starts.")
    label = date + '_' + str(round)

    results = m._chat_complete_batch(query_list)

    print("Done with round 1.")
    round_2_prompt_list = []

    for i in range(len(query_list)):
        tmp = [
                {
                "role": "user",
                "content": query_id_list[i]
                },
                {
                "role": "assistant",
                "content": results[i]
                },
                {
                "role": "user",
                "content": extract_constraint_prompt
                }
            ]
        round_2_prompt_list.append(tmp)

    round_2_results = m._chat_complete_batch_msg(round_2_prompt_list)

    for i in range(len(query_list)):
        # create folders
        per_query_log_folder = log_dir + query_id_list[i] + '/'
        per_query_result_folder = result_dir + query_id_list[i] + '/'

        if not os.path.exists(per_query_log_folder):
            os.makedirs(per_query_log_folder)

        if not os.path.exists(per_query_result_folder):
            os.makedirs(per_query_result_folder)

        # write to log file
        log_file = per_query_log_folder + query_id_list[i] + '_' + model + '_' + timestamp + '.txt'
        with open(log_file, 'w') as f:
            f.write(query_list[i])
            f.write("\n----------------------------------------\n")
            f.write(results[i])
            f.write("\n----------------------------------------\n")
            f.write(extract_constraint_prompt)
            f.write("\n----------------------------------------\n")
            f.write(round_2_results[i])

        # "Rewritten query:\n...\n\nRewrite rules:\n1. \n2.\n..."
        # write the rewrite and rules to result file
        rewritten_q = results[i].split("Rewrite rules:")[0]
        rewritten_q = rewritten_q.split("Rewritten query:")[1]
        rewritten_q = rewritten_q.strip()

        rewrite_rules = results[i].split("Rewrite rules:")[1]
        rewrite_rules = rewrite_rules.strip()
        
        # rewritten_q_file = per_query_result_folder + query_id_list[i] + '_' + model + '_rewrite' + '.sql'
        rewritten_q_file = per_query_result_folder + query_id_list[i] + '_' + model + '_rewrite_' + label + '.sql'
        with open(rewritten_q_file, 'w') as f:
            f.write(rewritten_q)

        # rewrite_rules_file = per_query_result_folder + query_id_list[i] + '_' + model + '_rules' + '.txt'
        rewrite_rules_file = per_query_result_folder + query_id_list[i] + '_' + model + '_rules_' + label + '.txt'
        with open(rewrite_rules_file, 'w') as f:
            f.write(rewrite_rules)

        rule_constraint_file = per_query_result_folder + query_id_list[i] + '_' + model + '_constraints_' + label + '.txt'
        with open(rule_constraint_file, 'w') as f:
            f.write(round_2_results[i])

        print("Done with query " + query_id_list[i])

