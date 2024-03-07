# p2: check if the rewritten query is equivalent to the original query by asking for counterexamples

from autorewrite.openai import Gpt4
from autorewrite.utils import check_equivalence_from_analysis, truncate_query
import os
from datetime import datetime

m = Gpt4()
model = m.model

max_iteration = 5

timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
date = 'xxx'
# folder paths
input_query_dir = "benchmark/tpcds/queries/"
log_dir = "logs/"
result_dir = "exp_results/"

# prompt for equivalence checking
equivalence_checking_prompt = "q1 is the original query and q2 is the rewritten query of q1.\nBreak down each query step by step and then describe what it does in one sentence."
equivalence_checking_prompt = equivalence_checking_prompt + "\nGive an example, using tables, to show that these two queries are not equivalent if there's any such case. Otherwise, just say they are equivalent. Be concise."
equivalence_checking_prompt = equivalence_checking_prompt + "\n\nYour response must conclude with either 'They are equivalent.' or 'They are not equivalent.'"

# prompt for correcting the rewritten query
correcting_prompt = "Based on your analysis, which part of q2 should be modified so that it becomes equivalent to q1? Make sure that all column names, table names and table aliases are correct. Show the modified version of q2. Be concise."
correcting_prompt = correcting_prompt + "\nOutput template:\n\nAnalysis: xxx\n\nThe complete q2 after modification:\nxxx"


for run in range(4):
    label = date + '_' + str(run)
    print("----------------------------------------")
    print("Run " + str(run) + " starts.")


    # read input queries and initial rewrites
    d = dict()

    for file in os.listdir(input_query_dir):
        id = file.split(".")[0]
        if '_' in id:
            continue
        log_file = log_dir + id+ '/'  + id + '_' + model + '_iterative_correction_' + label + '_' + timestamp + '.txt'
        with open(log_file, 'w') as f:
            pass

        f_p = os.path.join(input_query_dir, file)
        rewrite_p = os.path.join(result_dir, id, id + '_' + model + '_rewrite_' + label + '.sql')
        tmp = dict()
        
        if os.path.isfile(f_p):
            with open(f_p) as f:
                query = f.read()
                tmp['input'] = truncate_query(query)

            with open(rewrite_p) as f:
                rewrite = f.read()
                tmp['rewrite'] = truncate_query(rewrite)
        
        d[id] = tmp


    still_need_rewrite = True

    iteration = 0
    while still_need_rewrite:
        print("Iteration " + str(iteration) + " starts.")
        round_2_prompt_list = []
        for k, v in d.items():
            round_2_input = "q1: " + v['input'] + "\n\nq2: " + v['rewrite']
            round_2_prompt = round_2_input + "\n\n" + equivalence_checking_prompt
            round_2_prompt_list.append(round_2_prompt)
        results = m._chat_complete_batch(round_2_prompt_list)

        new_d = dict()
        idx = 0
        for  k, v in d.items():
            per_query_log_folder = log_dir + k + '/'         # e.g., logs/1
            per_query_result_folder = result_dir + k + '/'   # e.g., exp_results/1
            log_file = per_query_log_folder + k + '_' + model + '_iterative_correction_' + label + '_' + timestamp + '.txt'
            with open(log_file, 'a') as f:
                f.write(round_2_prompt_list[idx])
                f.write("\n----------------------------------------\n")
                f.write(results[idx])
                f.write("\n========================================\n")
                f.write("\n\n")
            equivalence = check_equivalence_from_analysis(results[idx])
            if not equivalence:
                new_d[k] = v
                tmp = [
                    {
                    "role": "user",
                    "content": round_2_prompt_list[idx]
                    },
                    {
                    "role": "assistant",
                    "content": results[idx]
                    },
                    {
                    "role": "user",
                    "content": correcting_prompt
                    }
                ]
                raw_new_rewrite = m._open_ai_chat_completion_msg(tmp)
                new_rewrite = truncate_query(raw_new_rewrite)
                new_d[k]['rewrite'] = new_rewrite

                with open(log_file, 'a') as f:
                    f.write(correcting_prompt)
                    f.write("\n----------------------------------------\n")
                    f.write(raw_new_rewrite)
                    f.write("\n========================================\n")
                    f.write("\n\n")

            else:
                # write to result file
                final_equiv_file = per_query_result_folder + k + '_' + model + '_semantic_check_' + label + '.txt'
                with open(final_equiv_file, 'w') as f:
                    f.write(d[k]['rewrite'])

            idx += 1

        print("Iteration " + str(iteration) + " ends.")
        print("size of d changes: " + str(len(d)) + " -> " + str(len(new_d)))
        # print elements in new_d
        print("queries that need to be rewritten: ")
        print(new_d.keys())
        print('---------------------------------')

        d = new_d
        iteration += 1

        if len(d) == 0:
            still_need_rewrite = False
        
        if iteration >= max_iteration:
            still_need_rewrite = False

    print("Done with iterative correction.")