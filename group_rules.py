import os
from autorewrite.gpt import O3Mini
import csv
import time
from datetime import datetime

m = O3Mini()
model = m.model

input_rule_folder = 'rewrite_rules/tpcds/ungrouped_rules'
output_rule_folder = 'rewrite_rules/tpcds/grouped_rules'
timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
log_file = 'rewrite_rules/' + model + '_' + timestamp + '.log'

rule_id_map_list = []

subfolders = os.listdir(input_rule_folder)
for subfolder in subfolders:
    subfolder_path = os.path.join(input_rule_folder, subfolder)
    if os.path.isdir(subfolder_path):
        m_rules = dict()
        rule_files = os.listdir(subfolder_path)
        for rule_file in rule_files:
            rule_id = rule_file.split('.')[0]
            if rule_file.endswith('.txt'):
                with open(os.path.join(subfolder_path, rule_file), 'r') as f:
                    rule = f.read()
                    m_rules[rule_id] = rule
                    
        stored_rules = []
        cnt = 0
        for rule_id, rule in m_rules.items():
            if cnt == 0:
                stored_rules.append(rule)
                rule_id_map_list.append([subfolder, rule_id, 0])
                cnt += 1
                continue
            
            prompt = rule + '\n'
            prompt += "Please select the rewrite rule that is equivalent the above rule (just give one answer). If not, please select the first item “Unseen rule”.\n"
            prompt += "1. Unseen rule\n"
            for j in range(len(stored_rules)):
                prompt += str(j + 2) + '. ' + stored_rules[j] + '\n'

            ans = m._open_ai_chat_completion(prompt)
            ans = ans.content
            
            selected_rule = -1
            for j in range(len(stored_rules)):
                mark = str(j + 2) + '. '
                if mark in ans:
                    selected_rule = stored_rules[j]
                    rule_id_map_list.append([subfolder, rule_id, j])
                    break
                
            if selected_rule == -1:
                stored_rules.append(rule)
                rule_id_map_list.append([subfolder, rule_id, len(stored_rules) - 1])
                
            with open(log_file, 'a') as f:
                # subfolder, rule_id, prompt, answer
                f.write(subfolder + ',' + rule_id + '\n')
                # prompt and answer
                f.write(prompt + '\n')
                f.write(ans + '\n')
                
            output_subfolder = os.path.join(output_rule_folder, subfolder)
            if not os.path.exists(output_subfolder):
                os.makedirs(output_subfolder)
                
            for i in range(len(stored_rules)):
                with open(os.path.join(output_subfolder, f'{i}.txt'), 'w') as f:
                    f.write(stored_rules[i])
                
                
with open('rewrite_rules/rule_id_map.csv', 'w') as f:
    writer = csv.writer(f)
    writer.writerow(['subfolder', 'old_rule_id', 'new_rule_id'])
    writer.writerows(rule_id_map_list)
    
            
            