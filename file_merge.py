import numpy as np
import pandas as pd
import sys

def param_merge(file1_txt,file2_txt,file3_txt):
    data1 = pd.read_csv(file1_txt, sep='\s+', header=None)
    data2 = pd.read_csv(file2_txt, sep='\s+', header=None)
    # 合并DataFrame，前2列相等
    merged_data = pd.merge(data1, data2, left_on=[data1.columns[0], data1.columns[1]], right_on=[data2.columns[0], data2.columns[3]])#on=[0,1]
#    print(merged_data)

    merged_data.to_csv(file3_txt, sep='\t', header=False, index=False)


file1_txt = sys.argv[1] #loci
file2_txt = sys.argv[2] #ptmscore
file3_txt = sys.argv[3] #merge

param_merge(file1_txt,file2_txt,file3_txt)
