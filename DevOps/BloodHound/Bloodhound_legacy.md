# BloodHound-Legacy Installation
Step-by-step commands for installing and configuring BloodHound-Legacy (version 4.3, **deprecated**) on Kali Linux. Follow these steps **in order, top to bottom**.

> **Note**: BloodHound-Legacy is no longer actively developed. Unless you have a specific reason to use it (e.g. an old workflow that depends on it), use **BloodHound CE** instead - see `Bloodhound_ce.md`. The steps below are kept for reference.

## Before You Start
- A Kali Linux machine with internet access and root access (Step 1 takes care of root).
- **Known compatibility issue**: BloodHound-Legacy 4.3 works best with **Neo4j 4.4.x**. Current Kali's `apt install neo4j` can pull **Neo4j 5.x**, which is known to cause very slow data imports and "no procedure with the name `apoc.*`" errors with BloodHound-Legacy (this is tracked as Kali bug #8143). Step 2 shows you how to check which version you got - if you hit these symptoms later, see the Troubleshooting section.

## Step 1: Become Root
```bash copy
sudo su
```
- Switches to the root user so all subsequent commands (apt, systemctl, file edits) work without typing `sudo` every time.
- No switches.

## Step 2: Install Neo4j

### 2.1 Update the package list
```bash copy
apt update
```
- Refreshes the list of available packages so you install the latest versions.
- No switches.

### 2.2 Install Neo4j
```bash copy
apt install neo4j -y
```
- Installs the Neo4j graph database, which BloodHound-Legacy uses to store and query collected Active Directory data.
- `-y`: Automatically answers "yes" to the install prompt.

### 2.3 Check which Neo4j version you got
```bash copy
dpkg -l | grep neo4j
```
- Lists the installed Neo4j package and its version number.
- If the version starts with `5.`, keep the compatibility note from "Before You Start" in mind - jump to the Troubleshooting section if you later see slow imports or `apoc.*` errors.

## Step 3: Enable and Start Neo4j
```bash copy
systemctl enable neo4j
systemctl start neo4j
systemctl status neo4j
```
- `enable`: Makes Neo4j start automatically every time the machine boots.
- `start`: Starts the Neo4j service right now.
- `status`: Shows whether Neo4j is running. Look for `active (running)` in green. Press `q` to exit the status view.

## Step 4: Configure Neo4j
```bash copy
nano /etc/neo4j/neo4j.conf
```
- Opens the Neo4j configuration file in the `nano` text editor.
- **What to change**:
  - Find the line for `dbms.default_listen_address` and make sure it's set to `dbms.default_listen_address=0.0.0.0` (uncomment it by removing a leading `#` if needed). This allows BloodHound-Legacy and SharpHound imports to connect, including from other machines if needed.
  - Find `dbms.security.auth_enabled` and make sure it's set to `true` (this is the default - it requires a username/password to connect, which you'll set in Step 5).
- **How to save in nano**: press `Ctrl+O` (write out), then `Enter` to confirm the filename, then `Ctrl+X` to exit.

## Step 5: Set the Neo4j Password
```bash copy
cypher-shell -u neo4j -p neo4j
```
- Connects to Neo4j using the default username (`neo4j`) and default password (`neo4j`).
- `-u neo4j`: Username to connect as.
- `-p neo4j`: Default password - Neo4j will force you to change it immediately.
- This drops you into an interactive Cypher prompt (it looks like `neo4j@neo4j>`).

At the prompt, run:
```cypher copy
ALTER USER neo4j SET PASSWORD 'your_secure_password';
```
- Changes the password for the `neo4j` user to whatever you put between the quotes.
- **Replace `your_secure_password` with your own password, and remember it** - you'll need it for both the BloodHound-Legacy GUI login (Step 9) and when importing SharpHound data.
- Type `:exit` (or press `Ctrl+D`) to leave the Cypher prompt afterwards.

## Step 6: Restart Neo4j
```bash copy
systemctl restart neo4j
```
- Restarts the Neo4j service so the configuration changes from Step 4 take effect.
- `restart`: Stops and starts the service in one command.

## Step 7: Install BloodHound-Legacy
```bash copy
apt install bloodhound -y
```
- Installs BloodHound-Legacy from the Kali Linux repository.
- `-y`: Automatically answers "yes" to the install prompt.

## Step 8: Download the BloodHound GUI
```bash copy
wget https://github.com/SpecterOps/BloodHound-Legacy/releases/download/v4.3.1/BloodHound-linux-x64.zip
```
- Downloads the BloodHound-Legacy desktop GUI for Linux.
- No switches.

```bash copy
unzip BloodHound-linux-x64.zip -d /usr/local/bin/bloodhound
```
- Extracts the GUI into `/usr/local/bin/bloodhound`.
- `-d /usr/local/bin/bloodhound`: Specifies the destination directory (created automatically if it doesn't exist).

## Step 9: Run the BloodHound GUI
```bash copy
/usr/local/bin/bloodhound/BloodHound
```
- Launches the BloodHound-Legacy GUI.
- On first launch, you'll see a login screen asking for Neo4j connection details:
  - **Database URL**: `bolt://localhost:7687` (the default Neo4j bolt port)
  - **Username**: `neo4j`
  - **Password**: the password you set in Step 5
- Click **Login** to open the main BloodHound interface.
- **Note**: This GUI needs a graphical desktop environment (or X11 forwarding) - it won't run on a purely headless server without one.

## SharpHound (Data Collector)

### Download SharpHound
```bash copy
wget https://github.com/SpecterOps/BloodHound-Legacy/raw/master/Collectors/SharpHound.exe
```
- Downloads the SharpHound (v1.1.1) data collector for Windows, the version bundled with BloodHound-Legacy.
- No switches.

### Run SharpHound and Import the Results
1. Transfer `SharpHound.exe` to a **domain-joined Windows machine**.
2. Run it from a command prompt (e.g. `SharpHound.exe -c All` to collect everything).
3. SharpHound produces a `.zip` file containing the collected data.
4. In the BloodHound-Legacy GUI (Step 9), drag and drop that `.zip` file onto the interface (or use the upload/import button) to ingest the data into Neo4j.

> **Tip**: If you're starting fresh, consider using **BloodHound CE** instead (see `Bloodhound_ce.md`) - it bundles a compatible database in Docker, so you avoid the Neo4j version issues below entirely.

## Troubleshooting
- **Slow imports / errors like "There is no procedure with the name `apoc.*`"**: This is the Neo4j 5.x vs BloodHound-Legacy 4.3 incompatibility mentioned at the top (Kali bug #8143). The practical fix is to switch to **BloodHound CE**, which ships its own compatible database and doesn't have this problem.
- **BloodHound GUI won't connect / "Unable to connect to Neo4j"**: Double-check the bolt port (`7687`) is correct, Neo4j is running (`systemctl status neo4j`), and the username/password match what you set in Step 5.
- **GUI doesn't open / no display**: The BloodHound-Legacy GUI is a desktop application - on a headless Kali install you'll need a desktop environment or X11 forwarding (`ssh -X`) to run it.
