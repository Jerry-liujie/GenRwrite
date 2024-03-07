
import os
import csv
import collections
import numpy as np
from datetime import datetime
from autorewrite.utils import truncate_query

# the goal is to select the top 3 rewrite rules for each query
qid_info_dict = collections.defaultdict(dict) # qid -> [(rewrite_id -> rewrite, speedup, rules), ...]  # TODO: embedding
rid_info_dict = collections.defaultdict(dict) # rid -> (rule, qid, group_id)   speedup is optional
group_info_dict = collections.defaultdict(dict) # groupid -> (rules, avg_speedup, qids)

initial_test_without_hints = 'xxx'
performamce_evaluation_result_path = 'xxx'
correctness_checking_result_path = 'xxx'
log_dir = "xxx"
result_dir = "xxx"

all = collections.defaultdict(dict)  # (qid) -> {method: (runtime, cost, query)}
with open(performamce_evaluation_result_path, 'r') as f:
    reader = csv.reader(f)
    next(reader)
    # pid,qid,query,status,runtime,cost,plan,extra
    for row in reader:
        label = row[1].split("-")
        qid = int(label[0])
        method = label[1]
        all[qid][method] = (float(row[4]), float(row[5]), row[2])

for qid in all:
    qid_info_dict[qid]['query'] = all[qid]['input'][2]


equiv_dict = collections.defaultdict(list)
with open(correctness_checking_result_path, 'r') as f:
    reader = csv.reader(f)
    next(reader)
    # pid,qid,query
    for row in reader:
        label = row[1].split("-")
        qid = int(label[0])
        method = label[1]
        if 'only' not in method and 'syntax' in method:
            equiv_dict[qid].append(method)

# only use the rewrite with max speedup
for qid, methods in equiv_dict.items():
    max_speedup = 0
    max_method = ''
    for method in methods:
        # using runtime to calculate speedup
        speedup = all[qid]['input'][0] / all[qid][method][0]
        # using cost to calculate speedup
        # speedup = all[qid]['input'][1] / all[qid][method][1]
        if speedup > max_speedup:
            max_speedup = speedup
            max_method = method
    qid_info_dict[qid]['speedup'] = max_speedup
    qid_info_dict[qid]['rewrite'] = all[qid][max_method][2]
    qid_info_dict[qid]['batch'] = int(max_method[-1])

qid_rid_file = 'xxx'
group_assignment_file = 'xxx'
cnt = 0
with open(qid_rid_file, 'r') as f:
    for line in f:
        line = line.strip()
        if len(line) == 0:
            continue
        # if line is a integer, then it is a query id
        if line.isdigit():
            query_id = int(line)
            qid_info_dict[query_id]['rules'] = []
        elif line.startswith('batch'):
            current_batch = int(line.split(' ')[1])
        else:
            if current_batch == qid_info_dict[query_id]['batch']:
                line = line.split('. ')[1].strip()
                qid_info_dict[query_id]['rules'].append(cnt)
                rid_info_dict[cnt]['rule'] = line
                rid_info_dict[cnt]['qid'] = query_id
            else:
                rid_info_dict[cnt]['rule'] = line
            cnt += 1



# read group assignment
with open(group_assignment_file, 'r') as f:
    # group 0 : 0 5 51 65 111 129
    for line in f:
        line = line.strip()
        if len(line) == 0:
            continue
        line = line.split(':')
        group_id = int(line[0].split()[1])
        # remove empty rids when split
        rids = [int(x) for x in line[1].split()]

        rids = [rid for rid in rids if rid in rid_info_dict and 'qid' in rid_info_dict[rid]]
        if len(rids) == 0:
            continue

        group_info_dict[group_id]['rules'] = rids
        group_info_dict[group_id]['qids'] = set()
        for rid in rids:
            group_info_dict[group_id]['qids'].add(rid_info_dict[rid]['qid'])
            rid_info_dict[rid]['group_id'] = group_id

