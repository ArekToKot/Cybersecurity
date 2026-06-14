# BloodHound Community Edition (CE) Installation
Commands for installing and configuring BloodHound Community Edition on Kali Linux

## Prerequisites
```bash copy
sudo su
```
- Switches to the root user to execute all subsequent commands.
- No switches.

## Docker

### Install Docker
```bash copy
apt update
```
- Updates the package list to ensure the latest dependencies.
- No switches.

```bash copy
apt install docker.io
```
- Installs Docker, required for BloodHound CE.
- No switches.

### Manage Docker Service
```bash copy
systemctl enable docker
systemctl start docker
systemctl status docker
```
- Configures, starts, and checks the status of the Docker service.
- `enable`: Enables the service to start on boot.
- `start`: Starts the service.
- `status`: Shows the service status.

## BloodHound CE

### Install BloodHound CLI
```bash copy
curl -L https://github.com/SpecterOps/BloodHound/releases/download/v5.16.1/bloodhound-cli_5.16.1_linux_x86_64.tar.gz -o bloodhound-cli.tar.gz
```
- Downloads the BloodHound CE CLI tool.
- `-L`: Follows redirects.
- `-o bloodhound-cli.tar.gz`: Specifies the output file.

```bash copy
tar -xzf bloodhound-cli.tar.gz -C /usr/local/bin/
```
- Extracts the BloodHound CLI to a specified directory.
- `-xzf`: Extracts the tar.gz file.
- `-C /usr/local/bin/`: Specifies the destination directory.

### Run BloodHound CLI Install
```bash copy
bloodhound-cli install
```
- Installs and configures BloodHound CE using Docker containers.
- No switches.

### Access BloodHound CE
- **URL**: Navigate to `http://localhost:8080` in a web browser.
- **Credentials**: Use the default credentials provided during installation or set a new password via the CLI.

### Configure BloodHound CE (Optional)
```bash copy
nano /etc/bloodhound/bloodhound.config.yaml
```
- Opens the BloodHound CE configuration file for editing.
- No switches.
- **Changes**: Adjust settings like `host: 0.0.0.0` or `port: 8080` for external access.

### Restart BloodHound CE
```bash copy
docker-compose -f /etc/bloodhound/docker-compose.yml restart
```
- Restarts the BloodHound CE Docker containers to apply configuration changes.
- `-f /etc/bloodhound/docker-compose.yml`: Specifies the Docker Compose file.

## SharpHound (Data Collector)
### Download SharpHound
```bash copy
wget https://github.com/SpecterOps/BloodHound/releases/download/v5.16.1/SharpHound-v2.5.0.zip
```
- Downloads the SharpHound data collector for Windows.
- No switches.

### Run SharpHound
- **Note**: Transfer `SharpHound.exe` to a domain-joined Windows system and run it to collect Active Directory data, then import the output into BloodHound CE.