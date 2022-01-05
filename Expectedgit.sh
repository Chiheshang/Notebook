#!/bin/bash

echo "GitAutoPull Start"
git pull origin main
echo "GitAutoPull End"

echo "GitAutoPush Starting..."
time=$(date "+%Y-%m-%d %H:%M:%S")
git add .


git commit -m "默认提交, 提交人: $(whoami), 提交时间: ${time}"


	
git push origin main
echo "GitAutoPush End"

read -t 30 -p "同步结束" msg