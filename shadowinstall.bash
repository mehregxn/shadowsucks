#!/bin/bash


#Find out which Linux distro is used
distro=$(awk -F= '/^NAME/{print $2}' /etc/os-release)


#generating random port
num_regex='^[0-9]+$'
GetRandomPort() {
	PORT=$((RANDOM % 16383 + 49152))
}

GenerateRandomPassword() {
    chars='abcdefghijklmnopqrstuvwxyz1234567890'
n=36

RANDOMPASS=
for ((i = 0; i < n; ++i)); do
    RANDOMPASS+=${chars:RANDOM%${#chars}:1}
    done
}


# checking root priviledge
[ `whoami` != "root" ] && echo "\033[1;31mplease run the script again with root permission \033[0m" && exit 1

InstallSadowSocks() {
		apt update
		apt -y install shadowsocks-libev wget
}

InstallV2Plugin() {
    wget "https://github.com/shadowsocks/v2ray-plugin/releases/download/v1.3.2/v2ray-plugin-linux-amd64-v1.3.2.tar.gz"
    tar xzvf v2ray-plugin-linux-amd64-v1.3.2.tar.gz
    mv v2ray-plugin_linux_amd64 /usr/local/bin/v2ray-plugin
}

ShadowsocksConfig(){
    mkdir /etc/shadowsocks-libev
    cat >/etc/shadowsocks-libev/config.json << EOF
{
    "server":"0.0.0.0",
    "server_port":$PORT,
    "password":"$RANDOMPASS",
    "timeout":300,
    "method":"aes-256-gcm",
    "plugin":"v2ray-plugin",
    "plugin_opts":"server;loglevel=none"
}
EOF
}

StartShadowSocksService() {
    systemctl enable --now shadowsocks
    systemctl restart shadowsocks
}

print_ss_info(){
    clear
    echo "\033[1;32malmost done!\033[0m"
    echo "Your Server IP        :  same as the server public IP "
    echo "Your Server Port      :  ${PORT} "
    echo "Your Password         :  ${RANDOMPASS} "
    echo "Your Encryption Method:  aes-256-gcm "
    echo "Your Plugin           :  v2ray-plugin"
    echo "use the fllowing informations to configure your client"
}


install_all(){
    GetRandomPort
    GenerateRandomPassword
    InstallSadowSocks
    InstallV2Plugin
    ShadowsocksConfig
    StartShadowSocksService
    print_ss_info

}

remove_all(){
    systemctl disable shadowsocks
    systemctl stop shadowsocks
    rm -fr /etc/shadowsocks-libev
    apt autoremove --purge -y shadowsocks-libev
    rm -f /usr/local/bin/v2ray-plugin
    echo "\033[1;32mRemove success!\033[0m"
}

clear
echo "What do you want to do?"
echo "[1] Install"
echo "[2] Remove"
read -p "(Default option: Install):" option
option=${option:-1}
if [ $option -eq 2 ];then
    remove_all
else
    install_all
fi


