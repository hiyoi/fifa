# fifa $$加速游戏
交流群:

<img src="https://github.com/hiyoi/fifa/blob/master/screenshot/qrcode.png" width="20%" height="20%">

### 梅林固件

1. 确保路由器安装了ss插件,设置好节点后,开关一次,确保最后插件的状态是关的,保存应用
![merlin](https://github.com/hiyoi/fifa/blob/master/screenshot/merlin.png)

2. 路由器中执行命令(可以使用shellinabox):

`curl https://raw.githubusercontent.com/hiyoi/fifa/master/merlin.sh|sh`

![shell](https://github.com/hiyoi/fifa/blob/master/screenshot/shell.png)

3. ps4 ip地址手动设置到192.168.50.2～192.168.50.126(以路由器网段为准,截图中的路由器网段是192.168.110.0) 范围内的任意一个,然后测速，如果是ss的带宽那么就成功了

![6](https://github.com/hiyoi/fifa/blob/master/screenshot/6.jpg)
![7](https://github.com/hiyoi/fifa/blob/master/screenshot/7.jpg)
![8](https://github.com/hiyoi/fifa/blob/master/screenshot/8.jpg)

游戏中稳定4格，偶尔还会出现5格情况。
![10](https://github.com/hiyoi/fifa/blob/master/screenshot/10.jpg)


## ps: 
- 可以在路由器中设置dhcp的ip范围为192.168.50.127～192.168.50.254,这样自动获取ip的设备就不会走代理
![dhcp](https://github.com/hiyoi/fifa/blob/master/screenshot/dhcp.png)


### 服务器ss搭载教程(自己有ss节点就可以跳过这步)
服务器上需要安装$$-libev

如果是Debian8 或 Ubuntu16.10，直接两条命令安装
```
sudo apt update
sudo apt install shadowsocks-libev
```
Centos7的则需要自己编译安装,安装方法参考[官方文档](https://github.com/shadowsocks/shadowsocks-libev#debian--ubuntu)

安装完在控制台打一下`ss-server -h`命令确认安装成功
#### 配置

在命令行中,先切换至用户主目录`cd ~`

新建一个配置文件`ss.json`
复制粘贴以下命令回车:
```
cat >ss.json<<EOF
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
EOF
```

完成后使用命令`cat ss.json`检查一下配置是否正确

#### 运行
之后就可以运行$$了,确保 `-u`存在不要漏了(这个参数是开启udp转发)
```
ss-server -c ss.json -a nobody -u -f ss.pid
```
用`ps aux|grep ss-server` 查看是否成功运行,否则检查前面哪里出问题

到此服务器的$$就配置好了







### 参考
* [用树莓派做路由器，搭建透明代理，加速游戏主机的网络](https://github.com/wangyu-/UDPspeeder/wiki/%E7%94%A8%E6%A0%91%E8%8E%93%E6%B4%BE%E5%81%9A%E8%B7%AF%E7%94%B1%E5%99%A8%EF%BC%8C%E6%90%AD%E5%BB%BA%E9%80%8F%E6%98%8E%E4%BB%A3%E7%90%86%EF%BC%8C%E5%8A%A0%E9%80%9F%E6%B8%B8%E6%88%8F%E4%B8%BB%E6%9C%BA%E7%9A%84%E7%BD%91%E7%BB%9C)
* [用openwrt路由器搭建透明代理，加速局域网内所有设备](https://github.com/wangyu-/tinyfecVPN/wiki/%E7%94%A8openwrt%E8%B7%AF%E7%94%B1%E5%99%A8%E6%90%AD%E5%BB%BA%E9%80%8F%E6%98%8E%E4%BB%A3%E7%90%86%EF%BC%8C%E5%8A%A0%E9%80%9F%E5%B1%80%E5%9F%9F%E7%BD%91%E5%86%85%E6%89%80%E6%9C%89%E8%AE%BE%E5%A4%87)
* [ssr-redir是否支持-u启动udp的代理](https://github.com/bettermanbao/openwrt-shadowsocksR-libev-full/issues/33)

