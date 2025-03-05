from autorewrite.utils import *
from tqdm import tqdm

class PlanSummarizer:

    analyze_prompt = """
        Summarize the top 2 performance bottlenecks from the query plan in very concise language, focusing only on the most critical issues, and propose rewrite rules to improve performance.
        Format:
        Performance bottlenecks:
        1. xxx
        2. xxx
        Rewrite rules:
        1. xxx
        2. xxx
        ...
        """

    
    plans = []
    model = None
    log_files = []
    
    def __init__(self, model, plans, log_files):
        self.model = model
        self.plans = plans
        self.log_files = log_files

    def summarize(self):
        summaries = []
        costs = []
        analyze_full_prompts = [x + self.analyze_prompt for x in self.plans]
        
        analyze_responses = self.model._chat_complete_batch(analyze_full_prompts)
        
        for response in analyze_responses:
            summary = response.content
            cost = response.cost
            summaries.append(summary)
            costs.append(cost)

        for i in range(len(self.plans)):
            with open(self.log_files[i], 'a') as f:
                # write query plan and summary
                f.write(f"Original query plan: {self.plans[i]}\n")
                f.write(f"Summary: {summaries[i]}\n")
                f.write(f"Cost: {costs[i]}\n")
                f.write("--------------------\n")
        

        return summaries, costs
  