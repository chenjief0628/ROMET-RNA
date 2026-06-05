#!/bin/bash
deepfoldrna_path="/data/zt/DeepFoldRNA/DeepFoldRNA"
infernal_dir="${deepfoldrna_path}/bin/rMSA/infernal-1.1.4-linux-intel-gcc/binaries/"
deepfoldrna_env="ztenv"   #                "/data/zt/DeepFoldRNA/conda_local/conda/envs/deepfoldrna"
trrosettarna_path="/data/zt/trRosettaRNA"
trrosettarna_env="trRNA"
rhofold_path='/data/chenjief/software/RhoFold/'
rhofold_env="rhofold"
rf2na_path="/data/chenjief/software/RoseTTAFold2NA"
rf2na_env="RF2NA"
drfold_path="/data/zt/DRfold/DRfold"
simrna_path="/data/zt/SimRNA_64bitIntel_Linux"


data=$1    #"example/output/"
res_folder=$2
pdb_folder=$3
soft=$4  #
pdbid=$5    #"seq"
dir_path=$(pwd)
###########DeepFoldRNA
if [ "$soft" == "DeepFoldRNA" ]; then
    echo "Soft:DeepFoldRNA"
    msa_list=(afa a2m a2mmsa nomsa)
    for msa in "${msa_list[@]}"; do
        echo "MSA:${msa}"
        msa_file="${data}/input_${msa}/seq.afa"
        if [ -e "$msa_file" ]; then
            save_folder=$res_folder/DeepFoldRNA/${msa}
            mkdir -p $save_folder
            cp "${data}/input_${msa}"/* ${save_folder}
            if [ ! -s "${save_folder}/seq.cm" ]; then 
                $infernal_dir/cmbuild --noss "${save_folder}/seq.cm" "${msa_file}"
            fi
            conda run -n ${deepfoldrna_env} python3 ${deepfoldrna_path}/runDeepFoldRNA.py --input_dir "${save_folder}"
            bash ${dir_path}/gene_data.sh ${soft} ${save_folder} ${pdb_folder} "$msa"
        fi
    done
fi
###########trRosettaRNA
if [ "$soft" == "trRosettaRNA" ]; then
    echo "Soft:trRosettaRNA"
    msa_list=(afa a2m a2mmsa nomsa)
    for msa in "${msa_list[@]}"; do
        echo "MSA:${msa}"
        msa_file="${data}/input_${msa}/seq.a3m"
        if [ -e "$msa_file" ]; then
            save_folder=$res_folder/trRosettaRNA/${msa}
            mkdir -p $save_folder
            cp "${data}/input_${msa}"/* ${save_folder}
            conda run -n ${trrosettarna_env} python ${trrosettarna_path}/predict.py -i $save_folder/seq.a3m -o $save_folder/seq.npz -mdir ${trrosettarna_path}/params/model_1 -gpu 0
            conda run -n ${trrosettarna_env} python ${trrosettarna_path}/fold.py -npz $save_folder/seq.npz -fa $save_folder/seq.fasta -out $save_folder/model_1.pdb
            bash ${dir_path}/gene_data.sh ${soft} ${save_folder} ${pdb_folder} "$msa"
        fi
    done
fi
###########Rhofold
if [ "$soft" == "RhoFold" ]; then
    echo "Soft:RhoFold"
    ckpt_path=${rhofold_path}/pretrained/rhofold_pretrained.pt
    msa_list=(afa a2m a2mmsa nomsa)
    for msa in "${msa_list[@]}"; do
        echo "MSA:${msa}"
        msa_file="${data}/input_${msa}/seq.a3m"
        if [ -e "$msa_file" ]; then
            save_folder=$res_folder/Rhofold/${msa}
            mkdir -p $save_folder
            cp "${data}/input_${msa}"/* ${save_folder}
            conda run -n ${rhofold_env} python ${rhofold_path}/inference.py --input_fas $data/seq.fasta --input_a3m $save_folder/seq.a3m  --output_dir $save_folder --ckpt ${ckpt_path}
            bash ${dir_path}/gene_data.sh ${soft} ${save_folder} ${pdb_folder} "$msa"
        fi
    done
     
fi
###########RosettaFoldRN
if [ "$soft" == "RosettaFoldNA" ]; then
    echo "Soft:RosettaFoldNA"
    msa_list=(afa a2m a2mmsa nomsa)
    for msa in "${msa_list[@]}"; do
        echo "MSA:${msa}"
        msa_file="${data}/input_${msa}/seq.afa"
        if [ -e "$msa_file" ]; then
            save_folder=$res_folder/RosettaFoldNA/${msa}
            mkdir -p $save_folder
            cp $data/seq.fasta $save_folder/
            cp ${msa_file} $save_folder/
            awk '
            BEGIN { OFS = ""; }
            /^>/ { print; getline; gsub(/[^AUCGN-]/, "U"); print; next; }
            { print }
            ' $save_folder/seq.afa > $save_folder/seq_new.afa
            mv $save_folder/seq_new.afa $save_folder/seq.afa
            conda run -n ${rf2na_env} bash ${rf2na_path}/run_RF2NA.sh $save_folder R:$save_folder/seq.fasta
            conda run -n ${rf2na_env} bash ${rf2na_path}/run_RF2NA.sh $save_folder R:$save_folder/seq.fasta
            bash ${dir_path}/gene_data.sh ${soft} ${save_folder} ${pdb_folder} "${msa}"
        fi
    done
fi
###########Drfold
if [ "$soft" == "Drfold" ]; then
    echo "Soft:Drfold"
    save_folder=$res_folder/Drfold/${pdbid}
    mkdir -p $save_folder
    bash ${drfold_path}/DRfold.sh $data/seq.fasta  ${save_folder}
    bash ${dir_path}/gene_data.sh ${soft} ${save_folder} ${pdb_folder}
fi

###########SimRNA
if [ "$soft" == "SimRNA" ]; then
    echo "Soft:SimRNA"
    save_folder=$res_folder/SimRNA/${pdbid}
    mkdir -p $save_folder
    # cp $data/seq.fasta $save_folder/
    tail -n +2 "$data/seq.fasta" > "${save_folder}/seq.fasta"
    now_path=$(pwd)
    cd ${simrna_path}
    bash ${dir_path}/run_simrna.sh $save_folder $save_folder
    cd ${now_path}
    bash ${dir_path}/gene_data.sh ${soft} ${save_folder} ${pdb_folder}    #${save_folder%/*}:$res_folder/SimRNA
fi



