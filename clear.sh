iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t nat -F SSTCP
iptables -t nat -X SSTCP 
iptables -t mangle -F
iptables -t mangle -X
iptables -t mangle -F SSUDP
iptables -t mangle -X SSUDP
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT