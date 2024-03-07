import torch
import matplotlib.pyplot as plt
import numpy as np
from autorewrite.openai import Gpt4
from datetime import datetime
import csv
import collections


m = Gpt4()

timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
date = 'xxx'
correctness_checking_result_path = 'xxx'
result_folder = 'xxx'
base_rule_file_name = 'xxx'
f_p = 'xxx'

equiv_dict = collections.defaultdict(list)
with open(correctness_checking_result_path, 'r') as f:
    reader = csv.reader(f)
    next(reader)
    # pid,qid,query
    for row in reader:
        label = row[1].split("-")
        qid = label[0]
        method = label[1]
        if 'only' not in method and 'syntax' in method:
            equiv_dict[qid].append(method[-1])


with open(f_p, 'w') as f:
    for k, v in equiv_dict.items():
        f.write(k + '\n')
        for ele in v:
            full_file_name = result_folder + k + '/' + k + base_rule_file_name + ele + '.txt'
            with open(full_file_name, 'r') as fr:
                f.write('batch ' + ele + '\n')
                rule = fr.read()
                f.write(rule + '\n')
        f.write('\n')
        # print("=======================================")

print("read all rules done")




from transformers import BertTokenizer, BertModel
tokenizer = BertTokenizer.from_pretrained('bert-base-uncased')
model = BertModel.from_pretrained('bert-base-uncased')



log_f = 'xxx'
output_text_file = 'xxx'
output_index_file = 'xxx'
top_k = 5


print("=======================================")

# read rule_dict
rule_dict = dict()
all_rules = []
group_rule_list_dict = dict()
rule_group_dict = dict()
rid_qid_reverse_dict = dict()

cnt = 0
with open(f_p, 'r') as f:
    for line in f:
        line = line.strip()
        if len(line) == 0:
            continue
        # if line is a integer, then it is a rule id
        if line.isdigit():
            rule_id = int(line)
            rule_dict[rule_id] = []
        elif line.startswith('batch'):
            continue
        else:
            line = line.split('. ')[1].strip()
            rule_dict[rule_id].append(line)
            all_rules.append(line)
            rid_qid_reverse_dict[cnt] = rule_id
            cnt += 1

encoded_rules = [tokenizer(rule, return_tensors='pt') for rule in all_rules]
# print(encoded_rules[0])
# print("=======================================")
with torch.no_grad():
    embeddings = [model(**rule)['last_hidden_state'].mean(dim=1).squeeze().numpy() for rule in encoded_rules]
embeddings = np.array(embeddings)
print(embeddings.shape)

group_cnt = 0
group_rule_list_dict[group_cnt] = [0]
rule_group_dict[0] = group_cnt

for i in range(1, len(embeddings)):
    print('progress: ' + str(i))
    if i < top_k:
        k = i
        indices = list(range(i))
    else:
        k = top_k
        # keep the top k nearest neighbors
        current_embedding = embeddings[i]
        dist = np.linalg.norm(embeddings[:i] - current_embedding, axis=1)
        # indices = np.argsort(dist)[:k]
        indices = np.argsort(dist)
        # now require the top k nearest neighbors coming from different groups
        group_set = set()
        tmp = []
        j = 0
        while len(group_set) < k:
            if rule_group_dict[indices[j]] not in group_set:
                group_set.add(rule_group_dict[indices[j]])
                tmp.append(indices[j])
            j += 1
            if j == i:
                break
        indices = tmp

    print(indices)

    prompt = all_rules[i] + '\n'
    prompt += "Please select the rewrite rule that is strictly the same as the above rule and give your explanation (just give one answer). If not, please select the first item “Unseen rule”.\n"
    prompt += "1. Unseen rule\n"
    for j in range(len(indices)):
        prompt += str(j + 2) + '. ' + all_rules[indices[j]] + '\n'

    ans = m._open_ai_chat_completion(prompt)

    with open(log_f, 'a') as f:
        f.write('tpc-ds ' + str(rid_qid_reverse_dict[i]) + '\n')
        f.write(prompt + '\n')
        f.write("---------------------------------------\n")
        f.write(ans + '\n')
        f.write("=======================================\n")
    # extract the first line from ans
    ans = ans.split('\n')[0]

    # check which rule is selected
    selected_rule = -1
    for j in range(k):
        mark = str(j + 2) + '. '
        if mark in ans:
            selected_rule = indices[j]
            break

    print("selected rule: ", selected_rule)

    if selected_rule == -1:
        group_cnt += 1
        group_rule_list_dict[group_cnt] = [i]
        rule_group_dict[i] = group_cnt
    else:
        group_id = rule_group_dict[selected_rule]


        group_rule_list_dict[group_id].append(i)
        rule_group_dict[i] = group_id


    print("=======================================")

with open(output_text_file, 'w') as f:
    for k, v in group_rule_list_dict.items():
        f.write("group: " + str(k) + '\n')
        for i in v:
            f.write(all_rules[i] + '\n')
        f.write("=======================================\n")

with open(output_index_file, 'w') as f:
    for k, v in group_rule_list_dict.items():
        f.write("group " + str(k) + " : ")
        for i in v:
            f.write(str(i) + ' ')
        f.write("\n")
    
