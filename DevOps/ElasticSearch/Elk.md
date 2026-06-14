# ELK Installation
Commands for installing and configuring the ELK stack (Elasticsearch, Logstash, Kibana) on the central server, plus the TLS cert and syslog setup that the agent-deployment script [Elk.sh](Elk.sh) depends on.

## Prerequisites
```bash copy
sudo su
```
- Switches to the root user to execute all subsequent commands.

### Configure Hostname and Hosts File
```bash copy
hostnamectl set-hostname <node-hostname>
echo "<node-ip>    <node-hostname>" >> /etc/hosts
echo "<elastic-ip> <elastic-cluster-name>" >> /etc/hosts
```
- Sets this node's own hostname and makes sure it (and the Elasticsearch cluster name used by the TLS cert below) resolve locally.
- `<elastic-cluster-name>` must match the `--name`/`--dns` values used when generating the certificate, and the hosts entry that `Elk.sh` adds on agent hosts.

## Elasticsearch

### Install Elasticsearch
```bash copy
dpkg -i elasticsearch.deb
```
- Installs the Elasticsearch package from a .deb file.
- `-i`: Installs the specified package.

#### Alternative: Install via APT Repository
```bash copy
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https -y
echo "deb https://artifacts.elastic.co/packages/9.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-9.x.list
sudo apt-get update
sudo apt-get install elasticsearch -y
```
- Adds the official Elastic apt repository and installs from it instead of a `.deb` file — useful for picking up updates with `apt upgrade` later. This is the same repository `Elk.sh` adds on agent hosts.

### Save Elastic Superuser Password
- **Note**: After installation, save the generated password for the `elastic` superuser (e.g., `<GENERATED_PASSWORD>`).

### Reset Elastic Password (Optional)
```bash copy
/usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
```
- Resets the password for the `elastic` superuser.
- `-u elastic`: Specifies the user `elastic`.

### Generate a TLS Certificate for Agents
```bash copy
/usr/share/elasticsearch/bin/elasticsearch-certutil cert \
  --ca-cert /home/elastic/scripts/ca/ca.crt \
  --ca-key /home/elastic/scripts/ca/ca.key \
  --days 3650 --keysize 4096 \
  --dns <elastic-cluster-name> --name CN=<node-hostname> \
  --out /home/elastic/scripts/<node-hostname>.zip --pem

unzip /home/elastic/scripts/<node-hostname>.zip -d /etc/elasticsearch/certs/
chown -R elasticsearch:elasticsearch /etc/elasticsearch
```
- Issues a CA-signed certificate/key pair for this node, valid for 10 years, and unpacks it into `/etc/elasticsearch/certs/`.
- The `ca.crt` from this CA is what `Elk.sh` downloads onto agent hosts so Beats can verify the connection to Elasticsearch over TLS — host it at `${WWW_HOST}/ca.crt`.

### Generate Kibana Enrollment Token
```bash copy
/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana
```
- Generates an enrollment token for Kibana to connect to Elasticsearch.
- `-s kibana`: Specifies the scope for Kibana.
- Save this token — it's needed during Kibana setup below.

### Manage Elasticsearch Service
```bash copy
systemctl enable elasticsearch.service
systemctl start elasticsearch.service
systemctl status elasticsearch.service
```
- Configures, starts, and checks the status of the Elasticsearch service.
- `enable`: Enables the service to start on boot.
- `start`: Starts the service.
- `status`: Shows the service status.

### Configure Elasticsearch
```bash copy
cd /etc/elasticsearch/
```
- Changes to the Elasticsearch configuration directory.

```bash copy
nano elasticsearch.yml
```
- Opens the `elasticsearch.yml` file for editing.
- **Changes**: Set `network.host: 127.0.0.1` and `http.port: 9200` for local access.

### Restart Elasticsearch Service
```bash copy
systemctl restart elasticsearch.service
```
- Restarts the Elasticsearch service to apply configuration changes.
- `restart`: Restarts the service.

## Logstash

### Install Logstash
```bash copy
dpkg -i logstash.deb
```
- Installs the Logstash package from a .deb file.
- `-i`: Installs the specified package.

