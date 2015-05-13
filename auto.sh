#!/bin/bash 
Pwd=$(pwd)
RSFPATH="${PWD}/*.rsf"
Num_file=0
for f in $RSFPATH
do
  Num_file=$((Num_file+1))
done
echo $Num_file
echo "${PWD}"

# try to source shrc in SPEC directory
cd ~/SPEC  #switch to spec binary directory
echo ${Pwd}
. ./shrc   #source environment
cd ${Pwd}
ls

for f in $RSFPATH
do
   echo $f
   cp $f ${f}.sub
#   rawformat -o txt --flagsurl  ~/Desktop/config/Intel-ic14.0-official-linux64.xml, ~/Desktop/config/Lenovo-Platform-Flags-V1.2-HSW-A.xml ${f}.sub
rawformat -o pdf ${f}.sub
done

