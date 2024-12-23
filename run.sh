#!/bin/bash

RNAalign_path="/data/zt/software/RNAalign/RNAalign"
lociPARSE_path="/data/zt/software/lociPARSE-main"
lociPARSE_env="lociPARSE"

input_fasta=$1  #"example/input/seq.fasta"  
output_dir=$2  ##"example/output/"

function show_help {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help      Show help information"
    echo "  -i, --input     Input FASTA file"
    echo "  -o, --output    Output directory"
    echo
    echo "Example:"
    echo "  $0 -i seq.fasta -o Outputs"
}

# Check if any parameters are passed
if [ "$#" -eq 0 ]; then
    echo "Error: No arguments provided."
    show_help
    exit 1
fi

# Process command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) 
            show_help
            exit 0 
            ;;
        -i|--input) 
            shift
            input_fasta="$1" 
            ;;
        -o|--output) 
            shift
            output_dir="$1" 
            ;;        
        *) 
            echo "Unknown option:$1"
            show_help
            exit 1 
            ;;
    esac
    shift
done

# Get current directory path
dir_path=$(pwd)

# Check if input FASTA file is specified
if [ -n "$input_fasta" ]; then
    echo "FASTA file: $input_fasta"
    echo "Output directory: ${output_dir:-Not specified}"
else
    echo "Error: Input FASTA file not specified."
    exit 1
fi
# Check if output directory is specified
if [ -n "$output_dir" ]; then
    echo "Output save directory: $output_dir"
else
    output_dir="${dir_path}/Outputs"
    echo "Output save directory not specified. Defaulting to: ${output_dir}"
    # Ask user if they want to use the default output directory
    while true; do
        read -p "Do you want to use this default directory? (yes/no): " choice
        case "$choice" in
            yes|Yes|y|Y)
                echo "Using default output directory: $output_dir"
                mkdir -p "$output_dir"  # Create the output directory if it does not exist
                break
                ;;
            no|No|n|N)
                echo "Please specify a different output directory."
                read -p "Enter the new output directory: " output_dir
                mkdir -p "$output_dir"  # Create the new specified output directory
                echo "Using specified output directory: $output_dir"
                break
                ;;
            *)
                echo "Invalid input. Please enter 'yes' or 'no'."
                ;;
        esac
    done
fi
data=$output_dir
fasta_name=$(basename $input_fasta | cut -d'.' -f1)
echo "fasta_name: $fasta_name"

MSA_path="${data}/MSA"   ###input.afa input.a2m input.a2m_msa
data_afa="${data}/input_afa/"
data_a2m="${data}/input_a2m/"
data_a2m_msa="${data}/input_a2mmsa/"
data_nomsa="${data}/input_nomsa/"
mkdir -p "${MSA_path}"
mkdir -p "${data_afa}"
mkdir -p "${data_a2m}"
mkdir -p "${data_a2m_msa}"
mkdir -p "${data_nomsa}"

res_data="${data}/Outputs"
res_data=$(realpath ${res_data})
mkdir -p ${res_data}
pdb_data="${res_data}/${fasta_name}_pdb/"
mkdir -p ${pdb_data}
meta_pdb="${res_data}/ROMETA_pdb"
mkdir -p ${meta_pdb}
method_pdb="${res_data}/method_pdb/"
mkdir -p ${method_pdb}
echo $dir_path
echo "#################### step 0: data preparation ####################"
######gene fasta
if [ ! -s "${data}/seq.fasta" ]; then 
    cp "${input_fasta}" "${data}/seq.fasta" 
