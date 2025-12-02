/etc/hostname
ELASTIC-DISTRO-220600-S3

/etc/hosts
127.0.0.1 localhost
10.2.2.13 ELASTIC-DISTRO-220600-S3
127.0.1.1 ELASTIC-DISTRO-220600-S3
10.2.2.10 ELASTIC-DISTRO-220600


dodawanie repozytorium
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
apt update
echo "deb https://artifacts.elastic.co/packages/9.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-9.x.list
sudo apt-get update && sudo apt-get install heartbeat-elastic elasticsearch unzip

sudo /usr/share/elasticsearch/bin/elasticsearch-certutil cert --ca-cert /home/elastic/scripts/ca/ca.crt --ca-key /home/elastic/scripts/ca/ca.key --days 3650 --keysize 4096 --dns ELASTIC-DISTRO-220600 --name CN=ELASTIC-DISTRO-220600-S3 --out /home/elastic/scripts/ELASTIC-DISTRO-220600-S3.zip --pem
sudo chown elastic:elastic ELASTIC-DISTRO-220600-S3.zip
unzip ELASTIC-DISTRO-220600-S2.zip




sudo chown -R elasticsearch:elasticsearch /etc/elasticsearch


Rsyslog
nano /etc/rsyslog.conf
*.* @10.2.2.10:1514
