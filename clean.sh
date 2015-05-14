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
	egrep "(base2006|rate2006|int2006|fp2006)" *.txt
	shopt -s extglob
	rm $remove_Target
done




