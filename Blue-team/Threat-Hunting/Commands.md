# Web Log Triage One-Liners

Quick `awk`/`grep` one-liners for triaging an Apache/Nginx **combined** access log (`$1` = client IP, `$6`/`$7` = request method/URI inside quotes, `$9` = HTTP status code). Useful as a first pass before pulling the same data into [KQL-Threat-Hunting.md](KQL-Threat-Hunting.md) for cross-host correlation.

## One-Liners

### Top IP + Method + Endpoint (Best General-Purpose View)

```bash copy
cat access.log | awk -F'"' '{print $1,$6}' | cut -d" " -f1,7- | sort | uniq -c | sort -nr
```

Shows who (IP), what (GET/POST/etc.), and where (URI) made the most requests — the best starting point for any triage.

### Most Active IPs by Method (Shorter Version)

```bash copy
cat access.log | awk '{print $1,$6}' | sort | uniq -c | sort -nr
```

### Unusual or Rare User-Agents (Often C2 or a Scanner)

```bash copy
cat access.log | awk -F'"' '{print $6}' | sort | uniq -c | sort -nr | head -20
```

Legitimate browsers produce a handful of common User-Agent strings; anything rare or malformed is worth investigating.

### IPs Generating the Most 4xx/5xx Errors (Brute-Force / Spray / Scanning)

```bash copy
cat access.log | awk '$9 ~ /^[45]/ {print $1,$9}' | sort | uniq -c | sort -nr
```

A high volume of 401/403/404 from a single IP often indicates credential brute-forcing, directory/endpoint scanning, or exploit attempts against non-existent paths.

### Unusual HTTP Methods (PUT, DELETE, OPTIONS, PATCH, CONNECT)

```bash copy
cat access.log | awk '{print $6}' | sort | uniq -c | grep -vE '"GET |"POST |"HEAD '
```

Most web apps only need GET/POST/HEAD — other methods appearing can indicate WebDAV abuse, exploitation attempts, or misconfigured proxies.

### POST Requests to Suspicious Script Paths

```bash copy
cat access.log | grep "POST" | grep -E "(php|asp|aspx|jsp|cfm|sh|cgi)" | awk '{print $1,$7,$9}'
```

Filters POST requests to executable script paths (e.g. `contact.php`, `upload.php`, `shell.php`) — common web shell or file-upload exploitation indicators.

### Top Endpoints Returning HTTP 200

```bash copy
cat access.log | awk '$9==200 {print $7}' | sort | uniq -c | sort -nr | head -20
```

Shows which endpoints were most often successfully retrieved or executed — useful for spotting an attacker repeatedly hitting a dropped web shell.

### Requests per Minute (Rate-Based Brute-Force / DoS Detection)

```bash copy
cat access.log | awk '{print substr($4,2,14)}' | sort | uniq -c | sort -nr | head -20
```

Buckets requests by minute (from the timestamp field) and shows the busiest minutes — a sudden spike can indicate brute-forcing, a scanner, or a denial-of-service attempt.
