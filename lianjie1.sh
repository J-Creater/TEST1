#!/bin/bash
#SYN_RECV 表示正在等待处理的请求数
#ESTABLISHED 表示正常数据传输状态
#TIME_WAIT 表示处理完毕，等待超时结束的请求数
#FIN_WAIT1 表示server端主动要求关闭tcp连接
#FIN_WAIT2 表示客户端中断连接
#LAST_ACK 关闭一个TCP连接需要从两个方向上分别关闭，双方都是通过发送FIN来表示单方向数据的关闭，当通信双方发送了最后一个FIN的时候，发送方此时处于LAST_ACK状态，当发送方收到对方的确认（Fin的Ack确认
#）后才真正关闭整个TCP连接

#部署脚本 配置文件路径
export base_path=$(cd $(dirname $0); pwd)

#监控模式改成FTP方式-20210208
export ALERT_FILE_PATH=$base_path/monitor_client_logs/alertlogs
export ALERT_FILE_NUM=001

#获取当前时间
export current_day=`date +%Y%m%d%H%M%S`
echo "Current date: $current_day"

a=$(date "+%Y-%m-%d %H:%M:%S")
b32=$(ps -ef|grep httpd|wc -l)
c32=$(netstat -ant|grep -E "8088|8001|9008|9010"|wc -l)
d32=$(netstat -ant|grep -E "8088|8001|9008|9010"|grep EST |wc -l)
e32=$(netstat -n|awk '/^tcp/{++S[$NF]} END {for(a in S)print a,S[a]}')

timeH0=0
timeH8=8
timeH19=19
timeH24=24

#阀值参数，高于告警
f1=430
g1=530
f2=700
g2=800
#阀值参数，低于告警
f3=20
g3=30
f4=70
g4=80

#####################################################
#检查临时文件目录是否存在，不存在则进行创建
#####################################################
function check_tmp_dir()
{
	echo "----------------------------------------------初始化日志、临时目录开始-----------------------------------------------"
	#监控模式改成FTP方式-20210208
	if [ ! -d "${ALERT_FILE_PATH}" ];then
		echo "[WARN]日志目录${ALERT_FILE_PATH}不存在，正在创建...！"
		mkdir -p ${ALERT_FILE_PATH}
		if [ $? -eq 0 ]; then
			echo "[INFO]创建日志目录${ALERT_FILE_PATH}成功"
		else
			echo "[ERROR]创建日志目录${ALERT_FILE_PATH}失败，请检查"
			exit 1
		fi
	fi
	
	echo "----------------------------------------------初始化日志、临时目录结束-----------------------------------------------"
}

#####################################################
#生成OK标志文件 #监控模式改成FTP方式-20210208
#####################################################
function GenerateOKFile(){
	AppCode="YYXT"
	Node="10.32.32.32"
	
	echo "" >> ${ALERT_FILE_PATH}/${AppCode}_${Node}_${current_day}_${ALERT_FILE_NUM}.ok
}

#####################################################
#发短信小程序 监控模式改成FTP方式-20210208
#####################################################
function UniMonAlert()
{
	AppCode="YYXT"
	Node="10.32.32.32"
	echo "Node:${Node}"
	Severity="$1"
	KpiCode="$2"
	Summary="$3"
	# 1：告警 2：恢复
	if [ $1 -eq 0 ];then
		AlarmType=2
		Alarm_Type="恢复告警"
	else
		AlarmType=1
		Alarm_Type="监控告警"
	fi
	echo "[应用系统][${Alarm_Type}][$Node]发送告警信息到统一监控平台, 指标[$KpiCode], 告警内容[$Summary], 告警级别[$Severity] 告警类型[$AlarmType], 发送时间[`date`]"

	#监控模式改成FTP方式-20210208
	AlertMsg="${AppCode}@${Node}@${Severity}@${KpiCode}@${Summary}"
	echo "${AlertMsg}" >> ${ALERT_FILE_PATH}/${AppCode}_${Node}_${current_day}_${ALERT_FILE_NUM}.log
}

