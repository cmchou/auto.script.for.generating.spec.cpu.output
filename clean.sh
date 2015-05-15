#!/bin/bash
Working_Directory=$1
echo $1
cd $1
remove_Target='!(*.rsf)'
pwd #for testing current directory
Output_Directories="$Working_Directory/*"
for a in $Output_Directories; do
	echo $a
	cd $a
	#egrep "(SPECint|base2006)" *.txt
        int_sp=$(grep SPECint *.txt | grep base2006 | grep -v rate | awk '{print $3}')
        int_sp_peak=$(grep SPECint2006 *.txt | awk '{print $3}')
	echo "$int_sp / $int_sp_peak"
	fp_sp=$(grep SPECfp *.txt | grep base2006 | grep -v rate | awk '{print $3}')
	fp_sp_peak=$(grep SPECfp2006 *.txt | awk '{print $3}')
	echo "$fp_sp / $fp_sp_peak"
        int_rate=$(grep SPECint *.txt | grep base2006 | grep rate | awk '{print $3}')
        int_rate_peak=$(grep SPECint *.txt | grep int_rate | awk '{print $3}')
        echo "$int_rate / $int_rate_peak"
	fp_rate=$(grep SPECfp *.txt | grep base2006 | grep rate | awk '{print $3}')
	fp_rate_peak=$(grep SPECfp *.txt | grep fp_rate | awk '{print $3}')
	echo "$fp_rate / $fp_rate_peak"
	#egrep "SPECint2006" *.txt
	#egrep "(base2006|rate2006|int2006|fp2006)" *.txt
	shopt -s extglob
	rm $remove_Target
	#need codes for modifying *.rsf contents

	#need codes for modifying folder name
done




