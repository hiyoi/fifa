# 梅林固件使用方法

1. 确保路由器安装了ss插件,设置好节点后,开关一次,确保开关状态为关,保存应用
![merlin](https://github.com/hiyoi/fifa/blob/master/screenshot/merlin.png)

2. 路由器中执行命令`curl https://raw.githubusercontent.com/hiyoi/fifa/master/merlin.sh|sh`

3. ps4 ip地址手动设置到192.168.50.2～192.168.50.126(以路由器网段为准,192.168.1.0的则把50改成1) 范围内的任意一个,然后测速，如果是ss的带宽那么就成功了


ps: 可以在路由器中设置dhcp的ip范围为192.168.50.127～192.168.50.254,这样自动获取ip的设备就不会走代理
![dhcp](https://github.com/hiyoi/fifa/blob/master/screenshot/dhcp.png)
