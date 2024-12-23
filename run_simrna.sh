#!/bin/bash
data=$1
save_path=$2
echo $save_path
pdbid=$(basename $data)

run_SimRNA(){
    for file in $save_path/*.fasta; do
        echo $file
        
        ./SimRNA -s $file -c ./config.dat -o "$save_path/${pdbid}"
        python ./trafl_extract_lowestE_frame.py ${pdbid}.trafl
        ./SimRNA_trafl2pdbs ${pdbid}-000001.pdb ${pdbid}_minE.trafl 1:1 AA
        mv ${pdbid}* $save_path/
    done
}
run_SimRNA










