#!/bin/bash
#Working_Directory=$1
#echo $1
folder_length=$(expr length $1)
echo ${1:$folder_length-1} #get the last character
#last_char=${1:$folder_length-1}
#compare_char='/'
#if [ "$last_char" == "/" ]
if [ ${1:$folder_length-1} == "/" ]
then
	#echo "equal"
	Working_Directory=${1:0:$folder_length-1}
	#echo $Working_Directory
fi
cd $1
remove_Target='!(*.rsf)'
#pwd #for testing current directory
Output_Directories="$Working_Directory/*"
for a in $Output_Directories; do
	
	#the following part rename the folder name
	echo $a
	temp_folder_name=${a/"Result_HT-"/}
	temp_folder_name=${temp_folder_name/"_COD-"/}
	temp_folder_name=${temp_folder_name/"_ES-"/}
	temp_folder_name=${temp_folder_name//"Enable"/E}
	temp_folder_name=${temp_folder_name//"Disable"/D}	
	echo ${temp_folder_name:$(expr length $temp_folder_name)-12:3}	
	temp_folder_name=${temp_folder_name:0:$(expr length $temp_folder_name)-12}${temp_folder_name:$(expr length $temp_folder_name)-12:3}
	mv $a $temp_folder_name 
	cd $temp_folder_name
        
	#The following part grep the score from the *.txt file
	#grep for int.sp
        int_sp=$(grep SPECint *.txt | grep base2006 | grep -v rate | awk '{print $3}')
        int_sp_peak=$(grep SPECint2006 *.txt | awk '{print $3}')
	echo "$int_sp / $int_sp_peak"

	#grep for fp.sp
	fp_sp=$(grep SPECfp *.txt | grep base2006 | grep -v rate | awk '{print $3}')
	fp_sp_peak=$(grep SPECfp2006 *.txt | awk '{print $3}')
	echo "$fp_sp / $fp_sp_peak"

	#grep for int.rate
        int_rate=$(grep SPECint *.txt | grep base2006 | grep rate | awk '{print $3}')
        int_rate_peak=$(grep SPECint *.txt | grep int_rate | awk '{print $3}')
        echo "$int_rate / $int_rate_peak"
	
	#grep for fp.rate
	fp_rate=$(grep SPECfp *.txt | grep base2006 | grep rate | awk '{print $3}')
	fp_rate_peak=$(grep SPECfp *.txt | grep fp_rate | awk '{print $3}')
	echo "$fp_rate / $fp_rate_peak"
	
	#remove useless files
	shopt -s extglob
	rm $remove_Target
	

	#modifying *.rsf contents
	#echo $temp_folder_name
	RSFPATH="$temp_folder_name/*.rsf"	
	for b in $RSFPATH; do
		echo $b
		sed -i -e 's/spec.cpu2006.sw_other: --/spec.cpu2006.sw_other: None/g' $b
	done
	

done




