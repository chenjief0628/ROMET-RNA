#!/bin/bash

input_file=$1
ori_pdb_path=$2
save_pdb_dir=$3

while IFS=$'\t' read -r col1 col2 col3 col4 rest_of_line; do
  # 在这里可以对 col1 和 col4 进行操作
	echo "pdb_id: $col1"
	echo "=======pdb: $col4"
	if [ ! -d $save_pdb_dir ]; then
		mkdir $save_pdb_dir
	fi
	pdb1=$ori_pdb_path/${col4}.pdb
	if [ -f $pdb1 ]; then
		echo $pdb1
		cp $pdb1 $save_pdb_dir/
	fi
done < "$input_file"
echo "$save_pdb_dir"











