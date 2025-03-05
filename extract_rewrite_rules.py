import os

db_name = 'tpcds'
label = 'xxxxx'
input_log_folder = 'logs/' + db_name + '/'
output_rule_folder = 'rewrite_rules/' + db_name + '/' + label + '/'

# for folder under input_log_folder
for folder in os.listdir(input_log_folder):
    if not os.path.isdir(os.path.join(input_log_folder, folder)):
        continue
    
    qid = folder

    
    query_output_folder = os.path.join(output_rule_folder, qid)
    if not os.path.exists(query_output_folder):
        os.makedirs(query_output_folder)
    
    print(f'Processing {qid}...')

    # for file under folder
    for file in os.listdir(os.path.join(input_log_folder, folder)):
        if not file.endswith('.txt'):
            continue
        
        # if file does not start with 'o3-mini_20250222-202639', skip
        # if not file.startswith('o3-mini_20250222-202639'):
        #     continue
        
        round_num = file.split('.')[0].split('_')[-1]

        # read file content
        with open(os.path.join(input_log_folder, folder, file), 'r') as f:
            content = f.read()
            # find text between 'Rewrite rules:' and 'Cost: '
            content = content.split('Rewrite rules: ')[1].split('Cost: ')[0]
            # split content into rules
            rules = content.split('\n')
            # remove empty strings
            rules = [rule for rule in rules if rule]
            # if rule does not start with an integer, remove it
            rules = [rule for rule in rules if rule[0].isdigit()]
            # remove the first integer in each rule
            rules = [rule.split(' ', 1)[1] for rule in rules]
            
            for i in range(len(rules)):
                with open(os.path.join(query_output_folder, f'{round_num}_{i+1}.txt'), 'w') as f:
                    f.write(rules[i])
            