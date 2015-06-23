#!/bin/bash
Working_Directory=$1

declare -i highest_int_sp=0
highest_int_sp_folder="aabb"
declare -i highest_fp_sp=0
highest_fp_sp_folder=""
declare -i highest_int_rate=0
highest_int_rate_folder=""
declare -i highest_fp_rate=0
highest_int_rate_folder=""
#echo $highest_int_sp
#echo $highest_int_sp_folder

remove_Target='!(*.rsf)'

#echo $1
folder_length=$(expr length $1)
#echo ${1:$folder_length-1} #get the last character
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
#pwd #for testing current directory
Output_Directories="$Working_Directory/*"
for a in $Output_Directories; do
	
	#=============================the following part rename the folder name==========================
	echo $a
	temp_folder_name=${a/"Result_HT-"/}
	temp_folder_name=${temp_folder_name/"_COD-"/}
	temp_folder_name=${temp_folder_name/"_ES-"/}
	temp_folder_name=${temp_folder_name//"Enable"/E}
	temp_folder_name=${temp_folder_name//"Disable"/D}	
	echo ${temp_folder_name:$(expr length $temp_folder_name)-12}	
	
	#output folder with configs and date(eg., EDE-150102AM)
	temp_folder_name=${temp_folder_name:0:$(expr length $temp_folder_name)-12}${temp_folder_name:$(expr length $temp_folder_name)-12}
	#output folder with configs only (eg., EDE)
	#temp_folder_name=${temp_folder_name:0:$(expr length $temp_folder_name)-12}${temp_folder_name:$(expr length $temp_folder_name)-12:3}

	mv $a $temp_folder_name 
	cd $temp_folder_name
        
	#=============================The following part grep the score from the *.txt file================
	#grep for int.sp
        int_sp=$(grep SPECint *.txt | grep base2006 | grep -v rate | awk '{print $3}')
        int_sp_peak=$(grep SPECint2006 *.txt | awk '{print $3}') 
	echo "$int_sp / $int_sp_peak"
	int_sp=$(printf "%.0f" $int_sp)
	if [ -z "$int_sp" ]  
	then
		echo "Variable is empty"
	elif [ $int_sp -gt $highest_int_sp ]
	then 
		highest_int_sp=$int_sp 
		highest_int_sp_folder=$temp_folder_name
	fi

	#grep for fp.sp
	fp_sp=$(grep SPECfp *.txt | grep base2006 | grep -v rate | awk '{print $3}')
	fp_sp_peak=$(grep SPECfp2006 *.txt | awk '{print $3}')
	echo "$fp_sp / $fp_sp_peak"
        fp_sp=$(printf "%.0f" $fp_sp)
        if [ -z "$fp_sp" ]  
	then
                echo "Variable is empty"
        elif [ "$fp_sp" -gt "$highest_fp_sp" ]   
	then
        	highest_fp_sp=$fp_sp
                highest_fp_sp_folder=$temp_folder_name
        fi

	#grep for int.rate
        int_rate=$(grep SPECint *.txt | grep base2006 | grep rate | awk '{print $3}')
        int_rate_peak=$(grep SPECint *.txt | grep int_rate | awk '{print $3}')
        echo "$int_rate / $int_rate_peak"
        int_rate=$(printf "%.0f" $int_rate)
        if [ -z "$int_rate" ]  
	then
                echo "Variable is empty"
        elif [ "$int_rate" -gt "$highest_int_rate" ]   
	then
                highest_int_rate=$int_rate
                highest_int_rate_folder=$temp_folder_name
        fi

	#grep for fp.rate
	fp_rate=$(grep SPECfp *.txt | grep base2006 | grep rate | awk '{print $3}')
	fp_rate_peak=$(grep SPECfp *.txt | grep fp_rate | awk '{print $3}')
	echo "$fp_rate / $fp_rate_peak"
        fp_rate=$(printf "%.0f" $fp_rate)
        if [ -z "$fp_rate" ]; then
                echo "Variable is empty"
        elif [ "$fp_rate" -gt "$highest_fp_rate" ]; then
                        highest_fp_rate=$fp_rate
                        highest_fp_rate_folder=$temp_folder_name
        fi

	#echo $highest_int_sp;
	#echo $highest_fp_sp;
	#echo $highest_int_rate;
	#echo $highest_fp_rate;
        #echo $highest_int_sp_folder;
        #echo $highest_fp_sp_folder;
        #echo $highest_int_rate_folder;
        #echo $highest_fp_rate_folder;
	

	
	#remove useless files
	shopt -s extglob
	rm $remove_Target
	

	#modifying *.rsf contents
	#echo $temp_folder_name
	RSFPATH="$temp_folder_name/*.rsf"	
	for b in $RSFPATH; do
		#echo $b
		#Add "none" for fp results
		sed -i -e 's/spec.cpu2006.sw_other: --/spec.cpu2006.sw_other: None/g' $b
		
		#remove the unnecessary memory spec description
		#echo $(grep -Fxq "spec.cpu2006.hw_memory002" $b)
		if grep -q "spec.cpu2006.hw_memory003" $b 
		then
			#echo "003 exists"
    			# code if found
			sed -i '/spec.cpu2006.hw_memory003/d' $b
			sed -i '/spec.cpu2006.hw_memory002/d' $b
		else
			#echo "doesn't have 003"
    			# code if not found
                	sed -i '/spec.cpu2006.hw_memory002/d' $b
                	sed -i '/spec.cpu2006.hw_memory001/d' $b

		fi
	done

done



echo $highest_int_sp
echo $highest_fp_sp
echo $highest_int_rate
echo $highest_fp_rate
echo $highest_int_sp_folder
echo $highest_fp_sp_folder
echo $highest_int_rate_folder
echo $highest_fp_rate_folder

#copy the highest cint.sp.rsf for submission
rsf_int_sp="$highest_int_sp_folder/CINT*.rsf"
for a in $rsf_int_sp; do
	echo $a
	cp $a ../cint.sp.rsf
done

#copy the highest cfp.sp.rsf for submission
rsf_fp_sp="$highest_fp_sp_folder/CFP*.rsf"
for a in $rsf_fp_sp; do
	echo $a
	cp $a ../cfp.sp.rsf
done

#copy the highest cint.rate.rsf for submission
rsf_int_rate="$highest_int_rate_folder/CINT*.rsf"
for a in $rsf_int_rate; do
        echo $a
	if [ -e "../cint.rate.rsf" ] 
	then
		#jump out of the for loop
  		break
	else
        	cp $a ../cint.rate.rsf
	fi
done

#copy the highest cfp.rate.rsf for submission
rsf_fp_rate="$highest_fp_rate_folder/CFP*.rsf"
for a in $rsf_fp_rate; do
        echo $a
	if [ -e "../cfp.rate.rsf" ]
	then
		#jump out of the for loop
		break
	else
        	cp $a ../cfp.rate.rsf
	fi
done

