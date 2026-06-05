#!/bin/bash

dir=$1
save_dir=$2
meta_file=$3
meta_dir=$4
rometa_score_file=$5
echo "dir:$dir"
echo "save_dir:$save_dir"
echo "meta_file:${meta_file}"
echo "meta_pdb:${meta_dir}"
path=$(pwd)
if [ -f "$rometa_score_file" ]; then
    rm "$rometa_score_file"
fi
title_score="fasta\tfile\tscore\trank"
echo -e "$title_score" >>"$rometa_score_file"
gene_method(){
    if [ -f "$dir/DeepFoldRNA_afa_1.pdb" ]; then
        cp $dir/DeepFoldRNA_afa_1.pdb $save_dir/DeepFoldRNA.pdb
    else
        cd $dir
        Deep_file=$(ls DeepFoldRNA_afa_* | sort -t_ -k2n | head -n 1)
        # echo ${Deep_file}
        cp ${Deep_file} ${path}/$save_dir/DeepFoldRNA.pdb
        cd $path
    fi
     
    cp $dir/RhoFold_afa.pdb $save_dir/RhoFold.pdb
    cp $dir/RosettaFoldNA_afa.pdb $save_dir/RosettaFoldNA.pdb
    cp $dir/Drfold_7.pdb $save_dir/DRfold.pdb   
    cp $dir/SimRNA.pdb $save_dir/SimRNA.pdb
     
    for file in "$dir"/trRosettaRNA_afa_best*.pdb; do
        # 检查文件名是否带有 "best"
        if [[ -f "$file" ]]; then
            filename=$(basename "$file")
            IFS='_' read -ra parts <<< "$filename"
            last_part="${parts[-1]}"
            number="${last_part//[!0-9]/}"
            if [[ $number -lt 6 ]]; then
                # echo $file
                cp "$file" "$save_dir/trRosettaRNA.pdb"
            fi
        fi
    done
}

gene_meta(){
    input_file="$meta_file"
    while IFS=$'\t' read -r  line; do
        # 提取第二列和第十列
        fasta_name=$(echo "$line" | cut -d$'\t' -f1)
        num_file=$(echo "$line" | cut -d$'\t' -f2)
        score=$(echo "$line" | cut -d$'\t' -f9)
        rank_file=$(echo "$line" | cut -d$'\t' -f10)
        # echo -e "$num_file $rank_file"
        # 检查旧文件是否存在
        if [[ -f "$meta_dir/${num_file}.pdb" ]]; then
            # 更新文件名
            mv "$meta_dir/${num_file}.pdb" "$meta_dir/model_${rank_file}.pdb"
            # echo "Renamed '$meta_dir/${num_file}.pdb' to '$meta_dir/model_${rank_file}.pdb'"
        else
            echo "File '$meta_dir/${num_file}.pdb' does not exist, skipping..."
        fi
        rometa_score_info="$fasta_name\t$num_file\t$score\t$rank_file" 
        echo -e "$rometa_score_info"   >>"${rometa_score_file}.temp"
    done < "$input_file"
    sort -k4,4n "${rometa_score_file}.temp" >>"${rometa_score_file}"
    rm "${rometa_score_file}.temp"
    cp "$meta_dir/model_1.pdb" "$save_dir/ROMET-RNA.pdb"

}

gene_method 
gene_meta 
