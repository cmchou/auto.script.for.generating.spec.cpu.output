#!/bin/bash

#=========================Initial variable setup================================
HOST=x3650m5
COUNT=30
now=$(date +"%Y%m%d")
#CPU_name=2690v3
#Snoop_Mood=CoD
#Mem_Freq=2133
#DPC=2DPC
HT=HToff
declare -a Mem_Speed_Set
Mem_Speed_Set=("Max Performance" "Balanced" "Minimal Power")
#"Minimal Power" "Balanced" 
echo "Will run ${#Mem_Speed_Set[@]} different memory speeds"
declare -a Snoop_Mode=(CoD ES HDOSB)
#ES HDOSB
echo "Will run ${#Snoop_Mode[@]} different snoop modes"
declare -i Need_Reboot=0
#echo $Need_Reboot
#Mem_Speed_Set[0]="Minimal Power"
#Mem_Speed_Set[1]="Balanced"
#Mem_Speed_Set[2]="Max Performance"
#echo ${Mem_Speed_Set[0]}
#echo ${Mem_Speed_Set[1]}
#echo ${Mem_Speed_Set[2]}
#for ((i=0; i< ${#Mem_Speed_Set[@]}; i++)) do
#	echo ${Mem_Speed_Set[${i}]}
#done

#=======================Set the machine to default mode =======================
#ssh root@${HOST} 'cd ~/onecli; ./OneCli config restore --file 20151224.x3650m5.cfg;' #reboot after restore
#Temp_Var=0
#while [ "$Temp_Var" -ne "$COUNT" ]
#do
#        Temp_Var=$(ping -c $COUNT $HOST | grep 'received' | awk -F',' '{print $2}' | awk '{print $1}')
#done
#echo "Load default successfully, ${HOST} is back"

#=======================Do the regular setting and data gathering==============
echo "entering for loop"
for ((i=0; i< ${#Snoop_Mode[@]}; i++)) do
	for ((j=0; j< ${#Mem_Speed_Set[@]}; j++)) do
		#collect server configs
		echo "We are in loop i=${i}, j=${j}"
		echo ${Snoop_Mode[i]}
		echo ${Mem_Speed_Set[j]}
		ssh root@${HOST} '~/onecli/./OneCli config show' > config.temp.txt
		declare -i CoD_Setting=$(grep Processors.CODPreference=Enable config.temp.txt | wc -l)
		declare -i ES_Setting=$(grep Processors.EarlySnoopPreference=Enable config.temp.txt | wc -l)
		echo "CoD = $CoD_Setting"
		echo "ES = $ES_Setting"
		Cur_Mem_Speed=$(grep Memory.MemorySpeed= config.temp.txt | sed 's/Memory.MemorySpeed=//g')
		#echo $(grep Memory.MemorySpeed= config.temp.txt | sed  's/Memory.MemorySpeed=//g')
		rm -rf config.temp.txt
		echo "Current Mem Speed is: $Cur_Mem_Speed (${#Cur_Mem_Speed})"
		echo "Target Mem Speed is:  ${Mem_Speed_Set[j]} (${#Mem_Speed_Set[j]})" 
		#check server configs equal to what we want to run for now
		
		if [ "${Mem_Speed_set[j]}" != "$Cur_Mem_Speed" ] 
		then	
			echo "Setting memory speed through onecli"
			ssh root@${HOST} "~/onecli/./OneCli config set Memory.MemorySpeed '${Mem_Speed_Set[j]}'"
			Need_Reboot=1
		fi

		#check if system is in CoD mode
		if [ "${Snoop_Mode[i]}" == "CoD" ] 
		then
			if [ "$CoD_Setting" -eq "0" ] 
			then
				echo "setting to ED mode"
				ssh root@${HOST} "~/onecli/./OneCli config set Processors.CODPreference Enable"
				ssh root@${HOST} "~/onecli/./OneCli config set Processors.EarlySnoopPreference Disable"
				Need_Reboot=1
			fi
		fi

                #check if system is in ES mode
                if [ "${Snoop_Mode[i]}" == "ES" ] 
		then
                        if [ "$CoD_Setting" -eq "1" ] 
			then
				echo "setting to DE mode(1)"
                                ssh root@${HOST} "~/onecli/./OneCli config set Processors.CODPreference Disable"
				ssh root@${HOST} "~/onecli/./OneCli config set Processors.EarlySnoopPreference Enable"
				Need_Reboot=1
			elif [ "$ES_Setting" -eq "0" ] 
			then
				echo "setting to DE mode(2)"
				ssh root@${HOST} "~/onecli/./OneCli config set Processors.EarlySnoopPreference Enable"
				Need_Reboot=1
			fi
                fi

                #check if system is in HDOSB mode
                if [ "${Snoop_Mode[i]}" == "HDOSB" ] 
		then
                        if [ "$CoD_Setting" -eq "1" ] 
			then
				echo "setting to DD mode(1)"
                                ssh root@${HOST} "~/onecli/./OneCli config set Processors.CODPreference Disable"
                                ssh root@${HOST} "~/onecli/./OneCli config set Processors.EarlySnoopPreference Disable"
				Need_Reboot=1
                        elif [ "$ES_Setting" -eq "1" ] 
			then
				echo "setting to DD mode(2)"
				ssh root@${HOST} "~/onecli/./OneCli config set Processors.EarlySnoopPreference Disable"
                                Need_Reboot=1
			fi

                fi

#========================check if need to reboot==============================================================================
		if [ "$Need_Reboot" -eq 1 ] 
		then
			echo "Rebooting ${HOST}"
			ssh root@${HOST} "reboot"
			Temp_Var=0
			while [ "$Temp_Var" -ne "$COUNT" ]
			do
       				 Temp_Var=$(ping -c $COUNT $HOST | grep 'received' | awk -F',' '{print $2}' | awk '{print $1}')
			done
			echo "Reboot successfully, ${HOST} is back"
		else 
			echo "No need to reboot, gathering data now..."

		fi

		#determine the variables used in this run
		CPU_name=$(ssh root@${HOST} "cat /proc/cpuinfo"|grep 'model name' | awk 'NR==1{print $7$8}')
		Mem_Freq=$(ssh root@${HOST} "dmidecode --type=17" | grep Configured | awk 'NR==1{print $4}')
		DPC=$(ssh root@${HOST} "dmidecode --type=17" | grep "Configured Clock Speed: ${Mem_Freq}" | wc -l)
		declare -i DPC
		DPC=$DPC/8
		Out_File_Name=${now}.${CPU_name}.${Snoop_Mode[i]}.${HT}.${Mem_Freq}.${DPC}DPC.txt
		echo "The file name is:$Out_File_Name"
		#echo ${Mem_Speed_Set[j]}
		
		#commands use to collect results
		ssh root@${HOST} "dmidecode --type=17" > dmidecode.$Out_File_Name
		ssh root@${HOST} "~/onecli/./OneCli config show" > UEFI.$Out_File_Name
		ssh root@${HOST} "~/mlc30/Linux/./mlc" > mlc.$Out_File_Name
		ssh root@${HOST} "~/stream/stream_avx2/./stream_avx2" > stream.$Out_File_Name
		#ssh root@${HOST} "~/onecli/./OneCli config set Processors.CODPreference Disable"
		#ssh root@${HOST} "~/onecli/./OneCli config set Processors.EarlySnoopPreference Enable"
		#ssh root@${HOST} 'reboot'





	done
done

