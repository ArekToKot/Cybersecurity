#! /bin/bash

# ============================================================
# WSTEPNA KONFIGURACJA SYSTEMU

DEBIAN_FRONTEND=noninteractive

AGENT_VERSION=9.1.2
TIME_ZONE=Europe/Warsaw
WWW_HOST=http://10.30.51.61:8080/configs/
ELASTIC_IP=10.2.2.10
HOSTNAME=SERWER-04

#strefa czasowa - ustawienie
sudo timedatectl set-timezone ${TIME_ZONE}

# hostname - ustawienie
hostnamectl set-hostname ${HOSTNAME}

# dodanie hosta (adres serwera elastic)
echo "" >> /etc/hosts
echo "${ELASTIC_IP}    ELASTIC-DISTRO-220600" >> /etc/hosts


# ============================================================
# DODANIE REPOZYTORIUM ELASTIC

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https -y
echo "deb https://artifacts.elastic.co/packages/9.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-9.x.list

sudo apt-get update

sleep 2
sudo killall apt-get

#sudo apt-get upgrade -y

#sleep 2
#sudo killall apt-get

# ============================================================
# INSTALACJA AGENTOW


sudo apt-get install metricbeat=${AGENT_VERSION} -y

wget ${WWW_HOST}/ca.crt
sudo mkdir /etc/elasticsearch/certs -p
sudo mv ca.crt /etc/elasticsearch/certs/

rm metricbeat.yml 2> /dev/null
wget ${WWW_HOST}/metricbeat.yml
sudo mv metricbeat.yml /etc/metricbeat/

sudo chown root:root /etc/metricbeat/metricbeat.yml
sudo chmod go-w /etc/metricbeat/metricbeat.yml

sudo systemctl start metricbeat
sudo systemctl enable metricbeat


sleep 2
sudo killall apt-get


sudo apt-get install auditbeat=${AGENT_VERSION} -y

rm auditbeat.yml 2> /dev/null
wget ${WWW_HOST}/auditbeat.yml
sudo mv auditbeat.yml /etc/auditbeat/

sudo chown root:root /etc/auditbeat/auditbeat.yml
sudo chmod go-w /etc/auditbeat/auditbeat.yml

sudo systemctl start auditbeat
sudo systemctl enable auditbeat


sleep 2
sudo killall apt-get


sudo apt-get install packetbeat=${AGENT_VERSION} -y

rm packetbeat.yml 2> /dev/null
wget ${WWW_HOST}/packetbeat.yml
sudo mv packetbeat.yml /etc/packetbeat/

sudo chown root:root /etc/packetbeat/packetbeat.yml
sudo chmod go-w /etc/packetbeat/packetbeat.yml

sudo systemctl start packetbeat
sudo systemctl enable packetbeat


sleep 2
sudo killall apt-get


sudo apt-get install filebeat=${AGENT_VERSION} -y

rm filebeat.yml 2> /dev/null
wget ${WWW_HOST}/filebeat.yml
sudo mv filebeat.yml /etc/filebeat/

sudo chown root:root /etc/filebeat/filebeat.yml
sudo chmod go-w /etc/filebeat/filebeat.yml

# Aktywacja modulow - moze byc wyamagana dodatkowa konfiguracja plikow YML
#sudo filebeat modules enable system
#sudo filebeat modules enable auditd

sudo systemctl start filebeat
sudo systemctl enable filebeat
