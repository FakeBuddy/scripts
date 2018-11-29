#!/bin/bash

declare -A servers=(["ac-redis01"]="192.168.5.4" ["ac-redis02"]="192.168.5.5" ["ac-redis03"]="192.168.5.6" ["ac-redis04"]="192.168.5.7" ["ac-redis05"]="192.168.5.8" ["ac-redis06"]="192.168.5.9")
for i in "${!servers[@]}"
do
    role=$(cut -d':' -f2 <<<"$(redis-cli -h ${servers[$i]} -p 6379 info replication | grep role)" | sed $'s/\r//')
    if [ $role = "slave" ] 
        then 
            echo $i
    fi
done
