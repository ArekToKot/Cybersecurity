
# Zui.md – Falcon Query Language Cheat-Sheet 

### Top Alert Signatures (ile razy co wystrzeliło)

```zui
event_type=="alert" 
| count() by alert.signature
```
- Pokazuje ranking wszystkich alertów według ich nazwy (signature).
- Idealne na początek triage’u – od razu widać co najgłośniejsze.

### Top 10 najczęstszych alertów (z sortowaniem)

```zui
event_type=="alert" 
| count() by alert.signature 
| sort by _count desc 
| limit 10
```
- To samo co wyżej, ale już posortowane malejąco i tylko top 10.

### Alerty z ostatniej godziny

```zui
event_type=="alert" 
| filter _time > now() - 1h 
| count() by alert.signature 
| sort by _count desc
```

### Tylko krytyczne/high severity

```zui
event_type=="alert" 
| filter alert.severity in ["Critical", "High"] 
| count() by alert.signature 
| sort by _count desc
```

### Alerty konkretnego hosta (np. DESKTOP-KOAA32A)

```zui
event_type=="alert" 
| filter computer_name=="DESKTOP-KOAA32A" 
| count() by alert.signature 
| sort by _count desc
```

### Process Execution + Alert w jednym widoku (mniam!)

```zui
(event_type=="alert" OR event_type=="process") 
| filter process.name in ["powershell.exe", "ps.exe", "psexec.exe", "mimikatz.exe"] 
| count() by process.name, alert.signature
```