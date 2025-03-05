import os
import shutil
import glob
import csv
import collections


baseline_sp_file = 'speedup_analysis/tpcds/final_stats/baseline_llm_tpcds_speedup.csv'
genrewrite_sp_file = 'speedup_analysis/tpcds/final_stats/genrewrite_tpcds_speedup.csv'
lr_sp_file = 'speedup_analysis/tpcds/final_stats/lr_tpcds_speedup.csv'
llm_r2_sp_file = 'speedup_analysis/tpcds/final_stats/llm_r2_tpcds_speedup.csv'

speedup_dict = collections.defaultdict(dict)

with open(baseline_sp_file, 'r') as f:
    reader = csv.reader(f)
    next(reader)
    for row in reader:
        qid = row[0]
        speedup = float(row[1])
        speedup_dict[qid]['base_llm'] = speedup
        
with open(genrewrite_sp_file, 'r') as f:
    reader = csv.reader(f)
    next(reader)
    for row in reader:
        qid = row[0]
        speedup = float(row[1])
        speedup_dict[qid]['genrewrite'] = speedup
        
with open(lr_sp_file, 'r') as f:
    reader = csv.reader(f)
    next(reader)
    for row in reader:
        qid = row[0]
        speedup = float(row[1])
        speedup_dict[qid]['lr'] = speedup
        
with open(llm_r2_sp_file, 'r') as f:
    reader = csv.reader(f)
    next(reader)
    for row in reader:
        qid = row[0]
        speedup = float(row[1])
        speedup_dict[qid]['llm_r2'] = speedup

threshold = 0.5

# default speedup value is 1
for i in range(1, 100):
    k = str(i)
    
    speedup_dict[k]['base_llm'] = speedup_dict[k]['base_llm'] if 'base_llm' in speedup_dict[k] else 1
    speedup_dict[k]['genrewrite'] = speedup_dict[k]['genrewrite'] if 'genrewrite' in speedup_dict[k] else 1
    speedup_dict[k]['lr'] = speedup_dict[k]['lr'] if 'lr' in speedup_dict[k] else 1
    speedup_dict[k]['llm_r2'] = speedup_dict[k]['llm_r2'] if 'llm_r2' in speedup_dict[k] else 1
    
    # if speedup is smaller than 0.5, then set it to 1
    speedup_dict[k]['base_llm'] = 1 if speedup_dict[k]['base_llm'] < threshold else speedup_dict[k]['base_llm']
    speedup_dict[k]['genrewrite'] = 1 if speedup_dict[k]['genrewrite'] < threshold else speedup_dict[k]['genrewrite']
    speedup_dict[k]['lr'] = 1 if speedup_dict[k]['lr'] < threshold else speedup_dict[k]['lr']
    speedup_dict[k]['llm_r2'] = 1 if speedup_dict[k]['llm_r2'] < threshold else speedup_dict[k]['llm_r2']



# sort speedup_dict by integer qid
speedup_dict = dict(sorted(speedup_dict.items(), key=lambda item: int(item[0])))


data = dict()
data['qid'] = []
data['base_llm'] = []
data['genrewrite'] = []
data['lr'] = []
data['llm_r2'] = []

for k, v in speedup_dict.items():
    threshold = 2
    if v['base_llm'] > threshold or v['genrewrite'] > threshold or v['lr'] > threshold or v['llm_r2'] > threshold:
        print(k, v['base_llm'], v['genrewrite'], v['lr'], v['llm_r2'])
        data['qid'].append('Q' + k)
        data['base_llm'].append(v['base_llm'])
        data['genrewrite'].append(v['genrewrite'])
        data['lr'].append(v['lr'])
        data['llm_r2'].append(v['llm_r2'])



import pandas as pd
import matplotlib.pyplot as plt

# Convert dictionary to DataFrame
df = pd.DataFrame(data)

# To make the bars evenly distributed, we will use a sequence of numbers as the x-axis positions.
positions = list(range(len(df['qid'])))

fig, ax = plt.subplots(figsize=(22, 7))

# Set the scale of the y-axis to 'log'
ax.set_yscale('log')

max_val = max(df['base_llm'].max(), df['lr'].max(), df['llm_r2'].max(), df['genrewrite'].max())
ax.set_ylim(bottom=0.1, top=max_val * 6)

width = 0.18

colors = [plt.cm.Greys(0.9),  # light gray
          plt.cm.Greys(0.7),  # slightly darker
          plt.cm.Greys(0.5),  # medium gray
          plt.cm.Greys(0.3)]  # dark gray

ax.bar([p - 1.5*width for p in positions], df['lr'], width=width, 
       color=colors[3], align='center', label='LR')
ax.bar([p - 0.5*width for p in positions], df['llm_r2'], width=width, 
       color=colors[2], align='center', label='LLM-R2')
ax.bar([p + 0.5*width for p in positions], df['base_llm'], width=width, 
       color=colors[1], align='center', label='Baseline LLM')
ax.bar([p + 1.5*width for p in positions], df['genrewrite'], width=width, 
       color=colors[0], align='center', label='GenRewrite')


# Add some labels and title
# plt.xlabel('Query ID')
plt.ylabel('Speedup ratio - Log Scale')
# plt.title('Speedup Comparison on Log Scale')

# increase font sizes of title and labels
# ax.title.set_fontsize(25)
# ax.xaxis.label.set_fontsize(20)
ax.yaxis.label.set_fontsize(20)
ax.xaxis.label.set_fontsize(18)
# increase font size of legend



# Set the x-ticks to be the job IDs and rotate them for better readability
# plt.xticks(positions, df['qid'], rotation=90)
plt.xticks(positions, df['qid'])
# increase font size of x-ticks
plt.xticks(fontsize=14)
plt.yticks(fontsize=14)
# plt.legend()
plt.legend(fontsize=15, ncol=4, loc='upper center')
# ax.legend(loc='upper center', bbox_to_anchor=(0.5, 1.05), ncol=4)


# Show the plot
plt.show()
