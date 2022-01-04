#!/bin/bash

echo "GitAutoPull Start"
git pull origin main
echo "GitAutoPull End"

echo "GitAutoPush Starting..."
time=$(date "+%Y-%m-%d %H:%M:%S")
git add .

read -t 30 -p "请输入提交注释:" msg

if  [ ! "$msg" ] ;then
    echo "[commit message] 默认提交, 提交人: $(whoami), 提交时间: ${time}"
	git commit -m "默认提交, 提交人: $(whoami), 提交时间: ${time}"
else
    echo "[commit message] $msg, 提交人: $(whoami), 提交时间: ${time}"
	git commit -m "$msg, 提交人: $(whoami), 提交时间: ${time}"
fi

	
git push origin main
echo "GitAutoPush End"

read -t 30 -p "同步结束" msg
ss