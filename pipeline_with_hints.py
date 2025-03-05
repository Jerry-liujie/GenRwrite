from autorewrite.gpt import O3Mini, O1, Gpt4oMini, Gpt4o, Gpt4
from autorewrite.qr import QR
from autorewrite.database_manager.psql_database_manager import PSQLDatabaseManager, database_connection
from autorewrite.utils import extract_cost_from_explain
import os
from datetime import datetime
import csv

m = O3Mini()
model = m.model
max_correct_iteration = 3

benchmark_name = "tpcds"
# specify input and output directories
query_dir = "benchmark/tpcds/queries/"
# query_dir = "benchmark/join-order-benchmark/job_queries/"
log_dir = "logs/" + benchmark_name + "/"
result_dir = "exp_results/"

# get label for result file
timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")

# I want to the timestamp to include the minute level
label = benchmark_name + "_" + model + '_' + timestamp[4:13]
result_file = result_dir + label + ".csv"

# configure database manager
database_manager = PSQLDatabaseManager("localhost", "vldb", "VLDB2022")
database_manager.connect_to_db(benchmark_name, "public")

# only do experiments on long running queries
long_running_query_file = "tpcds-queriy-list.txt"
long_running_query_ids = []
with open(long_running_query_file) as f:
    long_running_queries = f.readlines()
    # remove empty lines
    long_running_query_ids = [x.strip() for x in long_running_queries if x.strip()]




qid_list = []
query_list = []
hint_list = []
hint_id_list = []
per_query_log_folders = []
rewrite_rule_folder = "rewrite_rules/" + benchmark_name + "/ungrouped_rules/"


for subfolder in os.listdir(rewrite_rule_folder):
    subfolder_path = os.path.join(rewrite_rule_folder, subfolder)
    print(subfolder)
    if os.path.isdir(subfolder_path):
        qid = subfolder
        long_running_query_ids.append(qid)


for qid in long_running_query_ids:
    query_file = query_dir + qid + ".sql"
    with open(query_file) as f:
        query = f.read()
        rule_folder = os.path.join(rewrite_rule_folder, qid)
        # rule_folder = rewrite_rule_folder
        for file in os.listdir(rule_folder):
            if file.endswith(".txt"):
                with open(os.path.join(rule_folder, file)) as f:
                    hint = f.read()
                    query_list.append(query)
                    hint_list.append(hint)
                    hint_id_list.append(file.split(".")[0])
                    qid_list.append(qid)
                    
                    
    per_query_log_folder = log_dir + qid + "/"
    if not os.path.exists(per_query_log_folder):
        os.makedirs(per_query_log_folder)
        
print(f"Total number of queries: {len(query_list)}")

# ================== start rewriting ==================
with open(result_file, 'w') as f:
    writer = csv.writer(f)
    writer.writerow(["qid", "round", "query", "rewrite_r1", "rewrite_r2", "rewrite", "total_cost", "suggest_cost", "semantic_cost", "syntax_cost", "semantic_iterations", "syntax_iterations", "query_explain_cost", "rewrite_explain_cost", "rule_id", "rule"])

num_candidates_wanted = 2
for round in range(num_candidates_wanted):
    print(f"Candidate {round}")

    # this_round_log_files = [f"{f}{timestamp}_round_{round}.txt" for f in per_query_log_folders]
    log_files = []
    for i in range(len(qid_list)):
        log_file = f"{log_dir}{qid_list[i]}/{timestamp}_round_{round}_rule_{hint_id_list[i]}.txt"
        log_files.append(log_file)

    rewriter = QR(m, query_list, log_files, max_correct_iteration, hint_list)
    rewrites, rules, suggest_cost = rewriter.suggest_with_hints()
    print("Finish suggestion")

    rewrites_after_semantic_check, semantic_cost, semantic_iterations = rewriter.semantic_correct(rewrites)
    print("Finish semantic correction")
    
    rewrites_after_syntax_check, syntax_cost, syntax_iterations = rewriter.syntax_correct(rewrites_after_semantic_check, database_manager)
    print("Finish syntax correction")
    
    total_cost = [suggest_cost[i] + semantic_cost[i] + syntax_cost[i] for i in range(len(query_list))]
    
    res = database_manager.explain_query(query_list)
    query_explain_cost =[extract_cost_from_explain(r) for r in res]
    
    res = database_manager.explain_query(rewrites_after_syntax_check)
    rewrite_explain_cost =[extract_cost_from_explain(r) for r in res]

    with open(result_file, 'a') as f:
        writer = csv.writer(f)
        for i in range(len(query_list)):
            writer.writerow([qid_list[i], round, query_list[i], rewrites[i], rewrites_after_semantic_check[i], rewrites_after_syntax_check[i], total_cost[i], suggest_cost[i], semantic_cost[i], syntax_cost[i], semantic_iterations[i], syntax_iterations[i], query_explain_cost[i], rewrite_explain_cost[i], hint_id_list[i], hint_list[i]])

database_manager.close_connection()
