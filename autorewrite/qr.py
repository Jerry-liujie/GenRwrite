from autorewrite.utils import *
from tqdm import tqdm

class QR:

    suggest_prompt = """
        Rewrite this query to improve performance.
        Describe the rewrite rules you are using (you must not include any specific query details in the rules, e.g., table names, column names, etc; For each rule, separate rule itself and its benefit with ':'). Be concise.
        Output template:
        Rewritten query:
        ...
        Rewrite rules:
        1. xxx
        2. xxx
        ...
        """
        
    suggest_with_hints_prompt = """
        Rewrite this query to improve performance. Only use this rule when rewriting: zzzzzz
        Do not use other rules.
        Output template:
        Rewritten query:
        ...
        Rewrite rules:
        ...
        """

    extract_constraint_prompt = """
        For each rule, identify the condition to apply the rule. One sentence for each rule.
        """
    
    semantic_check_prompt = """
        q1 is the original query and q2 is the rewritten query of q1.
        Break down each query step by step and then describe what it does in one sentence.
        Give an example, using tables, to show that these two queries are not equivalent if there's any such case. Otherwise, just say they are equivalent. Be concise.
        Your response must conclude with either 'They are equivalent.' or 'They are not equivalent.'
        """
    
    semantic_correct_prompt = """
        Based on your analysis, which part of q2 should be modified so that it becomes equivalent to q1? Make sure that all column names, table names and table aliases are correct. Show the modified version of q2. Be concise.    
        Output template:
        Analysis:
        xxx
        The complete q2 after correction:
        xxx
        """
    syntax_correct_prompt = """
        q1 is the original query and q2 is the rewritten query of q1.
        Below is the error returned by database when executing q2:
        zzzzzz
        Based on the error, which part of q2 should be modified so that it becomes equivalent to q1? Show the modified version of q2. Be concise.
        Output template:
        Analysis:
        xxx
        The complete q2 after correction:
        xxx
        """
    
    queries = []
    model = None
    log_files = []
    max_iterations = 0
    hint_list = []
    
    def __init__(self, model, queries, log_files, max_iterations=3, hint_list=None):
        self.model = model
        self.queries = queries
        self.log_files = log_files
        self.max_iterations = max_iterations
        self.hint_list = hint_list

    def suggest(self):
        rewrites = []
        rewrite_rules = []
        costs = []
        suggest_full_prompts = [x + self.suggest_prompt for x in self.queries]
        
        suggest_responses = self.model._chat_complete_batch(suggest_full_prompts)
        
        for response in suggest_responses:
            q2 = extract_query_from_LLM_response(response)
            q2_rules = extract_rewrite_rules_from_LLM_response(response)
            cost = response.cost
            rewrites.append(q2)
            rewrite_rules.append(q2_rules)
            costs.append(cost)

        for i in range(len(self.queries)):
            with open(self.log_files[i], 'a') as f:
                f.write(f"Original query: {self.queries[i]}\n")
                f.write(f"Rewritten query: {rewrites[i]}\n")
                f.write(f"Rewrite rules: {rewrite_rules[i]}\n")
                f.write(f"Cost: {costs[i]}\n")
                f.write("--------------------\n")
        

        return rewrites, rewrite_rules, costs
    
    def suggest_with_hints(self):
        rewrites = []
        rewrite_rules = []
        costs = []
        suggest_full_prompts = [x + self.suggest_with_hints_prompt for x in self.queries]
        # replace 'zzzzzz' with hint
        for i in range(len(self.queries)):
            suggest_full_prompts[i] = suggest_full_prompts[i].replace('zzzzzz', self.hint_list[i])
        
        suggest_responses = self.model._chat_complete_batch(suggest_full_prompts)
        
        for response in suggest_responses:
            q2 = extract_query_from_LLM_response(response)
            q2_rules = extract_rewrite_rules_from_LLM_response(response)
            cost = response.cost
            rewrites.append(q2)
            rewrite_rules.append(q2_rules)
            costs.append(cost)

        for i in range(len(self.queries)):
            with open(self.log_files[i], 'a') as f:
                f.write(f"Prompt: {suggest_full_prompts[i]}\n")
                f.write(f"Original query: {self.queries[i]}\n")
                f.write(f"Rewritten query: {rewrites[i]}\n")
                f.write(f"Rewrite rules: {rewrite_rules[i]}\n")
                f.write(f"Cost: {costs[i]}\n")
                f.write("--------------------\n")
        

        return rewrites, rewrite_rules, costs



    def semantic_correct(self, rewrites):
        final_rewrites = []
        costs = []
        iterations = []
        
        # Initialize tqdm for the outer loop
        for i in tqdm(range(len(self.queries)), desc="semantic correction"):
            q1 = self.queries[i]
            q2 = rewrites[i]
            log_file = self.log_files[i]

            equivalent = False
            iter = 0
            cost = 0

            while True:
                semantic_check_full_prompt = f"q1: {q1}\n\nq2: {q2}\n\n" + self.semantic_check_prompt
                response = self.model._open_ai_chat_completion(semantic_check_full_prompt)

                with open(log_file, 'a') as f:
                    f.write(f"Semantic check Round: {iter}\n")
                    f.write(f"Semantic check: {response.content}\n")

                ans = response.content
                cost += response.cost
                equiv_result = check_equivalence_from_analysis(ans)
                if not equiv_result:
                    tmp = [
                        {
                            "role": "user",
                            "content": semantic_check_full_prompt
                        },
                        {
                            "role": "assistant",
                            "content": ans
                        },
                        {
                            "role": "user",
                            "content": self.semantic_correct_prompt
                        }
                    ]
                else:
                    equivalent = True
                    break

                if iter == self.max_iterations:
                    break
                iter += 1

                response = self.model._open_ai_chat_completion_msg(tmp)

                with open(log_file, 'a') as f:
                    f.write(f"Semantic correct: {response.content}\n")
                    f.write("--------------------\n")

                raw_new_rewrite = response.content
                cost += response.cost
                q2 = truncate_query(raw_new_rewrite)
        
            if not equivalent:
                q2 = ""

            final_rewrites.append(q2)
            costs.append(cost)
            iterations.append(iter)
            
        return final_rewrites, costs, iterations

                

    

    def syntax_correct(self, rewrites, database_manager):
        final_rewrites = []
        costs = []
        iterations = []
        
        # Initialize tqdm for the outer loop
        for i in tqdm(range(len(self.queries)), desc="syntax correction"):
            q1 = self.queries[i]
            q2 = rewrites[i]
            log_file = self.log_files[i]

            # if q2 is empty, then skip the syntax correction
            if not q2:
                print("q2 is empty")
                final_rewrites.append(q2)
                costs.append(0)
                iterations.append(0)
                continue

            equivalent = False
            iter = 0
            cost = 0

            while True:
                error_msg = ''
                output = database_manager.explain_query([q2])
                    
                if len(output[0]) == 1:
                    if iter == self.max_iterations:
                        break
                    iter += 1

                    error_msg = output[0][0]
                    syntax_correct_full_prompt = f"q1: {q1}\n\nq2: {q2}\n\n" + self.syntax_correct_prompt.replace("zzzzzz", error_msg)
                    response = self.model._open_ai_chat_completion(syntax_correct_full_prompt)
                    ans = response.content
                    cost += response.cost

                    with open(log_file, 'a') as f:
                        f.write(f"Syntax check Round: {iter}\n")
                        f.write(f"Error message: {error_msg}\n")
                        f.write(f"Syntax check: {response.content}\n")
                        f.write("--------------------\n")

                    if 'The complete q2 after correction:' in ans:
                        ans = ans.split('The complete q2 after correction:')[1]
                    q2 = truncate_query(ans)
                else:
                    equivalent = True
                    break

            if not equivalent:
                q2 = ""

            final_rewrites.append(q2)
            costs.append(cost)
            iterations.append(iter)
            
        return final_rewrites, costs, iterations
