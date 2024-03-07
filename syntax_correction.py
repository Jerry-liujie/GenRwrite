import os
from datetime import datetime
from autorewrite.openai import Gpt4
from autorewrite.utils import truncate_query
from autorewrite.database_manager.psql_database_manager import PSQLDatabaseManager

log_dir = "logs/"
result_dir = "exp_results/"
query_dir = "benchmark/tpcds/formatted_queries/"
timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
date = 'xxx'
max_iteration = 5

m = Gpt4()
model = m.model

syntax_err_prompt = "q1 is the original query and q2 is the rewritten query of q1.\n"
syntax_err_prompt = syntax_err_prompt + "Below is the error returned by database when executing q2:\nhole\n\n"
syntax_err_prompt = syntax_err_prompt + "Based on the error, which part of q2 should be modified so that it becomes equivalent to q1? Show the modified version of q2. Be concise."
syntax_err_prompt = syntax_err_prompt + "\nOutput template:\n\nAnalysis: xxx\n\nThe complete q2 after correction:\nxxx"

# get database manager
database_manager = PSQLDatabaseManager("localhost", "vldb", "VLDB2022")
database_manager.connect_to_db("tpcds", "public")
database_manager.tmp_db_name = "tpcds"
database_manager.tmp_schema_name = "public"


for run in range(4):
    label = date + '_' + str(run)
    print("----------------------------------------")
    print("Run " + str(run) + " starts.")

    # read final_equiv.txt and input queries
    d = dict()
    input_d = dict()
    for folder in os.listdir(result_dir):
        if '_' in folder:
            continue
        f_p = os.path.join(result_dir, folder)
        qid = folder

        input_query_p = os.path.join(query_dir, folder + ".sql")
        with open(input_query_p) as f:
            query = f.read()
            input_d[qid] = truncate_query(query)

        fname = qid + "_" + model + "_semantic_check_"+ label + ".txt"
        # fname = qid + "_" + model + "_rewrite_"+ label + ".sql"
        if fname in os.listdir(f_p):
            with open(os.path.join(f_p, fname)) as f:
                query = f.read()
                d[qid] = truncate_query(query)

    print(len(d))


    iteration = 0
    while len(d) > 0:
        print("size of d: " + str(len(d)))
        new_d = dict()
        for k, v in d.items():
            error_msg = ''
            output = database_manager.explain_query([v])
            if len(output[0]) == 1:
                # print("query " + k + " has syntax error")
                error_msg = output[0][0]

                # correct the query using the error message
                correction_input = "q1: " + input_d[k] + "\n\nq2: " + d[k] + "\n\n"
                correction_prompt = correction_input + syntax_err_prompt.replace("hole", error_msg)
                res = m._open_ai_chat_completion(correction_prompt)
                if 'The complete q2 after correction:' in res:
                    res = res.split('The complete q2 after correction:')[1]
                new_rewrite = truncate_query(res)
                new_d[k] = new_rewrite

                # [TODO] write to log file
                with open(os.path.join(log_dir, k, k + "_" + model + "_explain_err_" + timestamp + ".txt"), 'a') as f:
                    f.write(error_msg)
                    f.write("\n\n")
                    f.write("----------------------------------------\n\n")
                    f.write(correction_prompt)
                    f.write("\n\n")
                    f.write("----------------------------------------\n\n")
                    f.write(res)
                    f.write("\n\n")
                    f.write("========================================\n\n")

            else:
                # write to result file
                with open(os.path.join(result_dir, k, k + "_" + model + "_syntax_check_" + label + ".txt"), 'w') as f:
                    f.write(v)

        d = new_d
        print("size of d: " + str(len(d)))
        print(d.keys())
        print("iteration: " + str(iteration))
        iteration += 1
        if iteration >= max_iteration:
            break