# calculate geometric average speedup for each group
for group_id in group_info_dict:
    # calculate geometric mean speedup
    geo_mean = 1
    for qid in group_info_dict[group_id]['qids']:
        geo_mean *= qid_info_dict[qid]['speedup']
    group_info_dict[group_id]['avg_speedup'] = geo_mean ** (1.0 / len(group_info_dict[group_id]['qids']))

    # print("group_id: ", group_id)
    # print("avg_speedup: ", group_info_dict[group_id]['avg_speedup'])


# just fortesting
for qid in qid_info_dict:
    if qid not in [74]:
        continue
    if "speedup" in qid_info_dict[qid]:
        print("qid: ", qid)
        print("speedup: ", qid_info_dict[qid]['speedup'])
        print("batch: ", qid_info_dict[qid]['batch'])
        for rid in qid_info_dict[qid]['rules']:
            print(rid_info_dict[rid]['rule'])
        print("=====================================")

already_optimized_query_file = 'xxx'
optimized_qs = []
with open(already_optimized_query_file, 'r') as f:
    for line in f:
        line = line.strip()
        if len(line) == 0:
            continue
        qid = int(line)
        optimized_qs.append(qid)


# calculate pairwise similarity between queries
import torch
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.metrics.pairwise import euclidean_distances
from autorewrite.openai import Gpt4
from transformers import LongformerModel, LongformerTokenizer
tokenizer = LongformerTokenizer.from_pretrained("allenai/longformer-base-4096")
model = LongformerModel.from_pretrained("allenai/longformer-base-4096")

m = Gpt4()
model_name = m.model

# topk similar queries
topk = 3
# num_rules_in_hints is the number of rules that will be included in the hints
num_rules_in_hints = 5

timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
# extract date from timestamp, format: mmdd
date = timestamp[4:8]

qid_selected_rules = collections.defaultdict(list) # qid -> [selected_rules]
selected_rule_file = 'xxx'

# sort qid_info_dict by qid
qid_info_dict = dict(sorted(qid_info_dict.items(), key=lambda item: item[0]))
sql_queries = [info['query'] for qid, info in qid_info_dict.items()]
encoded_queries = [tokenizer(query, return_tensors='pt') for query in sql_queries]
with torch.no_grad():
    embeddings = [model(**query)['last_hidden_state'].mean(dim=1).squeeze().numpy() for query in encoded_queries]

# similarity_matrix = cosine_similarity(embeddings, embeddings)
distance_matrix = euclidean_distances(embeddings, embeddings)