function connectMax()(       
        dateH=$(date "+%-H")
        if [ $dateH -ge $timeH0 -a $dateH -lt $timeH8  ]
        then
						#监控大于阈值的告警
                        if [ $d32 -gt $f1 ]
                        then
                            echo "当前连接数$d32超出$f1"
                            UniMonAlert 2 SJYH32WEB_CON_GT_1  手机银行WEB32当前连接$d32超阀值$f1
                        else 
                            UniMonAlert 0 SJYH32WEB_CON_GT_1  手机银行WEB32当前连接$d32不超阀值$f1
                        fi 
                        if [ $c32 -gt $g1 ]
                        then
                            echo "当前总连接数$c32超出$g1"
                            UniMonAlert 2 SJYH32WEB_CON_SUM_GT_1  手机银行WEB32当前总连接$c32超阀值$g1
                        else 
                            UniMonAlert 0 SJYH32WEB_CON_SUM_GT_1  手机银行WEB32当前总连接$c32不超阀值$g1
                        fi

						#监控小于阈值的告警
						if [ $d32 -lt $f3 ]
                        then
                            echo "当前连接数$d32低于$f3"
                            UniMonAlert 2 SJYH32WEB_CON_LT_1  手机银行WEB32当前连接$d32低于阀值$f3
                        else 
                            UniMonAlert 0 SJYH32WEB_CON_LT_1  手机银行WEB32当前连接$d32超阀值$f3
                        fi 
                        if [ $c32 -lt $g3 ]
                        then
                            echo "当前总连接数$c32低于$g3"
                            UniMonAlert 2 SJYH32WEB_CON_SUM_LT_1  手机银行WEB32当前总连接$c32低于阀值$g3
                        else 
                            UniMonAlert 0 SJYH32WEB_CON_SUM_LT_1  手机银行WEB32当前总连接$c32超阀值$g3
                        fi
        fi
        
        if [ $dateH -ge $timeH8 -a $dateH -lt $timeH19  ]
        then
						#监控大于阈值的告警        
                        if [ $d32 -gt $f2 ]
                        then
                            echo "当前连接数$d32超出$f2"
                            UniMonAlert 2 SJYH32WEB_CON_GT_2  手机银行WEB32当前连接$d32超阀值$f2
                        else 
                            UniMonAlert 0 SJYH32WEB_CON_GT_2  手机银行WEB32当前连接$d32不超阀值$f2
                        fi 
                        if [ $c32 -gt $g2 ]
                        then
                            echo "当前总连接数$c32超出$g2"
                            UniMonAlert 2 SJYH32WEB_CON_SUM_GT_2  手机银行WEB32当前总连接$c32超阀值$g2
                        else 
                            UniMonAlert 0 SJYH32WEB_CON_SUM_GT_2  手机银行WEB32当前总连接$c32不超阀值$g2
                        fi

						#监控小于阈值的告警
						if [ $d32 -lt $f4 ]
                        then
                            echo "当前连接数$d32低于$f4"
                            UniMonAlert 2 SJYH32WEB_CON_LT_2  手机银行WEB32当前连接$d32低于阀值$f4
                        else 
                            UniMonAlert 0 SJYH32WEB_CON_LT_2  手机银行WEB32当前连接$d32超阀值$f4
                        fi 
                        if [ $c32 -lt $g4 ]
                        then
                            echo "当前总连接数$c32低于$g4"
                            UniMonAlert 2 SJYH32WEB_CON_SUM_LT_2  手机银行WEB32当前总连接$c32低于阀值$g4
                        else 
                            UniMonAlert 0 SJYH32WEB_CON_SUM_LT_2  手机银行WEB32当前总连接$c32超阀值$g4
                        fi
		fi
        
        if [ $dateH -ge $timeH19 -a $dateH -lt $timeH24  ]
        then
						#监控大于阈值的告警
                        if [ $d32 -gt $f1 ]
                        then
                            echo "当前连接数$d32超出$f1"
                            UniMonAlert 2 SJYH32WEB_CON_GT_3  手机银行WEB32当前连接$d32超阀值$f1
                        else 
                            UniMonAlert 0 SJYH32WEB_CON_GT_3  手机银行WEB32当前连接$d32不超阀值$f1
                        fi 
                        if [ $c32 -gt $g1 ]
                        then
                            echo "当前总连接数$c32超出$g1"
                            UniMonAlert 2 SJYH32WEB_CON_SUM_GT_3  手机银行WEB32当前总连接$c32超阀值$g1
                        else 
                            UniMonAlert 0 SJYH32WEB_CON_SUM_GT_3  手机银行WEB32当前总连接$c32不超阀值$g1
                        fi
                        
						#监控小于阈值的告警
						if [ $d32 -lt $f3 ]
                        then
                            echo "当前连接数$d32低于$f3"
                            UniMonAlert 2 SJYH32WEB_CON_LT_3  手机银行WEB32当前连接$d32低于阀值$f3
                        else 
                            UniMonAlert 0 SJYH32WEB_CON_LT_3  手机银行WEB32当前连接$d32超阀值$f3
                        fi 
                        if [ $c32 -lt $g3 ]
                        then
                            echo "当前总连接数$c32低于$g3"
                            UniMonAlert 2 SJYH32WEB_CON_SUM_LT_3  手机银行WEB32当前总连接$c32低于阀值$g3
                        else 
                            UniMonAlert 0 SJYH32WEB_CON_SUM_LT_3  手机银行WEB32当前总连接$c32超阀值$g3
                        fi
        fi
)
Current_Time=`date "+%Y-%m-%d %H:%M:%S"`
echo "-------------------------------------[$Current_Time]开始监控------------------------------------"
check_tmp_dir
connectMax
GenerateOKFile
echo "$a WEB服务器10.32.32.32 线程中http数量:$b32 当前连接数:$d32 总连接数:$c32"
echo "连接数详细信息:"
echo "$e32"
echo "-------------------------------------[$Current_Time]监控结束------------------------------------"
echo -e "\n"
