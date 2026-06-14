# BloodHound-Legacy Installation
Commands for installing and configuring BloodHound-Legacy (version 4.3, deprecated) on Kali Linux

## Prerequisites
```bash copy
sudo su
```
- Switches to the root user to execute all subsequent commands.
- No switches.

## Neo4j

### Install Neo4j
```bash copy
apt update
```
- Updates the package list to ensure the latest dependencies.
- No switches.

```bash copy
apt install neo4j
```
- Installs the Neo4j database, required for BloodHound-Legacy.
- No switches.

### Manage Neo4j Service
```bash copy
systemctl enable neo4j
systemctl start neo4j
systemctl status neo4j
```
- Configures, starts, and checks the status of the Neo4j service.
- `enable`: Enables the service to start on boot.
- `start`: Starts the service.
- `status`: Shows the service status.

### Configure Neo4j
```bash copy
nano /etc/neo4j/neo4j.conf
```
- Opens the `neo4j.conf` file for editing.
- No switches.
- **Changes**: Set `dbms.default_listen_address=0.0.0.0` for external access and ensure `dbms.security.auth_enabled=true`.

### Set Neo4j Password
```bash copy
cypher-shell -u neo4j -p neo4j
```
- Connects to Neo4j to set a new password for the `neo4j` user.
- `-u neo4j`: Specifies the default user.
- `-p neo4j`: Specifies the default password (prompts to change it).

```cypher copy
ALTER USER neo4j SET PASSWORD 'your_secure_password'
```
- Changes the password for the `neo4j` user.
- No switches.

### Restart Neo4j Service
```bash copy
systemctl restart neo4j
```
- Restarts the Neo4j service to apply configuration changes.
- `restart`: Restarts the service.

## BloodHound-Legacy

### Install BloodHound-Legacy
```bash copy
apt install bloodhound
```
- Installs BloodHound-Legacy from the Kali Linux repository.
- No switches.

### Download BloodHound GUI
```bash copy
wget https://github.com/SpecterOps/BloodHound-Legacy/releases/download/v4.3.1/BloodHound-linux-x64.zip
```
- Downloads the BloodHound-Legacy GUI for Linux.
- No switches.

### Unzip BloodHound GUI
```bash copy
unzip BloodHound-linux-x64.zip -d /usr/local/bin/bloodhound
```
- Extracts the BloodHound-Legacy GUI to a specified directory.
- `-d /usr/local/bin/bloodhound`: Specifies the destination directory.

### Run BloodHound GUI
```bash copy
/usr/local/bin/bloodhound/BloodHound
```
- Launches the BloodHound-Legacy GUI.
- No switches.
- **Note**: Authenticate with the Neo4j credentials (`neo4j:your_secure_password`).

## SharpHound (Data Collector)
### Download SharpHound
```bash copy
wget https://github.com/SpecterOps/BloodHound-Legacy/releases/download/v4.3.1/SharpHound.exe
```
- Downloads the SharpHound data collector for Windows.
- No switches.

### Run SharpHound
- **Note**: Transfer `SharpHound.exe` to a domain-joined Windows system and run it to collect Active Directory data, then import the output into BloodHound-Legacy.