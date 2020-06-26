#!/usr/bin/bash

#Noncerpro Argon2d Cryptomining
gpus=""
default="a"
commandline=""

echo "Noncerpro argon2d algorithm Bash runner"
echo ""
read -p "GPU0, GPU1 or All GPUs ? [0/1/A] " -n 1 gpus
gpus=${gpus:-${default}}
echo ""

if [ "$gpus" = "0" ] || [ "$gpus" = "1" ]; then
	commandline="-d=$gpus"
fi

result=$(pgrep -f 'SCREEN -S argon2d')

if [ ! -z "$result" ]; then
	echo "Quit old instance of argon2d algorithm"
	screen -r argon2d -X quit
fi

echo "Start new instance of argon2d algorithm"
/opt/mining/argon2d/mine.sh $commandline
