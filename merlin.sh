source /koolshare/scripts/base.sh
eval `dbus export ss`
cur_node=$ssconf_basic_node
value="\$ssconf_basic_server_"$cur_node
type="\$ssconf_basic_type_"$cur_node
tmp="export ss_basic_server=$value"
eval $tmp
tmp_type="export ss_basic_type=$type"
eval $tmp_type
lan=$(nvram get lan_ipaddr)                                  
lan_ip=$lan"/25"

if [ "$ss_basic_type" == "0" ];then
	killall ss-redir >/dev/null 2>&1
	killall rss-redir >/dev/null 2>&1
	ss-redir -c /koolshare/ss/ss.json --reuse-port -u -f /var/run/ss_1.pid
	ss-redir -c /koolshare/ss/ss.json --reuse-port -u -f /var/run/ss_2.pid
elif [ "$ss_basic_type" == "1" ];then
	killall ss-redir >/dev/null 2>&1
	killall rss-redir >/dev/null 2>&1
	rss-redir -c /koolshare/ss/ss.json --reuse-port -u -f /var/run/ss_1.pid
	rss-redir -c /koolshare/ss/ss.json --reuse-port -u -f /var/run/ss_2.pid
fi

load_tproxy(){
	MODULES="nf_tproxy_core xt_TPROXY xt_socket xt_comment"
	OS=$(uname -r)
	# load Kernel Modules
	checkmoduleisloaded(){
		if lsmod | grep $MODULE &> /dev/null; then return 0; else return 1; fi;
	}
	
	for MODULE in $MODULES; do
		if ! checkmoduleisloaded; then
			insmod /lib/modules/${OS}/kernel/net/netfilter/${MODULE}.ko >/dev/null 2>&1
		fi
	done
	
	modules_loaded=0
	
	for MODULE in $MODULES; do
		if checkmoduleisloaded; then
			modules_loaded=$(( j++ )); 
		fi
	done
}

get_wan0_cidr(){
	local netmask=`nvram get wan0_netmask`
	local x=${netmask##*255.}
	set -- 0^^^128^192^224^240^248^252^254^ $(( (${#netmask} - ${#x})*2 )) ${x%%.*}
	x=${1%%$3*}
	suffix=$(( $2 + (${#x}/4) ))
	prefix=`nvram get wan0_ipaddr`
	if [ -n "$prefix" -a -n "$netmask" ];then
		echo $prefix/$suffix
	else
		echo ""
	fi
}

load_tproxy

iptables -t nat -N SSTCP
iptables -t mangle -N SSUDP
# 白名单(不走ss)
ip_lan="0.0.0.0/8 10.0.0.0/8 100.64.0.0/10 127.0.0.0/8 169.254.0.0/16 172.16.0.0/12 192.168.0.0/16 224.0.0.0/4 240.0.0.0/4 223.5.5.5 223.6.6.6 114.114.114.114 114.114.115.115 1.2.4.8 210.2.4.8 117.50.11.11 117.50.22.22 180.76.76.76 119.29.29.29 $(get_wan0_cidr)"

iptables -t nat -A SSTCP -d $ss_basic_server -j RETURN
for ip in $ip_lan
do
	iptables -t nat -A SSTCP -d $ip -j RETURN
done

iptables -t nat -A SSTCP -p tcp -j REDIRECT --to-ports 3333

ip rule add fwmark 0x07 table 310 >/dev/null 2>&1
ip route add local 0.0.0.0/0 dev lo table 310 >/dev/null 2>&1

iptables -t mangle -A SSUDP -d $ss_basic_server -j RETURN
for ip in $ip_lan
do
	iptables -t mangle -A SSUDP -d $ip -j RETURN
done


#锁中亚
iptables -t mangle -A SSUDP -d 109.200.215.132/32 -j DROP
iptables -t mangle -A SSUDP -d 109.200.215.140/32 -j DROP
iptables -t mangle -A SSUDP -d 109.200.221.170/31 -j DROP
iptables -t mangle -A SSUDP -d 159.153.165.200/31 -j DROP
iptables -t mangle -A SSUDP -d 159.153.28.50/31 -j DROP
iptables -t mangle -A SSUDP -d 159.153.36.60/30 -j DROP
iptables -t mangle -A SSUDP -d 159.153.42.240/31 -j DROP
iptables -t mangle -A SSUDP -d 169.38.100.162/32 -j DROP
iptables -t mangle -A SSUDP -d 169.38.100.170/32 -j DROP
iptables -t mangle -A SSUDP -d 169.57.76.162/32 -j DROP
iptables -t mangle -A SSUDP -d 169.57.76.171/32 -j DROP
iptables -t mangle -A SSUDP -d 18.184.251.35/32 -j DROP
iptables -t mangle -A SSUDP -d 18.196.167.42/32 -j DROP
iptables -t mangle -A SSUDP -d 18.197.48.114/32 -j DROP
iptables -t mangle -A SSUDP -d 18.202.247.216/32 -j DROP
iptables -t mangle -A SSUDP -d 18.194.80.253/32 -j DROP
iptables -t mangle -A SSUDP -d 185.179.200.211/32 -j DROP
iptables -t mangle -A SSUDP -d 185.179.200.226/32 -j DROP
iptables -t mangle -A SSUDP -d 185.179.203.68/32 -j DROP
iptables -t mangle -A SSUDP -d 185.179.203.80/32 -j DROP
iptables -t mangle -A SSUDP -d 185.50.104.206/32 -j DROP
iptables -t mangle -A SSUDP -d 185.50.104.221/32 -j DROP
iptables -t mangle -A SSUDP -d 203.195.120.68/32 -j DROP
iptables -t mangle -A SSUDP -d 203.195.122.124/32 -j DROP
iptables -t mangle -A SSUDP -d 52.58.40.163/32 -j DROP
iptables -t mangle -A SSUDP -p udp  -j TPROXY --on-port 3333 --tproxy-mark 0x07 >/dev/null 2>&1

iptables -t nat -A PREROUTING -s $lan_ip -p tcp -j SSTCP >/dev/null 2>&1
iptables -t mangle -A PREROUTING -s $lan_ip -j SSUDP >/dev/null 2>&1

if [ $(iptables-save -t nat|grep SSTCP|wc -l) -gt 1 ]; then
	echo "succeed!"
	echo "forward data "$lan_ip" to ss"
	echo "How to fix it? use command \"curl https://raw.githubusercontent.com/hiyoi/fifa/master/clear.sh|sh\" or reboot your router!"
else
	echo "failed!"
fi
