from autorewrite.gpt import O3Mini, O1, Gpt4oMini, Gpt4o, Gpt4
from autorewrite.qr import QR
from autorewrite.database_manager.psql_database_manager import PSQLDatabaseManager, database_connection
from autorewrite.utils import extract_cost_from_explain
import os
from datetime import datetime
import csv
import time

m = O3Mini()
model = m.model
max_correct_iteration = 3


benchmark_name = "imdb"
# specify input and output directories
query_dir = "benchmark/imdb/job_queries/"
# query_dir = "benchmark/join-order-benchmark/job_queries/"
log_dir = "logs/"
result_dir = "exp_results/"

# get label for result file
timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
# I want to the timestamp to include the minute level
label = benchmark_name + "_" + model + '_' + timestamp[4:13]
result_file = result_dir + label + ".csv"

# configure database manager
database_manager = PSQLDatabaseManager("localhost", "vldb", "VLDB2022")
database_manager.connect_to_db(benchmark_name, "public")

# read queries
query_list = []
qid_list = []
per_query_log_folders = []

for file in os.listdir(query_dir):
    f_p = os.path.join(query_dir, file)
    id = file.split(".")[0]
    if '_' in id:
        continue


    if os.path.isfile(f_p):
        with open(f_p) as f:
            query = f.read()
            query_list.append(query)
            qid_list.append(id)

    # create log folder for each query
    per_query_log_folder = log_dir + benchmark_name + "/" + id + "/"
    if not os.path.exists(per_query_log_folder):
        os.makedirs(per_query_log_folder)
    per_query_log_folders.append(per_query_log_folder)

# ================== start rewriting ==================
with open(result_file, 'w') as f:
    writer = csv.writer(f)
    writer.writerow(["qid", "round", "query", "rewrite_r1", "rewrite_r2", "rewrite", "total_cost", "suggest_cost", "semantic_cost", "syntax_cost", "semantic_iterations", "syntax_iterations", "query_explain_cost", "rewrite_explain_cost"])

num_candidates_wanted = 4
for round in range(num_candidates_wanted):
    print(f"Candidate {round}")
    
    # also add model information to the log file
    # orignal: this_round_log_files = [f"{f}{timestamp}_round_{round}.txt" for f in per_query_log_folders]
    this_round_log_files = [f"{f}{model}_{timestamp}_round_{round}.txt" for f in per_query_log_folders]
    
    
    start_time = time.time()
    
    rewriter = QR(m, query_list, this_round_log_files, max_correct_iteration)
    rewrites, rules, suggest_cost = rewriter.suggest()
    end_time = time.time()
    print(f"Suggestion time: {end_time - start_time}")
    print("Finish suggestion")

    start_time = time.time()
    rewrites_after_semantic_check, semantic_cost, semantic_iterations = rewriter.semantic_correct(rewrites)
    end_time = time.time()
    print(f"Semantic correction time: {end_time - start_time}")
    print("Finish semantic correction")
    
    start_time = time.time()
    rewrites_after_syntax_check, syntax_cost, syntax_iterations = rewriter.syntax_correct(rewrites_after_semantic_check, database_manager)
    end_time = time.time()
    print(f"Syntax correction time: {end_time - start_time}")
    print("Finish syntax correction")
    
    total_cost = [suggest_cost[i] + semantic_cost[i] + syntax_cost[i] for i in range(len(query_list))]
    
    res = database_manager.explain_query(query_list)
    query_explain_cost =[extract_cost_from_explain(r) for r in res]
    
    res = database_manager.explain_query(rewrites_after_syntax_check)
    rewrite_explain_cost =[extract_cost_from_explain(r) for r in res]

    with open(result_file, 'a') as f:
        writer = csv.writer(f)
        for i in range(len(query_list)):
            writer.writerow([qid_list[i], round, query_list[i], rewrites[i], rewrites_after_semantic_check[i], rewrites_after_syntax_check[i], total_cost[i], suggest_cost[i], semantic_cost[i], syntax_cost[i], semantic_iterations[i], syntax_iterations[i], query_explain_cost[i], rewrite_explain_cost[i]])

database_manager.close_connection()