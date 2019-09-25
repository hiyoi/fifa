nat_indexs=`iptables -nvL PREROUTING -t nat |sed 1,2d | sed -n '/SSTCP/='|sort -r`
for nat_index in $nat_indexs
do
	iptables -t nat -D PREROUTING $nat_index >/dev/null 2>&1
done

mangle_indexs=`iptables -nvL PREROUTING -t mangle |sed 1,2d | sed -n '/SSUDP/='|sort -r`
for mangle_index in $mangle_indexs
do
	iptables -t mangle -D PREROUTING $mangle_index >/dev/null 2>&1
done

iptables -t nat -F SSTCP >/dev/null 2>&1 && iptables -t nat -X SSTCP >/dev/null 2>&1
iptables -t mangle -F SSUDP >/dev/null 2>&1 && iptables -t mangle -X SSUDP >/dev/null 2>&1
#remove_redundant_rule
ip_rule_exist=`ip rule show | grep "lookup 310" | grep -c 310`
if [ -n "ip_rule_exist" ];then
	#echo_date 清除重复的ip rule规则.
	until [ "$ip_rule_exist" == "0" ]
	do 
		IP_ARG=`ip rule show | grep "lookup 310"|head -n 1|cut -d " " -f3,4,5,6`
		ip rule del $IP_ARG
		ip_rule_exist=`expr $ip_rule_exist - 1`
	done
fi
#remove_route_table
#echo_date 删除ip route规则.
ip route del local 0.0.0.0/0 dev lo table 310 >/dev/null 2>&1