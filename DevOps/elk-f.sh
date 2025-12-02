#! /bin/bash

# ============================================================
# WSTEPNA KONFIGURACJA SYSTEMU

AGENT_VERSION=9.1.2
TIME_ZONE=Europe/Warsaw
WWW_HOST=http://10.30.51.61:8080/configs
ELASTIC_IP=10.2.2.10
HOSTNAME=Fedora-02

#strefa czasowa - ustawienie
sudo timedatectl set-timezone ${TIME_ZONE}

# hostname - ustawienie
hostnamectl set-hostname ${HOSTNAME}
echo "127.0.0.1         ${HOSTNAME}" | tee -a /etc/hosts
echo "127.0.1.1         ${HOSTNAME}" | tee -a /etc/hosts


# dodanie hosta (adres serwera elastic)
echo "" | tee -a /etc/hosts
echo "${ELASTIC_IP}    ELASTIC-DISTRO-220600" | tee -a /etc/hosts

# ============================================================
# DODANIE REPOZYTORIUM ELASTIC

echo "[elastic-9.x]
name=Elastic repository for 9.x packages
baseurl=https://artifacts.elastic.co/packages/9.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md" | tee /etc/yum.repos.d/elastic.repo

# ============================================================
# INSTALACJA AGENTOW


sudo yum install metricbeat-${AGENT_VERSION} -y

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

sudo yum install auditbeat-${AGENT_VERSION} -y

rm auditbeat.yml 2> /dev/null
wget ${WWW_HOST}/auditbeat.yml
sudo mv auditbeat.yml /etc/auditbeat/

sudo chown root:root /etc/auditbeat/auditbeat.yml
sudo chmod go-w /etc/auditbeat/auditbeat.yml

sudo systemctl start auditbeat
sudo systemctl enable auditbeat


sudo yum install packetbeat-${AGENT_VERSION} -y

rm packetbeat.yml 2> /dev/null
wget ${WWW_HOST}/packetbeat.yml
sudo mv packetbeat.yml /etc/packetbeat/

sudo chown root:root /etc/packetbeat/packetbeat.yml
sudo chmod go-w /etc/packetbeat/packetbeat.yml

sudo systemctl start packetbeat
sudo systemctl enable packetbeat


sudo yum install filebeat-${AGENT_VERSION} -y

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
