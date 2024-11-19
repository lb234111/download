#!/bin/bash
# 获取当前时间(年月日时)，因为每个小时chainmaker会生成一个新的日志文件
# 下面的四句代码为了获取当前执行压测之后，所产生的日志所在文件的文件名
date=$(date +"%Y%m%d%H")
logDir="../build/release/chainmaker-v2.3.0-wx-org1.chainmaker.org/log/system.log."
logFile="$logDir$date"
blockConfigDir="../build/config/node1/chainconfig/bc1.yml"

# 获取最后一个块的提交时间、编号
LastCommit=$(cat $logFile | grep "commit block" | tail -n 1)
LastCommitTime=${LastCommit:0:23}
tmp=${LastCommit#*commit block [}
LastCommitNo=${tmp%]*}

# 获取倒数第50个块的提交时间、编号
FirstPropose=$(cat $logFile | grep "proposer success" | tail -n 50 | head -n 1)
FirstProposeTime=${FirstPropose:0:23}
tmp=${FirstPropose#*proposer success [}
FirstProposeNo=${tmp%]*}

# 从bc.yml配置文件获取块大小
capacityConfig=$(cat $blockConfigDir | grep 'block_tx_capacity')
block_tx_capacity=${capacityConfig#*: }

# 计算TPS
totalBlock=$((LastCommitNo - FirstProposeNo))
echo "TotalBlock: $totalBlock"
totalTx=$((totalBlock * block_tx_capacity))

LastCommitTimeFormatted=$(date -d "$LastCommitTime" +"%s.%N")
echo "Stop Time:  $LastCommitTimeFormatted"
FirstProposeTimeFormatted=$(date -d "$FirstProposeTime" +"%s.%N")
echo "Start Time: $FirstProposeTimeFormatted"

start_s=`echo $FirstProposeTimeFormatted | cut -d '.' -f 1`
start_ns=`echo $FirstProposeTimeFormatted | cut -d '.' -f 2`
end_s=`echo $LastCommitTimeFormatted | cut -d '.' -f 1`
end_ns=`echo $LastCommitTimeFormatted | cut -d '.' -f 2`

time_micro=$(( (10#$end_s-10#$start_s)*1000000 + (10#$end_ns/1000 - 10#$start_ns/1000) ))
time_ms=`expr $time_micro/1000 | bc`
echo "Time Interval: $time_ms(ms)"

TPS=$((totalTx * 1000 / time_ms))
echo "TPS for Highway: $TPS(Tx/s)"
