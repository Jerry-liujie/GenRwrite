import os
import duckdb
import hashlib
import csv
import tqdm
import sys

# tpcds
test_queries_folder = sys.argv[1]
output_equiv_result_file = sys.argv[2]
db_paths = ['200G_tpcds_duckdb.db', '10G_tpcds_duckdb.db']
# db_paths = ['imdb_duckdb.db']


output_directory = os.path.dirname(output_equiv_result_file)
# Create the directory if it doesn't exist
if not os.path.exists(output_directory):
    os.makedirs(output_directory)


query_files = os.listdir(test_queries_folder)
query_files = tqdm.tqdm(query_files)

queries = dict()
m_signature = dict()
equiv_results = dict()
for query_file in query_files:
    # check if the file is a .sql file
    if not query_file.endswith('.sql'):
        continue
    qid = query_file.split('.')[0]
    
    # use os path join to avoid path issues
    with open(os.path.join(test_queries_folder, query_file), 'r') as f:
        query = f.read()
        
        queries[qid] = query
        m_signature[qid] = []
        # print(f'{query}')


for db_path in db_paths:
    print(f'Connecting to {db_path}...')
    con = duckdb.connect(db_path)
    # show progress bar
    for k, v in tqdm.tqdm(queries.items()):
        query = v
        try:
            result = con.execute(query)
        except Exception as e:
            # Print the error message when an exception occurs
            print(f'Query {k} failed: {e}')
            continue
        
        if result is None:
            print(f'Query {k} returns None')
            continue
        else:
            rows = result.fetchall()
            if len(rows) == 0:
                m_signature[k].append('empty')
                continue
            rows_str = str(rows).encode()
            signature = hashlib.sha256(rows_str).hexdigest()
            m_signature[k].append(signature)
    
    

        
for k, v in m_signature.items():
    if '_' not in k:
        continue
    if len(v) != len(db_paths):
        print(f'Query {k} has errors')
        equiv_results[k] = 'error'
        continue
    
    qid = k.split('_')[0]
    if qid not in m_signature:
        continue
    original_signature = m_signature[qid]
    if original_signature != v:
        equiv_results[k] = 'nonequiv'
    # else if every signature in original_signature is 'empty', then the query is 'empty'
    elif all([x == 'empty' for x in original_signature]):
        equiv_results[k] = 'unknown'
    else:
        equiv_results[k] = 'equiv'
        

with open(output_equiv_result_file, 'w') as f:
    writer = csv.writer(f)
    writer.writerow(['query', 'result'])
    for k, v in equiv_results.items():
        writer.writerow([k, v])
