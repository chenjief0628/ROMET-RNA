#!/bin/bash

input_dir=$1 
output_dir=$2 
pdb_id=$(basename $input_dir)
echo $pdb_id
pdb1="$dir/${pdb_id}_minE-000001_AA.pdb"
echo "pdb1:$pdb1"
mkdir -p "$output_dir/$pdb_id/"
pdb2="$output_dir/$pdb_id/SimRNA.pdb"
echo "pdb2:$pdb2"
cp $pdb1 $pdb2


