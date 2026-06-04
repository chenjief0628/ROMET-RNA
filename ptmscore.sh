#!/bin/bash

# 获取pdb路径
  
RNAalign_path=$1 #"/data/zt/software/RNAalign/RNAalign"
pdb_path=$2 
ptmscore_txt=$3
pdb_id=$4 
echo "pdb_id:$pdb_id"
ptmscore_result_txt=${ptmscore_txt%.*}_info.txt
if [ -f $ptmscore_txt ] || [ -f $ptmscore_result_txt ]; then
	rm $ptmscore_txt $ptmscore_result_txt
fi
for pdb1 in $pdb_path/*.pdb; do
	pdb1name=$(basename $pdb1)
	file_name=${pdb1name%.*}
	ptmscore_result_list=()
	ptmscore_result_list+=("$pdb_id" "$i")
	soft=$(echo "$file_name" | awk -F'_' '{print $1}')
	if [[ $file_name == *_* ]]; then
		num=$(echo "$file_name" | awk -F'_' '{print $NF}')      #$NF
		echo "num1:$num"    # 输出  26
	else
		num=1
	fi
	echo "num2:$num"
	tmp_name="${file_name#*_*_}"
	echo -e "$pdb_id\t$soft\t$num\t$file_name"
	ptmscore_list=()
	ptmscore_list+=("$pdb_id	$soft	$num	$file_name")
	sum=0	
	num=0
	# for ((j=1; j<=24; j++))
	# do
	for pdb2 in $pdb_path/*.pdb; do
		pdb2name=$(basename $pdb2)
		# pdb2=$pdb_path/${j}.pdb
		if [ -f "$pdb2" ] && [ -f "$pdb1" ]; then
			output=$( { "$RNAalign_path" "$pdb1" "$pdb2" -outfmt 2 2>&1; } | tee /dev/stderr )
			echo "output:$output"
			# 检查命令的返回值
			if [[ $output == *"Cannot parse file"* ]]; then
				echo "======="
				#echo $?
				output=$("$RNAalign_path"  -atom ' P  ' "$pdb1" "$pdb2" -outfmt 2)
				echo $output
				echo "===="
			fi
			TM1_value=$(echo "$output" | awk -v pdb1="$pdb1" '$0 ~ pdb1 {print $3}')
		else
			TM1_value=0.00
		fi
		echo $TM1_value		
		ptmscore_result_list+=("$TM1_value")
		if [ $TM1_value != 0.00 ];then
			sum=$(echo "$sum+$TM1_value" | bc)
			#echo $sum
			num=$((num+1))
			#echo $num
		fi
	done
	echo "====="
	echo ${ptmscore_result_list[@]} >> $ptmscore_result_txt
	sum_1=$(echo "$sum-1" | bc)
	num_1=$((num - 1))
	if [ "$(echo "$sum > 0" | bc -l)" -eq 1 ]; then
		result=$(echo "scale=4; ($sum - 1) / ($num - 1)" | bc)
	else
		result="0.0"
	fi
	formatted_result=$(printf "%.4f" $result)
	ptmscore_list+=("$formatted_result")
	echo ${ptmscore_list[@]} >> $ptmscore_txt	

done
# echo "done $ptmscore_txt"
