import pandas as pd
import numpy as np
import sys

type=sys.argv[1]

input_txt=sys.argv[2]   
save_txt=sys.argv[3]
if type == "ptmscore":
    df = pd.read_csv(input_txt, sep='\s+', header=None, names=['Col1', 'Col2', 'Col3', 'Col4', 'Col5'])
    df['Col6'] = df.groupby(['Col1', 'Col2'])['Col5'].rank(method='first', ascending=False)
    df.to_csv(save_txt, sep='\t', index=False)
elif type == "meta":    
    df = pd.read_csv(input_txt, sep='\s+', header=None, names=['Col1', 'Col2', 'Col3', 'Col4', 'Col5', 'Col6', 'Col7', 'Col8', 'Col9'])
    # 按第一列分组，并对每个分组的第四列进行排序
    df['Col10'] = df.groupby('Col1')['Col9'].rank(method='first', ascending=False).astype(int)
    df.to_csv(save_txt, sep='\t', index=False, header=False)
print(save_txt)



