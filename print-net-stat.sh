#!/bin/sh
echo '统计：各种连接的数量:'
netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