### Manage Logstash Service
```bash copy
systemctl daemon-reload
systemctl enable logstash.service
systemctl start logstash.service
systemctl status logstash.service
```
- Reloads systemd, configures, starts, and checks the status of the Logstash service.
- `daemon-reload`: Reloads systemd configuration.
- `enable`: Enables the service to start on boot.
- `start`: Starts the service.
- `status`: Shows the service status.

### Configure Logstash
```bash copy
nano /etc/logstash/logstash.yml
```
- Opens the `logstash.yml` file for editing.
- **Changes**: Set `config.reload.automatic: true` and `config.reload.interval: 3s` for automatic configuration reload.

### Restart Logstash Service
```bash copy
systemctl restart logstash.service
```
- Restarts the Logstash service to apply configuration changes.
- `restart`: Restarts the service.

### Forward Syslog to Logstash
On a client host, add to `/etc/rsyslog.conf`:
```bash copy
*.* @<logstash-host>:1514
```
- Forwards all local syslog messages to Logstash on UDP port 1514 (use `@@<logstash-host>:1514` for TCP).
- Logstash needs a matching input in its `.conf` file to receive these, e.g. `input { syslog { port => 1514 } }`.

## Kibana

### Install Kibana
```bash copy
dpkg -i kibana.deb
```
- Installs the Kibana package from a .deb file.
- `-i`: Installs the specified package.

### Manage Kibana Service
```bash copy
systemctl daemon-reload
systemctl enable kibana.service
systemctl start kibana.service
```
- Reloads systemd, configures, and starts the Kibana service.
- `daemon-reload`: Reloads systemd configuration.
- `enable`: Enables the service to start on boot.
- `start`: Starts the service.

### Configure Kibana
```bash copy
nano /etc/kibana/kibana.yml
```
- Opens the `kibana.yml` file for editing.
- **Changes**: Set `server.port: 5601` and `server.host: "0.0.0.0"` for external access.

### Restart Kibana Service
```bash copy
systemctl restart kibana.service
```
- Restarts the Kibana service to apply configuration changes.
- `restart`: Restarts the service.

### Access Kibana
- **URL**: Navigate to `http://0.0.0.0:5601` in a web browser.
- Paste in the enrollment token generated earlier (see [Generate Kibana Enrollment Token](#generate-kibana-enrollment-token)) to connect Kibana to Elasticsearch.

### Generate Kibana Verification Code
```bash copy
/usr/share/kibana/bin/kibana-verification-code
```
- Generates a verification code for Kibana login.

### Login to Kibana
- **Credentials**: Use `elastic:<GENERATED_PASSWORD>` (replace with the actual password generated during installation).

## Logstash Configuration
Configuration for processing log files in Logstash
### /etc/logstash/conf.d/(any_name).conf
```conf copy
input {
    file {
        path => "/home/Desktop/web_attacks.csv"
        start_position => "beginning"
        sincedb_path => "/dev/null"
    }
}
filter {
    csv {
        separator => ","
        columns => ["timestamp", "ip_address", "request", "referrer", "user_agent", "attack_type"]
    }
    if [attack_type] =~ /SQL Injection|Brute Force/ {
    # Perform any necessary actions for the filtered logs
}
}
output {
    file {
        path => "/home/Desktop/updated-web-attacks.csv"
    }
}
```
- **input**: Configures Logstash to read data from a CSV file.
- **filter**: Parses the CSV file into structured fields.
- **note**: Filters logs for specific attack types (SQL Injection or Brute Force).
- `[attack_type] =~ /SQL Injection|Brute Force/`: Matches logs where `attack_type` contains "SQL Injection" or "Brute Force".

- **output**: Writes processed log data to an output CSV file.

## Next: Deploy Agents

Once Elasticsearch, Logstash, and Kibana are up and the TLS certificate has been generated, use [Elk.sh](Elk.sh) to deploy Metricbeat, Auditbeat, Packetbeat, and Filebeat to monitored hosts so they ship data into this stack.