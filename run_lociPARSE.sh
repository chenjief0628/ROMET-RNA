#!/bin/bash


runloci(){
	pdb_id=$1  #R1107
	echo "loci:$pdb_id"
	echo "========Running lociPARSE========="
	echo ""
	echo "========Generating Features======="

	python3 ${ori_path}/Scripts/Feature.py --pdb_id ${pdb_id} --Path ${pdb_id}_F/

	echo "Done"

	echo "=========Running Inference========"

	python3 ${ori_path}/Scripts/prediction.py --pdb_id ${pdb_id}
	echo ""
	echo "=======Inference complete.========"

}

ori_path=$1
data=$2
runloci $data

