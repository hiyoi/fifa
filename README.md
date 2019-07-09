# fifa19 $$加速游戏
这个方案比较适合需要中转路线连港服的地区
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
