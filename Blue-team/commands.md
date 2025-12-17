
# Useful Commands.md – Web Log Triage One-Liners


### 1. Top IP + metoda + endpoint (najlepszy ogólny widok)
```bash
cat access.log | awk -F'"' '{print $1,$6}' | cut -d" " -f1,7- | sort | uniq -c | sort -nr
```
→ Pokazuje kto (IP), co (GET/POST/etc.) i gdzie (URI) walił najczęściej.

### 2. Najaktywniejsze IP + metoda (krótsza wersja)
```bash
cat access.log | awk '{print $1,$6}' | sort | uniq -c | sort -nr
```

### 3. Dziwne / rzadkie User-Agenty (prawie zawsze C2 albo skaner)
```bash
cat access.log | awk -F'"' '{print $6}' | sort | uniq -c | sort -nr | head -20
```

### 4. IP, które dostały najwięcej błędów 4xx/5xx (brute-force / spray / skanowanie)
```bash
cat access.log | awk '$9 ~ /^[45]/ {print $1,$9}' | sort | uniq -c | sort -nr
```

### 5. Nietypowe metody HTTP (POST, PUT, DELETE, HEAD, OPTIONS, PATCH, CONNECT)
```bash
cat access.log | awk '{print $6}' | sort | uniq -c | grep -vE '"GET |"POST |"HEAD '
```

### 6. Wszystkie POST-y na podejrzane pliki (contact.php, upload.php, shell.php itd.)
```bash
cat access.log | grep "POST" | grep -E "(php|asp|aspx|jsp|cfm|sh|cgi)" | awk '{print $1,$7,$9}'
```

### 7. Top endpointy zwracające 200 (co najczęściej udało się pobrać/wykonać)
```bash
cat access.log | awk '$9==200 {print $7}' | sort | uniq -c | sort -nr | head -20
```
