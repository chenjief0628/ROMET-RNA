#!/bin/bash

soft=$1
source_path=$2    
save_path=$3   
msa=$4  
###########DeepFoldRNA
if [ "$soft" == "DeepFoldRNA" ]; then
    echo "gene DeepFoldRNA data: "
    models=("model_1" "model_2" "model_3" "model_4" "model_5" "model_6")
    for ((i=0; i<${#models[@]}; i++)); do
        pdb1="$source_path/${models[i]}/final_models/refined_model.pdb"
        echo "pdb1:$pdb1"
        num=${soft}_${msa}_$((i + 1)) 
        if [ ! -d "$save_path" ]; then
            mkdir -p "$save_path"
        fi
        echo "pdb2:$save_path/${num}.pdb"
        cp $pdb1 "$save_path/${num}.pdb"	
    done
fi
###########trRosettaRNA
if [ "$soft" == "trRosettaRNA" ]; then
    echo "gene trRosettaRNA data: "
    for pdb in $source_path/*.pdb; do
        pdbname=$(basename $pdb)
        if [[ $pdbname != *model* ]] && [[ $pdbname != *initpose* ]]; then
            
            # 使用正则表达式匹配数字部分
            if [[ $pdbname =~ ([0-9]+) ]]; then
                number_part="${BASH_REMATCH[1]}"
                number_part=$((number_part+dex))	
                if [[ $pdbname == *best* ]]; then
                    num2="_best_${number_part}"
                else
                    num2="_$number_part"
                fi
            fi
            pdb1="$pdb"
            echo "pdb1:$pdb1"
            mkdir -p "$save_path/"
            pdb2="$save_path/${soft}_${msa}${num2}.pdb"
            echo "pdb2:$pdb2"
            
            if [[ -f "$pdb1" ]]; then
                cp $pdb1 $pdb2
            fi	
        fi
    done
fi
###########RhoFold
if [ "$soft" == "RhoFold" ]; then
    echo "gene RhoFold data: "

    pdb1="$source_path/unrelaxed_model.pdb"
    echo "pdb1:$pdb1"
    mkdir -p "$save_path"
    pdb2="$save_path/${soft}_${msa}.pdb"
    echo "pdb2:$pdb2"
    cp $pdb1 $pdb2
fi
###########RosettaFoldRN
if [ "$soft" == "RosettaFoldNA" ]; then
    echo "gene RosettaFoldNA data: "

    pdb1=$source_path/models/model_00.pdb
    echo "pdb1:$pdb1"
    mkdir -p "$save_path/"
    pdb2="$save_path/${soft}_${msa}.pdb"
    echo "pdb2:$pdb2"
    cp $pdb1 $pdb2

fi
###########Drfold
if [ "$soft" == "Drfold" ]; then
    echo "gene Drfold data: "
    for pdb in $source_path/*.pdb; do
        # echo $pdb
        pdbname=$(basename $pdb)
        # echo $pdbname
        if [[ $pdbname != *cg* ]]; then
            # echo $pdb
            # 使用正则表达式匹配数字部分
            # if [[ $pdbname =~ ([0-9]+) ]]; then
            if [[ $pdbname =~ _([0-9]+)\.pdb ]]; then
                number_part="${BASH_REMATCH[1]}"
                ((number_part++))
                num="_$number_part"
                # echo "Extracted number: $num"
            else
                num="_7"
                # echo "$num"
            fi
            # echo $num
            pdb1="$pdb"
            echo "pdb1:$pdb1"
            mkdir -p "$save_path/"
            pdb2="$save_path/${soft}$num.pdb"
            echo "pdb2:$pdb2"
            
            if [[ -f "$pdb1" ]]; then
                cp $pdb1 $pdb2
            fi	
        fi
    done
fi

###########SimRNA
if [ "$soft" == "SimRNA" ]; then
    echo "gene SimRNA data: "
    pdb_id=$(basename $source_path)
    # echo $pdb_id
    pdb1="$source_path/${pdb_id}_minE-000001_AA.pdb"
    echo "pdb1:$pdb1"
    mkdir -p "$save_path/"
    pdb2="$save_path/${soft}.pdb"
    echo "pdb2:$pdb2"
    cp $pdb1 $pdb2
fi


