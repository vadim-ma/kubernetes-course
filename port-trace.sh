#!/usr/bin/env bash

# Claude 4.5 Opus
# https://ai.yandex-team.ru/?shareId=68ce6dfa-f163-4f04-92b3-70973e201c73

cat << 'EOF' > ~/port-trace.sh
#!/bin/bash

PORT=${1:-80}
echo "=== Поиск для порта $PORT ==="

echo -e "\n[1] iptables NAT rules:"
sudo iptables -t nat -L -n -v --line-numbers | grep -E ":$PORT |dpt:$PORT" | head -20

echo -e "\n[2] nftables rules:"
sudo nft list ruleset 2>/dev/null | grep -E "dport $PORT|:$PORT" | head -20

echo -e "\n[3] Активные соединения (conntrack):"
sudo conntrack -L -p tcp --dport $PORT 2>/dev/null | head -10

echo -e "\n[4] Host namespace - кто слушает:"
sudo ss -tlnp | grep ":$PORT "

echo -e "\n[5] Все network namespaces - кто слушает:"
for ns in $(sudo ip netns list 2>/dev/null | awk '{print $1}'); do
    result=$(sudo ip netns exec $ns ss -tlnp 2>/dev/null | grep ":$PORT ")
    [ -n "$result" ] && echo "  netns [$ns]: $result"
done

echo -e "\n[6] Container network namespaces (через /proc):"
for pid in $(ps -eo pid --no-headers); do
    result=$(sudo nsenter -t $pid -n ss -tlnp 2>/dev/null | grep ":$PORT ")
    if [ -n "$result" ]; then
        pname=$(ps -p $pid -o comm= 2>/dev/null)
        echo "  PID $pid ($pname): $result"
    fi
done 2>/dev/null | sort -u | head -10

echo -e "\n[7] Kubernetes Services:"
kubectl get svc -A 2>/dev/null | grep -E "(:$PORT |/$PORT |^NAME)" | head -10

echo -e "\n[8] Kubernetes Endpoints для порта:"
kubectl get endpoints -A -o json 2>/dev/null | jq -r ".items[] | select(.subsets[]?.ports[]?.port == $PORT) | \"\(.metadata.namespace)/\(.metadata.name)\"" | head -10

EOF
chmod +x ~/port-trace.sh