print("topk: ", topk)
for i in range(len(sql_queries)):

    if i+1 in optimized_qs:
        continue

    top_neighbors = [j for j in distance_matrix[i].argsort()]
    top_distances = [distance_matrix[i][j] for j in distance_matrix[i].argsort()]
    # since the first element is the query itself, the distance is 0, we need to do some adjustment
    distance_matrix[i][i] = top_distances[1]

    print("query: ", i+1)
    print("queries: ", [j+1 for j in distance_matrix[i].argsort()[:topk]])


    selected_cnt = 0
    tmp_neighbors = []
    tmp_distances = []
    for j in top_neighbors:
        # the real query id is j + 1
        if j + 1 in equiv_dict.keys():
            tmp_neighbors.append(j + 1)
            tmp_distances.append(distance_matrix[i][j])
            # tmp_similarities.append(similarity_matrix[i][j])
            selected_cnt += 1
        if selected_cnt == topk:
            break

    top_neighbors = tmp_neighbors
    top_distances = tmp_distances
    print("Neighbors: ", top_neighbors)

    top_distances = np.array(top_distances)
    weights = 1 / top_distances
    weights /= np.sum(weights)

    print("Weights: ", weights)

    group_pref_dict = collections.defaultdict(dict) # group_id -> {selected_rule, current_max, total_score}
    for idx, qid in enumerate(top_neighbors):
        for rid in qid_info_dict[qid]['rules']:
            group_id = rid_info_dict[rid]['group_id']
            if group_id not in group_pref_dict:
                group_pref_dict[group_id]['current_max'] = 0
                group_pref_dict[group_id]['total_score'] = 0

            tmp_max = qid_info_dict[qid]['speedup'] * weights[idx]
            if tmp_max > group_pref_dict[group_id]['current_max']:
                group_pref_dict[group_id]['current_max'] = tmp_max
                group_pref_dict[group_id]['selected_rule'] = rid
            
            group_pref_dict[group_id]['total_score'] += group_info_dict[group_id]['avg_speedup'] * weights[idx]
    
    # rank groups by total score
    sorted_group_ids = sorted(group_pref_dict, key=lambda x: group_pref_dict[x]['total_score'], reverse=True)
    # select top 5 groups
    selected_groups = sorted_group_ids[:num_rules_in_hints]
    selected_rules = [group_pref_dict[group_id]['selected_rule'] for group_id in selected_groups]
    qid_selected_rules[i] = selected_rules


    print("selected rules: ", selected_rules)
    for rid in selected_rules:
        print(rid_info_dict[rid]['rule'])
    print("===================================================================")


    

    # with open(selected_rule_file, 'w') as f:
    #     # join using comma
    #     f.write(str(i) + ': ' + ', '.join([str(rid) for rid in selected_rules]) + '\n')


   

    # ask LLM to rewrite the query using the selected rules
    round_1_prompt = "\n\n" + "Rewrite this query to improve performance. Describe the rewrite rules you are using (you must not include any specific query details in the rules, e.g., table names, column names, etc; For each rule, separate rule itself and its benefit with ':'). Be concise.\n"
    # optional: add hints ========================
    # round_1_prompt += 'Here are some hints that you might consider when rewriting the query:\n'
    round_1_prompt += 'Feel free to consider the following hints as you rewrite the query, but you are not limited to them. You have the freedom to apply other rewrite rules as well.\n\n'
    for r in selected_rules:
        round_1_prompt += rid_info_dict[r]['rule'] + '\n'
    # round_1_prompt += "\nNote that you have the freedom to not use these rules and you also have the freedom to apply other rewrite rules not listed here.\n"
    round_1_prompt += "\nOutput template: \n\n" + "Rewritten query:\n...\n\nRewrite rules:\n1. xxx\n2. xxx\n..."
    complete_query = truncate_query(sql_queries[i]) + round_1_prompt

    result = m._open_ai_chat_completion(complete_query)

    rewritten_q = result.split("Rewrite rules:")[0]
    rewritten_q = rewritten_q.split("Rewritten query:")[1]
    rewritten_q = rewritten_q.strip()

    rewrite_rules = result.split("Rewrite rules:")[1]
    rewrite_rules = rewrite_rules.strip()

    per_query_log_folder = log_dir + str(i+1) + '/'
    per_query_result_folder = result_dir + str(i+1) + '/'
    
    # rewritten_q_file = per_query_result_folder + str(i+1) + '_' + model_name + '_rewrite_' + date + '_with_hints_official.sql'
    rewritten_q_file = per_query_result_folder + str(i+1) + '_' + model_name + '_rewrite_' + date + '_with_hints_explain.sql'
    with open(rewritten_q_file, 'w') as f:
        f.write(rewritten_q)

    # rewrite_rules_file = per_query_result_folder + str(i+1) + '_' + model_name + '_rules_' + date + '_with_hints_official.txt'
    rewrite_rules_file = per_query_result_folder + str(i+1) + '_' + model_name + '_rules_' + date + '_with_hints_explain.txt'
    with open(rewrite_rules_file, 'w') as f:
        f.write(rewrite_rules)

    # log_file = per_query_log_folder + str(i+1) + '_' + model_name + '_' + timestamp + '_with_hints.txt'
    log_file = per_query_log_folder + str(i+1) + '_' + model_name + '_' + timestamp + '_with_hints_explain.txt'
    with open(log_file, 'w') as f:
        f.write(complete_query)
        f.write("\n----------------------------------------\n")
        f.write(result)


