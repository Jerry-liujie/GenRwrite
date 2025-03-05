"""Util functions for autorewrite."""

import tiktoken
import os
import re

def count_tokens(text: str) -> int:
    """Count the number of tokens in a text."""
    # other models can be used here, e.g. "gpt-3.5-turbo"
    encoding = tiktoken.encoding_for_model("gpt-4")
    return len(encoding.encode(text))


def load_tpcds_formatted_queries(path : str) -> list[str]:
    """Load a list of queries from the benchmarks directory."""
    files = os.listdir(path)
    queries = []
    for file in files:
        with open(f"{path}/{file}") as f:
            queries.append(f.read())
    return queries

def truncate_query(sql):
    # keep parts between two ' unchanged and convert the rest to lowercase
    sql = sql.split("'")
    for i in range(0, len(sql), 2):
        sql[i] = sql[i].lower()

    sql = "'".join(sql)

    # if query contains '```', then only keep the part between the first and the second '```'
    if '```' in sql:
        sql = sql.split('```')[1]
        sql = sql.split('```')[0]

    if not sql.startswith("select ") and not sql.startswith("with "):
        # only keep the part after the first select or first with (inclusive)
        sql1 = sql[sql.find("select"):]
        sql2 = sql[sql.find("with"):]
        # keep the longer one
        if len(sql1) > len(sql2):
            sql = sql1
        else:
            sql = sql2

    sql = " ".join(sql.split())
    sql = sql.strip()

    # print(sql)

    return sql

def check_equivalence_from_analysis(analysis):
    if "not equivalent." in analysis:
        return False
    elif "equivalent." in analysis:
        return True
    else:
        return False
    
def extract_query_from_LLM_response(response):
    # return response.split("Rewrite rules:")[0].split("Rewritten query:")[1].strip()
    try:
        q2 = response.content.split("Rewrite rules:")[0]
        q2 = q2.split("Rewritten query:")[1]
        q2 = truncate_query(q2)
    except:
        q2 = ''
    return q2

def extract_rewrite_rules_from_LLM_response(response):
    try:
        rules = response.content.split("Rewrite rules:")[1].strip()
    except:
        rules = ''
    return rules


def extract_cost_from_explain(tuples_list):
    cost_pattern = re.compile(r'cost=(\d+\.\d+)\.\.(\d+\.\d+)')
    
    for item in tuples_list:
        for element in item:
            if isinstance(element, str):  # Ensure the element is a string
                match = cost_pattern.search(element)
                if match:
                    start_cost = float(match.group(1))
                    end_cost = float(match.group(2))
                    return end_cost
    return None

def extract_plan_summary_from_summary_string(s):
    try:
        summary = s.split("Performance bottlenecks:")[1].split("Rewrite rules:")[0].strip()
    except:
        summary = ''
    return summary
    
def extract_rewrite_rules_from_summary_string(s):
    try:
        rules = s.split("Rewrite rules:")[1].strip()
    except:
        rules = ''
    return rules