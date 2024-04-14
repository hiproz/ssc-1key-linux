#!/bin/sh

## prepare 
sudo apt -y update
sudo apt upgrade
sudo apt -y install python3 python3-pip

## ss client
## ss 要安装到root全局角色，否则可能会提示shadowsocks.local module的问题
sudo pip install https://github.com/shadowsocks/shadowsocks/archive/master.zip -U
sudo apt-get install -y libsodium*

## issue 问题修复，基于22.04测试的，如果后面系统问题了，就需要灵活修改
sudo cp lru_cache.py /usr/local/lib/python3.10/dist-packages/shadowsocks/lru_cache.py
sudo sudo ln -s /usr/lib/x86_64-linux-gnu/libsodium.a /usr/lib/x86_64-linux-gnu/liblibsodium.a

## config the ss client
cat <<EOF > tmp
{
  "server": "您服务器地址",
  "server_port": 9999,
  "local_address": "127.0.0.1",
  "local_port": 1080,
  "password": "密码",
  "timeout": 600,
  "method": "aes-256-gcm"
}
EOF

if [ ! -f "/etc/shadowsocks.json" ]; then
    sudo mv tmp /etc/shadowsocks.json
fi

sudo chmod 777 /var/log
sudo chmod 777 /var/run

cat <<EOF >tmp
Description=Shadowsocks Client Service
After=network.target
[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/sslocal -c /etc/shadowsocks.json restart
[Install]
WantedBy=multi-user.target
EOF

if [ ! -f "/etc/systemd/system/shadowsocks.service" ]; then
    sudo mv tmp /etc/systemd/system/shadowsocks.service
fi

sudo systemctl enable shadowsocks.service
sudo systemctl restart shadowsocks.service

## install polipo
if [ ! -f "polipo_1.1.1-8_amd64.deb" ]; then
    wget http://archive.ubuntu.com/ubuntu/pool/universe/p/polipo/polipo_1.1.1-8_amd64.deb
fi

sudo dpkg -i polipo_1.1.1-8_amd64.deb

cat <<EOF > tmp
logSyslog = true
logFile = /var/log/polipo/polipo.log
proxyAddress = "0.0.0.0"
socksParentProxy = "127.0.0.1:1080"
socksProxyType = socks5
chunkHighMark = 50331648
objectHighMark = 16384
serverMaxSlots = 64
serverSlots = 16
serverSlots1 = 32
EOF
sudo mv tmp /etc/polipo/config

#export http_proxy=http://127.0.0.1:8123
#export https_proxy=http://127.0.0.1:8123
if ! grep -q "https" $HOME/.profile; then
    #sudo echo 'export PATH="$PATH:/home/zcj/.local/bin"'>>$HOME/.profile
    sudo echo 'export http_proxy=http://127.0.0.1:8123'>>$HOME/.profile
    sudo echo 'export https_proxy=http://127.0.0.1:8123'>>$HOME/.profile
fi

echo  start polipo finished...
sudo reboot

## privoxy
# sudo apt install -y privoxy
# systemctl enable privoxy
# systemctl restart privoxy

#sudo echo 'export http_proxy=http://127.0.0.1:8118'>>$HOME/.profile
#sudo echo 'export https_proxy=http://127.0.0.1:8118'>>$HOME/.profile

