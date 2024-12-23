#!/bin/bash

pdbid=$1  #"R1221s2"
# id=$2  #"1221s2"
# add="_fold"
############### msa 数据准备
gene_msa(){
	dir1=$1
	dir2=$2
	pdbid=$3
	type1=$(basename $dir1 | awk -F'_' '{print $NF}')
	echo $type1
	type2=$(basename $dir2 | awk -F'_' '{print $NF}')
	echo $type2
	cp -r "$dir1/$pdbid" "$dir2/"
	if [ $type1 == 'nomsa' ]; then
		cp "/home/fengchenjie/casp16/${id}/${pdbid}.${type}" "$dir2/$pdbid/"
		cp "$dir2/$pdbid/${pdbid}.${type}"  "$dir2/$pdbid/seq.afa"
		cp "$dir2/$pdbid/${pdbid}.${type}"  "$dir2/$pdbid/seq.a3m"
 	fi
	# if [ $type2 == 'ss' ]; then
	# 	cp "SPOTRNA/${pdbid}/ss.txt" "$dir2/$pdbid"
 	# fi

}
# type=$3  #"a2m"
# # gene_msa "casp16_nomsa" "casp16_${type}" $pdbid
# # gene_msa "casp16_${type}" "casp16_${type}_ss" $pdbid
# gene_msa "casp16_${type}" "casp16_${type}_pet" $pdbid
# gene_msa "casp16_${type}" "casp16_${type}_fold" $pdbid
# gene_msa "casp16_${type}" "casp16_${type}_pet_fold" $pdbid

######
gene_msa_tar(){
	now_path=$(pwd)
	echo "=================================================${now_path}"
	pdbid=$1 
	msa=$2
	path1="Deep/${pdbid}"
	path2="Deep/casp16_${msa}/"
	# mv $path1/${pdbid}_${msa}.tar $path2
	cd $path2
	echo "==================================================$(pwd)"
	tar xvf ${pdbid}_${msa}.tar
	cd $now_path

}
# msa_type=$2
# gene_msa_tar $pdbid ${msa_type}
# gene_msa_tar $pdbid ${msa_type}_pet
# gene_msa_tar $pdbid ${msa_type}_fold
# gene_msa_tar $pdbid ${msa_type}_pet_fold

################ 将其他的运行结果复制到Web目录下
gene_dir(){
        path1=$2  #"casp16_afa"
        path2=$1  #"tr/casp16_afa2"
        pdbid=$3  #"R1205"
        soft=$4   #"tr"
		path3="$path1/${pdbid}_res/$soft/"
		if [ ! -d $path1/$pdbid ]; then
			mkdir -p $path1/$pdbid
			cp $path2/$pdbid/seq.fasta $path1/$pdbid/
			cp $path2/$pdbid/seq.afa $path1/$pdbid/
			cp $path2/$pdbid/*.a2m $path1/$pdbid/
			cp $path2/$pdbid/seq.a3m $path1/$pdbid/
			# cp $path2/$pdbid/ss.txt $path1/$pdbid/
		fi
		mkdir -p $path3
        cp -r $path2/$pdbid $path3
        ./run.sh $path1/$pdbid   #收集结果
}

# gene_dir Deep/casp16_a2m_msa casp16_a2m_msa $pdbid dp
# gene_dir Deep/casp16_a2m casp16_a2m $pdbid dp
# gene_dir Deep/casp16_afa casp16_afa $pdbid dp
# gene_dir Deep/casp16_a2m_msa${add} casp16_a2m_msa${add} $pdbid dp
# gene_dir Deep/casp16_a2m${add} casp16_a2m${add} $pdbid dp
# gene_dir Deep/casp16_afa${add} casp16_afa${add} $pdbid dp
############### 将pdb结果复制到目标路径
gene_pdb(){

	path="casp16_dp"
	type=$1  #"a2m_ss  a2m_msa_ss afa_ss a2m_pet"
	pdbid=$2
	path1=$path/${type}/$pdbid/
	path2=$pdbid/msa_${type}/
	mkdir -p $path2
	echo $path1
	ls $path1
	echo $path2
	cp $path1/* $path2
}

########## 将pdb结果复制到目标路径
gene_pdb2(){
	type=$1
	pdbid=$2
	./rundata.sh "casp16_${type}/${pdbid}"   ### gene data
	path1="casp16_${type}/${pdbid}_res/${pdbid}_pdb/${pdbid}"
	path2="casp16/$pdbid/msa_${type}"
	mkdir -p $path2
	echo $path1
	echo $path2
	cp $path1/* $path2/
	# ./gene_pdb.sh $path2
}

#gene_pdb2 a2m_msa $pdbid
# #gene_pdb2 a2m $pdbid
#gene_pdb2 afa $pdbid
gene_pdb2 nomsa $pdbid
# gene_pdb2 a2m_msa${add} $pdbid
# gene_pdb2 a2m${add} $pdbid
# gene_pdb2 afa${add} $pdbid


##### 将dp pdb结果复制到目标路径
get_dp(){
	type=$1
	pdbid=$2
	path1="Deep/casp16_${type}/${pdbid}"
	path2="casp16/$pdbid/msa_${type}"
	mkdir -p $path2
	echo $path1
	echo $path2
	./gene_Deepdf.sh $path1 $pdbid $path2 'afa'
	mv $path2/${pdbid}/* $path2/
	rm -r $path2/${pdbid}
}
#msa=$2  #"a2m"  "afa"  
#get_dp ${msa} $pdbid
#get_dp ${msa}_pet $pdbid
#get_dp ${msa}_fold $pdbid
#get_dp ${msa}_pet_fold $pdbid


########### get initfile
get_initfile(){
	
	ori_path="tr_initfile"
	data="R1203"
	init_path="casp16/$data/"
	for dir in $init_path/*; do
		echo $dir
		type=$(basename $dir)
		echo $type
		type2=$(echo "$type" | cut -d'_' -f2-)
		echo $type2
		for pdb in $dir/*pdb; do
			echo $pdb
			pdbname=$(basename $pdb |cut -d'.' -f1)
			echo $pdbname
			path=$ori_path/$data/${type}_init/${pdbname}_init/
			echo $path
			mkdir -p $path
			cp casp16_${type2}/${data}/* $path
			cp $pdb $path/${pdbname}_init.pdb
		done
	done
}
