#! /bin/bash

## macOS

if [[ $OSTYPE == darwin* ]];
then
	echo "You are Mac"
	echo
	sudo diskutil list

	echo "Which disk would you like to backup (ex: disk3. Do not include partition)?"
	read infile
	echo
	sleep 0.7

	echo "Name your backup image (A file extension of .img.dd.gz will be added.):"
	read outfile
	echo
	echo "The file $outfile.img.dd.gz will be saved to $(pwd)"
	echo
	sleep 0.7

	echo "Specify block size. Include unit of data in lower-case (ex: 64k, 512k, 1m):"
	read blocksize
	echo
	sleep 0.7

	echo "The following will be executed. Please review carefully:"
	echo
	sleep 1
	echo "dd if=/dev/$infile bs=$blocksize | gzip -c > $outfile.img.dd.gz"
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
		
			echo "Unmounting all partitions on $infile"
				sudo diskutil unmountDisk /dev/"${infile}"
			echo
			sleep 0.7
		
			echo "Executing dd if=/dev/$infile bs=$blocksize | gzip -c > $outfile.img.dd.gz"
			echo
			sleep 0.7
			echo "The script will exit when complete. Please be patient..."
                	sleep 0.7
                	echo
		
			dd if=/dev/$infile bs=$blocksize | gzip -c > $outfile.img.dd.gz &
			pid=$!
			echo "dd pid: $pid"
			# If script is killed, kill dd
			trap "kill $pid 2> /dev/null" EXIT
			# While dd is running...
			while kill -0 $pid 2> /dev/null; 
			do 
				echo "-------------------------------"
				echo
				echo "Size of $infile:"
					diskutil list /dev/$infile | grep 0: | awk '{print $3$4}'
				echo
				echo "Size of $outfile.img.dd.gz:"
					ls -lh $outfile.img.dd.gz | awk '{ print $5 }'
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
	lsblk
	echo

	echo "Which disk would you like to backup (ex: sdb. Do not include partition)?"
	read infile
	echo
	sleep 0.7

	echo "Name your backup image (A file extension of .img.dd.gz will be added.):"
	read outfile
	echo
	echo "The file $outfile.img.dd.gz will be saved to $(pwd)"
	echo
	sleep 0.7

	echo "Specify block size. Include unit of data in Upper-Case (ex: 64K, 512K, 1M):"
	read blocksize
	echo
	sleep 0.7

	echo "The following will be executed. Please review carefully:"
	echo
	sleep 1
	echo "sudo dd if=/dev/$infile bs=$blocksize | gzip -c > $outfile.img.dd.gz"
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
		
			echo "Unmounting all partitions on $infile"
				sudo umount /dev/"${infile}"* 2>/dev/null;
			echo
			sleep 0.7
			
			echo "Executing sudo dd if=/dev/$infile bs=$blocksize | gzip -c > $outfile.img.dd.gz"
			echo
			sleep 0.7
			echo "The script will exit when complete. Please be patient..."
                	sleep 0.7
                	echo
		
			sudo dd if=/dev/$infile bs=$blocksize | gzip -c > $outfile.img.dd.gz &
			pid=$!
			echo "dd pid: $pid"
			# If script is killed, kill dd
			trap "kill $pid 2> /dev/null" EXIT
			# While dd is running...
			while kill -0 $pid 2> /dev/null; 
			do 
				echo "-------------------------------"
				echo
				echo "Size of $infile:"
					lsblk /dev/sdb | grep sdb | awk '{print $4}'
				echo
				echo "Size of $outfile.img.dd.gz:"
					ls -lh $outfile.img.dd.gz | awk '{ print $5 }'
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
