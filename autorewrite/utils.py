"""Util functions for autorewrite."""

import tiktoken
import os

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