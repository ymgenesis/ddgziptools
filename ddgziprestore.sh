#! /bin/bash

## macOS

if [[ $OSTYPE == darwin* ]];
then
	echo "You are Mac"
	echo
	sudo diskutil list

	echo "Which disk would you like to restore to (Use absolute disk path. Ex: /dev/disk3. Do not include partition)?"
	read -e outfile
	echo
	sleep 0.7

	echo "Which .img.dd.gz would you like to use (include absolute path and file extension. Tab completion enabled)?"
	read -e infile
	echo
	sleep 0.7

	echo "The following will be executed. Please review carefully:"
	echo
	sleep 1
	echo "sudo sh -c 'gunzip -c $infile | dd of=$outfile' bs=1m"
	echo
	sleep 0.7

	read -p "Execute? (y/N): " ANS
		if [ "$ANS" = "y" -o "$ANS" = "Y" ] 
		then
			echo
			sleep 0.7
			echo "Executing in 8 seconds..."
				count=8
				while [ $count -ge 1 ]
				do
					echo $count
					count=$(( $count - 1 ))
					sleep 1
				done
			echo
		
			echo "Unmounting all partitions on $outfile"
			echo
				sudo diskutil unmountDisk "${outfile}"
			echo
			sleep 0.7
		
			echo "Executing sudo sh -c 'gunzip -c $infile | dd of=$outfile' bs=1m"
			echo
			sleep 0.7
			echo "The script will exit when complete. Please be patient..."
                	sleep 0.7
                	echo
		
			sudo sh -c 'gunzip -c '$infile' | dd of='$outfile' bs=1m' &
			pid=$!
			echo "dd pid: $pid"
			# If script is killed, kill dd
			trap "kill $pid 2> /dev/null" EXIT
			# While dd is running...
			while sudo kill -0 $pid 2> /dev/null; 
			do 
				echo "-------------------------------"
				echo
				echo "Size of $infile:"
					ls -lh $infile | awk '{ print $5 }'
				echo
				echo "dd progress:"
					sudo killall -INFO dd
				echo
				sleep 10
			done
			# Disable trap
			trap - EXIT
			
			echo
			echo "Complete!"
			echo
			
		else
			sleep 0.7
			echo
			echo "Exiting without executing..."
		fi

## Linux

elif [[ $OSTYPE == linux* ]];
then
	echo "You are Linux"
	echo
	sudo lsblk
	echo

	echo "Which disk would you like to restore to (Use absolute disk path. Ex: /dev/sdb. Do not include partition)?"
	read -e outfile
	echo
	sleep 0.7

	echo "Which .img.dd.gz would you like to use (include absolute path and file extension. Tab completion enabled)?"
	read -e infile
	echo
	sleep 0.7

	echo "The following will be executed. Please review carefully:"
	echo
	sleep 1
	echo "sudo sh -c 'gunzip -c $infile | dd of=$outfile bs=1M'"
	echo
	sleep 0.7
	
	read -p "Execute? (y/N): " ANS
		if [ "$ANS" = "y" -o "$ANS" = "Y" ] 
		then
			echo
			sleep 0.7
			echo "Executing in 8 seconds..."
				count=8
				while [ $count -ge 1 ]
				do
					echo $count
					count=$(( $count - 1 ))
					sleep 1
				done
			echo
		
			echo "Unmounting all partitions on $outfile"
				sudo umount /dev/"${outfile}"* 2>/dev/null;
			echo
			sleep 0.7
			
			echo "Executing sudo sh -c 'gunzip -c $infile | dd of=$outfile bs=1M'"
			echo
			sleep 0.7
			echo "The script will exit when complete. Please be patient..."
                	sleep 0.7
                	echo
		
			sudo sh -c 'gunzip -c '$infile' | dd of='$outfile' bs=1M' &
			pid=$!
			echo "dd pid: $pid"
			# If script is killed, kill dd
			trap "kill $pid 2> /dev/null" EXIT
			# While dd is running...
			while sudo kill -0 $pid 2> /dev/null; 
			do 
				echo "-------------------------------"
				echo
				echo "Size of $infile:"
					ls -lh $infile | awk '{ print $5 }'
				echo
				echo "dd progress:"
					sudo killall -s USR1 dd
				echo
				sleep 10
			done
			# Disable trap
			trap - EXIT
			
			echo
			echo "Complete!"
					
		else
			sleep 0.7
			echo
			echo "Exiting without executing..."
		fi
 
## Neither Linux or macOS
	
else
	echo "OSTYPE doesn't return Darwin or Linux. Exiting..."
	sleep 0.7
fi