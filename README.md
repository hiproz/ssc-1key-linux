# ssc-1key-linux
linux下一键安装shadowsocks客户端的脚本

解决 访问android，chrome，github源码等网络不畅的问题。

## linux系统
ubuntu 22.04

## 安装
`./ssc-1key-install.sh`

如果有错就排错。

## 配置ss
安装完成后，生成的ss配置是默认的无效配置，需要根据自己的ss资源实际配置。

```
{
  "server": "您服务器地址",
  "server_port": 9999,
  "local_address": "127.0.0.1",
  "local_port": 1080,
  "password": "密码",
  "timeout": 600,
  "method": "aes-256-gcm"
}
```
需要根据你的ss 服务器实际情况，修改以上参数

## 检查
```
ps -ef|grep sslocal
ps -er|grep polipo
echo $http_proxy
```
如果以上的结果都对，那么就可以开始使用了。
