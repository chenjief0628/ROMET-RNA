import numpy as np
import pandas as pd
import sys
import math


file=sys.argv[1]
save_file=sys.argv[2]

def gene_avgfd(file):
	
    # 读取 TXT 文件并命名列
	df = pd.read_csv(file, delim_whitespace=True, header=0)

    # 按照第一列和第六列进行排序
	df_sorted = df.sort_values(by=['Col1', 'Col2'])

	# 计算每个分组的第五列的平均值
	grouped = df_sorted.groupby([df_sorted['Col1'], df_sorted['Col2']])['Col5'].mean().reset_index()
	grouped.columns = ['Col1', 'Col2', 'mean_col5']  # 重命名列名
	# print(grouped)

	# 合并平均值到原数据框
	df_sorted = pd.merge(df_sorted, grouped, on=['Col1', 'Col2'])
	print(df_sorted)

	# 输出平均值大于0.7且第7列等于1的行
	output_1 = df_sorted[(df_sorted['mean_col5'] >= 0.5) & (df_sorted['Col6'] <= 4)]

	# 输出平均值大于0.6且第7列小于或等于2的行
	output_2 = df_sorted[(df_sorted['mean_col5'] < 0.5) &  (df_sorted['Col6'] <= 6)]
	# 将结果保存到文件
	output = pd.concat([output_1, output_2])
	output.to_csv(save_file, sep='\t', index=False, header=False)

gene_avgfd(file)



