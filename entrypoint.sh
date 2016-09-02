#!/bin/bash
set -ex

NIC_MORE_TRAFFIC=$(grep -vE "lo:|face|Inter" /proc/net/dev | sort -n -k 2 | tail -1 | awk '{ sub (":", "", $1); print $1 }')
if command -v ip; then
  if [ ${NETWORK_AUTO_DETECT} -eq 1 ]; then
    MON_IP=$(ip -6 -o a s $NIC_MORE_TRAFFIC | awk '{ sub ("/..", "", $4); print $4 }')
    if [ -z "$MON_IP" ]; then
      MON_IP=$(ip -4 -o a s $NIC_MORE_TRAFFIC | awk '{ sub ("/..", "", $4); print $4 }')
      CEPH_PUBLIC_NETWORK=$(ip r | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/[0-9]\{1,2\}' | head -1)
    fi
  elif [ ${NETWORK_AUTO_DETECT} -eq 4 ]; then
    MON_IP=$(ip -4 -o a s $NIC_MORE_TRAFFIC | awk '{ sub ("/..", "", $4); print $4 }')
    CEPH_PUBLIC_NETWORK=$(ip r | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/[0-9]\{1,2\}' | head -1)
  elif [ ${NETWORK_AUTO_DETECT} -eq 6 ]; then
    MON_IP=$(ip -6 -o a s $NIC_MORE_TRAFFIC | awk '{ sub ("/..", "", $4); print $4 }')
    CEPH_PUBLIC_NETWORK=$(ip r | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/[0-9]\{1,2\}' | head -1)
  fi
# best effort, only works with ipv4
# it is tough to find the ip from the nic only using /proc
# so we just take on of the addresses available
# which is fairely safe given that containers usually have a single nic
else
  MON_IP=$(grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' /proc/net/fib_trie | grep -vEw "^127|255$|0$" | head -1)
  CEPH_PUBLIC_NETWORK=$(grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}/[0-9]\{1,2\}' /proc/net/fib_trie | grep -vE "^127|^0" | head -1)
fi


sleep 300