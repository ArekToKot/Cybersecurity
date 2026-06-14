# Phishing Email Triage

Checklist for triaging a reported phishing email — what to extract from the message, how to safely expand links, and where to send any attachment for deeper analysis. Always handle attachments and links in an isolated environment; see [../Malware-Analysis/README.md](../Malware-Analysis/README.md) for safe analysis workflows.

## Tools

| Tool | Platform | Link |
|---|---|---|
| Google Admin Toolbox Messageheader | Web | [toolbox.googleapps.com](https://toolbox.googleapps.com/apps/messageheader/analyzeheader) |
| Message Header Analyzer | Web | [mha.azurewebsites.net](https://mha.azurewebsites.net/) |
| Analyze my mail header | Web | [mailheader.org](https://mailheader.org/) |
| urlscan.io | Web | [urlscan.io](https://urlscan.io/) |
| VirusTotal | Web | [virustotal.com](https://www.virustotal.com/) |
| PhishTool | Web | [phishtool.com](https://www.phishtool.com/) |

## Header Analysis

Extract from the email headers (use one of the header-analyzer tools above):

- Sender email address
- Sender IP address, and its reverse DNS lookup
- Email subject line
- Recipient email address(es) — check the CC/BCC fields too
- `Reply-To` address, if present and different from the sender
- Date/time the message was sent

**Red flags:**

- **Lookalike sender domains** — e.g. `micros0ft.com`, `paypal-support.com`, or a domain that's a single character off from the legitimate one.
- **Display-name / email mismatch** — the friendly name says "IT Support" but the address is an unrelated free-mail domain.
- **Mismatched `Reply-To`** — replies are routed to a different address than the sender, often the attacker's actual mailbox.
- **Urgency or threat language** — "your account will be suspended", "immediate action required" — designed to short-circuit careful review.

## Links & URLs

- Collect every URL in the message body.
- If a URL shortener was used (bit.ly, tinyurl, etc.), resolve it to the real destination **without visiting it directly** — use [urlscan.io](https://urlscan.io/) to submit and screenshot the URL safely.
- **Defang** URLs before sharing them in reports or chat to prevent accidental clicks, e.g. `hxxp://evil[.]com/login`.

## Attachments

- Record the attachment's filename.
- Compute its hash (MD5 or, preferably, SHA-256) and check it against [VirusTotal](https://www.virustotal.com/).
- If the hash is unknown or not flagged, proceed to:
  - [../Malware-Analysis/Static-Analysis.md](../Malware-Analysis/Static-Analysis.md) for file-type identification and signature checks
  - [../Malware-Analysis/Maldocs-Analysis.md](../Malware-Analysis/Maldocs-Analysis.md) if the attachment is an Office document, PDF, or script
  - [../Malware-Analysis/Dynamic-Analysis.md](../Malware-Analysis/Dynamic-Analysis.md) if execution in an isolated VM is needed to observe behavior