fi
######gene afa
if [ ! -s "${data_afa}/seq.a3m" ]; then 
    cp "${data}/seq.fasta" "${data_afa}"
    cp "${MSA_path}"/*.afa "${data_afa}/seq.afa" 
    cp "${data_afa}/seq.afa"  "${data_afa}/seq.a3m"
    cp "${data_afa}/seq.afa"  "${data_afa}/seq.a2m"
fi
######gene a2m
if [ ! -s "${data_a2m}/seq.a3m" ]; then 
    cp "${data}/seq.fasta" "${data_a2m}/"
    cp "${MSA_path}"/*.a2m "${data_a2m}/seq.afa" 
    cp "${data_a2m}/seq.afa"  "${data_a2m}/seq.a3m"
    cp "${data_a2m}/seq.afa"  "${data_a2m}/seq.a2m"
fi
######gene a2m_msa
if [ ! -s "${data_a2m_msa}/seq.a3m" ]; then 
    cp "${data}/seq.fasta" "${data_a2m_msa}/"
    cp "${MSA_path}"/*.a2m_msa "${data_a2m_msa}/seq.afa" 
    cp "${data_a2m_msa}/seq.afa"  "${data_a2m_msa}/seq.a3m"
    cp "${data_a2m_msa}/seq.afa"  "${data_a2m_msa}/seq.a2m"
fi
######gene nomsa
if [ ! -s "${data_nomsa}/seq.a3m" ]; then 
    cp "${data}/seq.fasta" "${data_nomsa}/"
    cp "${data_nomsa}/seq.fasta" "${data_nomsa}/seq.afa" 
    cp "${data_nomsa}/seq.afa"  "${data_nomsa}/seq.a3m"
    cp "${data_nomsa}/seq.afa"  "${data_nomsa}/seq.a2m"
fi
echo "done"
echo "#################### step 1: run mothod ####################"
# ########### DeepFoldRNA trRosettaRNA RhoFold RosettaFoldNA Drfold SimRNA 
soft_list=(DeepFoldRNA trRosettaRNA RhoFold RosettaFoldNA Drfold SimRNA)
for soft in "${soft_list[@]}"; do
    echo "================= ${soft} ================"
    bash ${dir_path}/gene_meta.sh "$data" "${res_data}" "${pdb_data}" $soft  "${fasta_name}"  
done

# echo "##################### step 2: meta ##########################"
echo "#### 2.1 ptmscore #####"
ptmscore_file="${res_data}/${fasta_name}_ptmscore"
ptmscore_file_num="${ptmscore_file}_num.txt"
bash ${dir_path}/ptmscore.sh "${RNAalign_path}" "${pdb_data}" "${ptmscore_file}.txt" "${fasta_name}" 
echo ${ptmscore_file}
python ${dir_path}/file_num.py "ptmscore" "${ptmscore_file}.txt" "${ptmscore_file_num}"

ptmavg_file="${res_data}/${fasta_name}_ptmavgfd.txt"
echo "${ptmavg_file}"
python ${dir_path}/gene_soft_txt.py "${ptmscore_file_num}" "${ptmavg_file}"
bash ${dir_path}/gene_model_pdb.sh "${ptmavg_file}" "${pdb_data}" "${meta_pdb}"
# ####ptmscore
ptmscore_file="${res_data}/${fasta_name}_ptmscore"
ptmscore_file_num="${ptmscore_file}_num.txt"
bash ${dir_path}/ptmscore.sh "${RNAalign_path}" "${meta_pdb}" "${ptmscore_file}.txt" "${fasta_name}" 
echo "#### 2.2 loci #####"
meta_pdb_abso=$(realpath ${meta_pdb})
# # ##1.pdb
bash ${dir_path}/gene_lociPARSE_input.sh "$meta_pdb_abso" "data" "${fasta_name}" #gene_data
echo "meta_pdb_abso:${meta_pdb_abso}"
##2.lociPARSE.sh
cd $lociPARSE_path
echo "${meta_pdb_abso}"
conda run -n ${lociPARSE_env} bash ${dir_path}/run_lociPARSE.sh   "${lociPARSE_path}" "${meta_pdb_abso}"
cd $dir_path
##3.score
loci_file="${res_data}/${fasta_name}_loci"
bash ${dir_path}/gene_lociPARSE_input.sh "${meta_pdb_abso}" "score" "${fasta_name}"  "${loci_file}.txt"    #gene_score
echo $(pwd)
# echo "#### 2.3 meta #####"
# ###merge 
score_file="${res_data}/${fasta_name}_score"
python ${dir_path}/file_merge.py "${loci_file}.txt" "${ptmscore_file}.txt"  "${score_file}.txt"
meta_file="${res_data}/${fasta_name}_rometa"
awk -v mp="$mccp" '{ $9 = $4 + $8 ; print }' "${score_file}.txt" > "${meta_file}.txt"    #loci+ptm
meta_file_num="${meta_file}_num.txt"
python ${dir_path}/file_num.py "meta"  "${meta_file}.txt" "${meta_file_num}"
# # echo "#### 2.4 method pdb #####"
rometa_score_file="${meta_file}_score.csv"
bash ${dir_path}/gene_pdb.sh  "${pdb_data}" "${method_pdb}" "${meta_file_num}" "${meta_pdb}" "${rometa_score_file}"
rm ${meta_pdb}/*.txt ${res_data}/*.txt
rm -r "${meta_pdb_abso}_F" "${meta_pdb_abso}_P"


echo "######################### end ######################################"











