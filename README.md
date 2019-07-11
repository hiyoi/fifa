# fifa19 $$加速游戏
交流群:

<img src="https://github.com/hiyoi/fifa/blob/master/screenshot/qrcode.jpg" width="20%" height="20%">

* 梅林路由器和其他能跑ss的路由器同样可以，群里有老哥测试成功了。

这个方案比较适合需要中转路线连港服的地区,服务器是自己搭的，相当于专线加速
### 准备工作
* [一台openwrt路由器](https://openwrt.org/)
* [aliyun深圳服务器,这边使用的是366块一年的那款](https://promotion.aliyun.com/ntms/yunparter/invite.html?userCode=e8zawwrp)

### 服务器篇
服务器上需要安装$$-libev

如果是Debian8 或 Ubuntu16.10，直接两条命令安装
```
sudo apt update
sudo apt install shadowsocks-libev
```
Centos7的则需要自己编译安装,安装方法参考[官方文档](https://github.com/shadowsocks/shadowsocks-libev#debian--ubuntu)

安装完在控制台打一下`ss-server -h`命令确认安装成功
#### 配置
加速游戏需要同时使用tcp和udp,后面可能要用到udp2raw,所以配置的时候分开配置

在命令行中,先切换至用户主目录`cd ~`

新建一个加速tcp的配置文件`touch sst.json`
配置如下:
```
{
	"server":"0.0.0.0",
	"server_port":16888,
	"local_port":1080,
	"password":"xxxxxx",
	"timeout":60,
	"fast_open": true,
	"reuse_port": true,
	"no_delay":true,
	"method":"chacha20-ietf-poly1305"
}
```
然后新建一个加速udp的配置文件 `touch ssu.json`
配置如下:
```
{
	"server":"0.0.0.0",
	"server_port":16888,
	"local_port":1080,
	"password":"xxxxxx",
	"timeout":60,
	"fast_open": false,
	"reuse_port": true,
	"method":"chacha20-ietf-poly1305"
}
```
#### 运行
之后就可以运行$$了,两条命令
```
ss-server -c sst.json -a nobody -f sst.pid
ss-server -c ssu.json -a nobody -U -f ssu.pid
```
用`ps aux|grep ss-server` 查看是否成功运行,否则检查前面哪里出问题

到此服务器的$$就配置好了

### 路由器篇(客户端)

手头上只有一台树莓派,刷了openwrt后,某宝购入一个usb网卡用来做路由
![1](https://github.com/hiyoi/fifa/blob/master/screenshot/1.png)

openwrt中要实现udp转发,要用iptables的tproxy模块,需要手动安装一些包
```
opkg update
opkg install iptables-mod-tproxy kmod-ipt-tproxy ip
```

设置好路由器的wan和lan,这里wan使用上级路由的网段`192.168.50.161`,lan使用`192.168.110.1`

安装$$-redir,openwrt比较简单,只需在Luci web控制界面中的 software中搜索`shadowsocks-libev`,安装下面几个包:
![2](https://github.com/hiyoi/fifa/blob/master/screenshot/2.png)
之后配置运行$$-redir
![3](https://github.com/hiyoi/fifa/blob/master/screenshot/3.png)
![4](https://github.com/hiyoi/fifa/blob/master/screenshot/4.png)
### 防火墙篇(重点)

最后要配置 iptables来实现$$的透明代理和udp转发，以及锁定中亚服务器, 配置如下(将xxx.xxx.xxx.xxx换成你的aliyun服务器ip地址)
![5](https://github.com/hiyoi/fifa/blob/master/screenshot/5.png)

```
# clear iptables first
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Create new chain
iptables -t nat -N sstcp
iptables -t mangle -N ssudp

# 这里xxx填你自己的ss地址
iptables -t nat -A sstcp -d xxx.xxx.xxx.xxx -j RETURN

iptables -t nat -A sstcp -d 0.0.0.0/8 -j RETURN
iptables -t nat -A sstcp -d 10.0.0.0/8 -j RETURN
iptables -t nat -A sstcp -d 127.0.0.0/8 -j RETURN
iptables -t nat -A sstcp -d 169.254.0.0/16 -j RETURN
iptables -t nat -A sstcp -d 172.16.0.0/12 -j RETURN
iptables -t nat -A sstcp -d 192.168.0.0/16 -j RETURN
iptables -t nat -A sstcp -d 224.0.0.0/4 -j RETURN
iptables -t nat -A sstcp -d 240.0.0.0/4 -j RETURN

# 这里最后的1080 改成你的ss的local port
iptables -t nat -A sstcp -p tcp -j REDIRECT --to-ports 1080

ip rule add fwmark 0x01/0x01 table 100
ip route add local 0.0.0.0/0 dev lo table 100

# 这里xxx填你自己的ss地址
iptables -t mangle -A ssudp -d xxx.xxx.xxx.xxx -j RETURN

iptables -t mangle -A ssudp -d 0.0.0.0/8 -j RETURN
iptables -t mangle -A ssudp -d 10.0.0.0/8 -j RETURN
iptables -t mangle -A ssudp -d 127.0.0.0/8 -j RETURN
iptables -t mangle -A ssudp -d 169.254.0.0/16 -j RETURN
iptables -t mangle -A ssudp -d 172.16.0.0/12 -j RETURN
iptables -t mangle -A ssudp -d 192.168.0.0/16 -j RETURN
iptables -t mangle -A ssudp -d 224.0.0.0/4 -j RETURN
iptables -t mangle -A ssudp -d 240.0.0.0/4 -j RETURN
iptables -t mangle -A ssudp -d 109.200.215.132/32 -j DROP
iptables -t mangle -A ssudp -d 109.200.215.140/32 -j DROP
iptables -t mangle -A ssudp -d 109.200.221.170/31 -j DROP
iptables -t mangle -A ssudp -d 159.153.165.200/31 -j DROP
iptables -t mangle -A ssudp -d 159.153.28.50/31 -j DROP
iptables -t mangle -A ssudp -d 159.153.36.60/30 -j DROP
iptables -t mangle -A ssudp -d 159.153.42.240/31 -j DROP
iptables -t mangle -A ssudp -d 169.38.100.162/32 -j DROP
iptables -t mangle -A ssudp -d 169.38.100.170/32 -j DROP
iptables -t mangle -A ssudp -d 169.57.76.162/32 -j DROP
iptables -t mangle -A ssudp -d 169.57.76.171/32 -j DROP
iptables -t mangle -A ssudp -d 18.184.251.35/32 -j DROP
iptables -t mangle -A ssudp -d 18.196.167.42/32 -j DROP
iptables -t mangle -A ssudp -d 18.197.48.114/32 -j DROP
iptables -t mangle -A ssudp -d 18.202.247.216/32 -j DROP
iptables -t mangle -A ssudp -d 185.179.200.211/32 -j DROP
iptables -t mangle -A ssudp -d 185.179.200.226/32 -j DROP
iptables -t mangle -A ssudp -d 185.179.203.68/32 -j DROP
iptables -t mangle -A ssudp -d 185.179.203.80/32 -j DROP
iptables -t mangle -A ssudp -d 185.50.104.206/32 -j DROP
iptables -t mangle -A ssudp -d 185.50.104.221/32 -j DROP
iptables -t mangle -A ssudp -d 203.195.120.68/32 -j DROP
iptables -t mangle -A ssudp -d 203.195.122.124/32 -j DROP
iptables -t mangle -A ssudp -d 52.58.40.163/32 -j DROP

#这里的1080同样改成ss的local port
iptables -t mangle -A ssudp -p udp  -j TPROXY --on-port 1080 --tproxy-mark 0x01/0x01

# 这里的192.168.110.0/25网段改成你自己的路由器网段
iptables -t nat -A PREROUTING -s 192.168.110.0/25 -p tcp -j sstcp
iptables -t mangle -A PREROUTING -s  192.168.110.0/25 -j ssudp
```

注意上面最后两条规则,把子网掩码设置为25位,这样只转发192.168.110.1~192.168.110.126的设备,后面我们的ps4手动设置到这个范围内就能使用加速,设置大于这个网段则不使用。


配置完成后重启防火墙,将ps4接上路由器lan,然后手动配置网络
![6](https://github.com/hiyoi/fifa/blob/master/screenshot/6.jpg)
![7](https://github.com/hiyoi/fifa/blob/master/screenshot/7.jpg)
![8](https://github.com/hiyoi/fifa/blob/master/screenshot/8.jpg)

最后测试ps4网络，下载速度为 1Mb/s(服务器的带宽),则代理成功

测试游戏DR模式,openwrt中监控可以看到已经连上港服
![9](https://github.com/hiyoi/fifa/blob/master/screenshot/9.png)

游戏中稳定4格，偶尔还会出现5格情况。
![10](https://github.com/hiyoi/fifa/blob/master/screenshot/10.jpg)

以上防火墙规则适用使用iptables的路由器,因为转发udp流量需要tproxy模块,像梅林固件这些系统有待测试



### 参考
* [用树莓派做路由器，搭建透明代理，加速游戏主机的网络](https://github.com/wangyu-/UDPspeeder/wiki/%E7%94%A8%E6%A0%91%E8%8E%93%E6%B4%BE%E5%81%9A%E8%B7%AF%E7%94%B1%E5%99%A8%EF%BC%8C%E6%90%AD%E5%BB%BA%E9%80%8F%E6%98%8E%E4%BB%A3%E7%90%86%EF%BC%8C%E5%8A%A0%E9%80%9F%E6%B8%B8%E6%88%8F%E4%B8%BB%E6%9C%BA%E7%9A%84%E7%BD%91%E7%BB%9C)
* [用openwrt路由器搭建透明代理，加速局域网内所有设备](https://github.com/wangyu-/tinyfecVPN/wiki/%E7%94%A8openwrt%E8%B7%AF%E7%94%B1%E5%99%A8%E6%90%AD%E5%BB%BA%E9%80%8F%E6%98%8E%E4%BB%A3%E7%90%86%EF%BC%8C%E5%8A%A0%E9%80%9F%E5%B1%80%E5%9F%9F%E7%BD%91%E5%86%85%E6%89%80%E6%9C%89%E8%AE%BE%E5%A4%87)
* [ssr-redir是否支持-u启动udp的代理](https://github.com/bettermanbao/openwrt-shadowsocksR-libev-full/issues/33)


### 测试相关

1M带宽可能会是瓶颈,踢球有种带铅球的感觉。

测试把带宽临时提到5M,踢球时丝般顺滑,也无需再开udp2raw,因此推荐配置服务器时尽量用2M以上的带宽(虽然很贵)

