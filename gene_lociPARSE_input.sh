#!/bin/bash  

mv_MODEL(){
        pdb_id=$1  #R1116
        ###去掉多余的MODEL，只留MODEL 1
        awk '/MODEL/,/TER/ {print; if (/TER/) exit}' ${pdb_id}/7.pdb >${pdb_id}/71.pdb
        mv ${pdb_id}/71.pdb ${pdb_id}/8.pdb

}

gene_data(){
	ori_path=$1
	pdb_id=$2
	echo $pdb_id
	echo "befor cd $(pwd)"
	cd $ori_path
	path=$(pwd)
	echo "after cd $(pwd)"
	rm *.txt
	ls *.pdb > int.txt   
	sed 's/\.pdb$//' int.txt >input.txt    
	rm int.txt
	cd ../
	echo "path:$ori_path"
	for pdb in $ori_path/*.pdb; do
		echo $pdb
		#grep "R*3" $pdb
		sed -i 's/RU3/  U/g' $pdb
		sed -i 's/RA3/  A/g' $pdb
		sed -i 's/RC3/  C/g' $pdb
		sed -i 's/RG3/  G/g' $pdb
	done
	
	if [[ -f ${ori_path}/7.pdb ]]; then
		mv_MODEL ${ori_path}
	fi	
}

#gene_data $data

gene_score(){
	data=$1
	save_txt=$2
	pdb_id=$3
	echo $save_txt
	if [ -f ${save_txt} ]; then
		rm ${save_txt}
	fi
	echo "pdb_id:$pdb_id"
	for pdb_dir in ${data}_P/*; do
		#echo $pdb_dir 
		pdb=$(basename $pdb_dir)
		#echo $pdb
		score_txt=$pdb_dir/score.txt
		score=$(head -n 1 $score_txt)
		echo -e "${pdb_id}\t${pdb}\t${score}" >> ${save_txt}

	done
}
data=$1
step=$2
pdb_id=$3
if [ "$step" == "data" ]; then
	gene_data $data $pdb_id
elif [ "$step" == "score" ]; then
	save_txt=$4
	gene_score $data $save_txt $pdb_id
fi
