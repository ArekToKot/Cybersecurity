# do stron tylko
sudo nano /etc/hosts
# całe sieci np AD, dns resolver
sudo nano /etc/resolv.conf
# Shorten name resolution timeouts to 1 second
options timeout:1
# Only attempt to resolve a hostname 2 times
options attempts:2
# restart

sudo systemctl restart networking.service
# nslookup thmdc.za.tryhackme.com

ssh za.tryhackme.com\\kenneth.davies@thmjmp1.za.tryhackme.com
ssh diane.wood@thmjmp1.za.tryhackme.com
# pierwszy wiersz poleceń uruchomić jako administrator
runas.exe /netonly /user:<domain>\<username> cmd.exe
runas.exe /netonly /user:za.tryhackme.com\kenneth.davies mmc.exe

# Windows LTSC QPM6N-7J2WJ-P88HH-P3YRH-YY74H

# konfiguracja wewnętrznego serwera DNS
$dnsip = "10.200.58.101"
$index = Get-NetAdapter -Name 'Ethernet' | Select-Object -ExpandProperty 'ifIndex'
Set-DnsClientServerAddress -InterfaceIndex $index -ServerAddresses $dnsip
# sprawdzić nslookup za.tryhackme.com
# dir \\za.tryhackme.com\SYSVOL\
# dir \\ip\SYSVOL\ < uwierzytelninanie NTLM


