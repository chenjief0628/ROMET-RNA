import numpy as np
import pandas as pd
import sys
import math


file=sys.argv[1]
save_file=sys.argv[2]

def gene_avgfd(file):
	

	df = pd.read_csv(file, delim_whitespace=True, header=0)

	df_sorted = df.sort_values(by=['Col1', 'Col2'])

	grouped = df_sorted.groupby([df_sorted['Col1'], df_sorted['Col2']])['Col5'].mean().reset_index()
	grouped.columns = ['Col1', 'Col2', 'mean_col5']  # 重命名列名
	# print(grouped)

	df_sorted = pd.merge(df_sorted, grouped, on=['Col1', 'Col2'])
	print(df_sorted)

	output_1 = df_sorted[(df_sorted['mean_col5'] >= 0.5) & (df_sorted['Col6'] <= 4)]

	output_2 = df_sorted[(df_sorted['mean_col5'] < 0.5) &  (df_sorted['Col6'] <= 6)]

	output = pd.concat([output_1, output_2])
	output.to_csv(save_file, sep='\t', index=False, header=False)

gene_avgfd(file)



