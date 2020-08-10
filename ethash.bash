#!/usr/bin/bash

#PhoenixMiner DaggerHashimito Cryptomining
gpus=""
default="a"
commandline=""

echo "PhoenixMiner ethash algorithm Bash runner"
echo ""
read -p "GPU1, GPU2 or All GPUs ? [1/2/A] " -n 1 gpus
gpus=${gpus:-${default}}
echo ""

if [ "$gpus" = "1" ] || [ "$gpus" = "2" ]; then
	commandline="-gpus $gpus"
fi

result=$(pgrep -f 'SCREEN -S ethash')

if [ ! -z "$result" ]; then
	echo "Quit old instance of ethash algorithm"
	screen -r ethash -X quit
fi

echo "Start new instance of ethash algorithm"
/opt/mining/ethash/PhoenixMiner/start_miner.sh $commandline
