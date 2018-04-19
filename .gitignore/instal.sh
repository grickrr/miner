#!/bin/bash

IP=$(curl ipinfo.io/ip)

POOLS="\"pool_list\" :\n"
POOLS+="[\n"
POOLS+="{\"pool_address\" : \"stellite.miner.rocks:3333\",\n"
POOLS+="\"wallet_address\" : \"SEiStP7SMy1bvjkWc9dd1t2v1Et5q2DrmaqLqFTQQ9H7JKdZuATcPHUbUL3bRjxzxTDYitHsAPqF8EeCLw3bW8ARe8rYXDQ9kNN6AdLREXVYt\", \"rig_id\" : \"\",\n"
POOLS+="\"pool_password\" : \"x\",\n"
POOLS+="\"use_nicehash\" : true,\n"
POOLS+="\"use_tls\" : false,\n"
POOLS+="\"tls_fingerprint\" : \"\",\n"
POOLS+="\"pool_weight\" : 1 },\n"
POOLS+="],\n"
POOLS+="\"currency\" : \"stellite\",\n"

CONFIG="\"call_timeout\" : 10,\n"
CONFIG+="\"retry_time\" : 30,\n"
CONFIG+="\"giveup_limit\" : 0,\n"
CONFIG+="\"verbose_level\" : 3,\n"
CONFIG+="\"print_motd\" : true,\n"
CONFIG+="\"h_print_time\" : 60,\n"
CONFIG+="\"aes_override\" : null,\n"
CONFIG+="\"use_slow_memory\" : \"warn\",\n"
CONFIG+="\"tls_secure_algo\" : true,\n"
CONFIG+="\"daemon_mode\" : false,\n"
CONFIG+="\"flush_stdout\" : false,\n"
CONFIG+="\"output_file\" : \"\",\n"
CONFIG+="\"httpd_port\" : 16000,\n"
CONFIG+="\"http_login\" : \"\",\n"
CONFIG+="\"http_pass\" : \"\",\n"
CONFIG+="\"prefer_ipv4\" : true,\n"

echo "---INSTALL DEPENDENCING---"
sudo apt-get update && sudo apt-get -y install libmicrohttpd-dev libssl-dev cmake build-essential libhwloc-dev htop

echo "---DOWNLOAD,COMPILE, INSTALL AND CONFIGURE XMR-STAK"
git clone https://github.com/fireice-uk/xmr-stak.git
mkdir xmr-stak/build
cd xmr-stak/build
cmake -DCUDA_ENABLE=OFF -DOpenCL_ENABLE=OFF ..
make install
cd /bin

echo "---SETTING YOUR CONFIG---"
touch /root/xmr-stak/build/bin/pools.txt
printf "$POOLS" >> /root/xmr-stak/build/bin/pools.txt
chown root /root/xmr-stak/build/bin/pools.txt

touch /root/xmr-stak/build/bin/config.txt
printf "$CONFIG" >> /root/xmr-stak/build/bin/config.txt
chown root /root/xmr-stak/build/bin/config.txt

echo "--MAKE EXECUTABLE CUSTOM FILE---"
cd /root
echo "cd /root/xmr-stak/build/bin && ./xmr-stak" >> miner
chown root /root/miner
chmod +x miner

echo "---CHANGE HOSTNAME---"
rm -rf /etc/hostname
printf "$IP" >> /etc/hostname
chown root /etc/hostname
echo "127.0.0.1 $IP" >> /etc/hosts

echo "---ADD HUGEPAGES---"
sudo sysctl -w vm.nr_hugepages=128
echo "vm.nr_hugepages = 128" >> /etc/sysctl.conf

echo "---SET AUTO REBOOT---"
echo "0 *  * * *   root    reboot" >> /etc/crontab

echo "---SET EXECUTABLE RUNNING AT REBOOT---"
(crontab -l 2>/dev/null; echo "@reboot screen -dmS asoy /root/miner")| crontab -

echo "---DISABLE SCREEN STARTUP MESSAGE---"
echo 'startup_message off' >> ~/.screenrc

echo "---CLEAR ANY RUNNING SCREEN SESSION AT REBOOT---"

clear
echo "---CONRATULATION, YOUR MINER HAS BEED RUNNING SUCCESSFULLY---"
screen -dmS goyang /root/miner
