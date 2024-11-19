#!/bin/bash
# 获取当前时间(年月日时)，因为每个小时chainmaker会生成一个新的日志文件
# 下面的四句代码为了获取当前执行压测之后，所产生的日志所在文件的文件名
rm -f highwayPropose.csv
rm -f highwayCommit.csv
date=$(date +"%Y%m%d%H")
logDir="../build/release/chainmaker-v2.3.0-wx-org1.chainmaker.org/log/system.log."
logFile="$logDir$date"
blockConfigDir="../build/config/node1/chainconfig/bc1.yml"

# 获取倒数第50个块的提交时间、编号
AllPropose=$(cat $logFile | grep "proposer success" | tail -n 50)
while IFS= read -r line
do
	timestamp=${line:0:23}
	tmp=${line#*proposer success [}
	No=${tmp%]*}
	tmp=${line#*(txs:}
	txs=${tmp%%)*}
	echo "$timestamp	$No	$txs" >> highwayPropose.csv
done <<< "$AllPropose"
FirstProposeTime=${FirstPropose:0:23}

# 获取倒数第50个块的提交时间、编号
AllCommit=$(cat $logFile | grep "commit block" | tail -n 200)
while IFS= read -r line
do
	timestamp=${line:0:23}
	tmp=${line#*commit block [}
	No=${tmp%]*}
	tmp=${line#*(count:}
	txs=${tmp%%,*}
	echo "$timestamp	$No	$txs" >> highwayCommit.csv
done <<< "$AllCommit"
FirstProposeTime=${FirstPropose:0:23}