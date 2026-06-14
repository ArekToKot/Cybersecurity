# BloodHound Community Edition (CE) Installation
Step-by-step commands for installing and configuring BloodHound Community Edition on Kali Linux (or any Debian/Ubuntu-based distro). Follow these steps **in order, top to bottom** - each step explains what it does, why it's needed, and what to watch out for.

## Before You Start
- A Debian/Ubuntu/Kali Linux machine with internet access.
- Root access (Step 1 takes care of this).
- **At least 8 GB RAM and 10 GB free disk space.** BloodHound CE runs a graph analysis job during its first startup that needs this memory - with less than 8 GB the containers can crash and restart in a loop.
- A web browser that can reach this machine (locally, or via SSH tunnel/port-forward if it's a remote VM).

## Step 1: Become Root
```bash copy
sudo su
```
- Switches to the root user so all subsequent commands (Docker, apt, file edits) work without typing `sudo` every time.
- No switches.

## Step 2: Install Docker

### 2.1 Update the package list
```bash copy
apt update
```
- Refreshes the list of available packages so you install the latest versions.
- No switches.

### 2.2 Install Docker
```bash copy
apt install docker.io -y
```
- Installs Docker, which BloodHound CE runs entirely inside (via Docker Compose).
- `-y`: Automatically answers "yes" to the install prompt, so the command doesn't stop and wait for you.

### 2.3 Enable and start Docker
```bash copy
systemctl enable docker
systemctl start docker
systemctl status docker
```
- `enable`: Makes Docker start automatically every time the machine boots.
- `start`: Starts the Docker service right now.
- `status`: Shows whether Docker is running. Look for `active (running)` in green. Press `q` to exit the status view.

### 2.4 Verify Docker works
```bash copy
docker --version
```
- Prints the installed Docker version. If this errors out, Docker isn't installed/running correctly - go back to step 2.2/2.3 before continuing.
- No switches.

## Step 3: Create a Working Directory
```bash copy
mkdir -p /opt/bloodhound
cd /opt/bloodhound
```
- Creates a dedicated folder for BloodHound CE and moves into it.
- `-p`: Creates parent directories if they don't exist (and doesn't error if the folder already exists).
- **Why this matters**: in the next steps, `bloodhound-cli` will create its `docker-compose.yml` and configuration files **in the folder you run it from**. Doing everything from `/opt/bloodhound` means you always know where to find these files later (for restarting, upgrading, or troubleshooting).

## Step 4: Download and Install the BloodHound CLI
```bash copy
wget https://github.com/SpecterOps/bloodhound-cli/releases/latest/download/bloodhound-cli-linux-amd64.tar.gz
```
- Downloads the latest BloodHound CLI (`bloodhound-cli`), the tool that installs and manages BloodHound CE for you.
- `latest`: Always grabs the newest release, so you don't need to keep updating a version number in this command.

```bash copy
tar -xvzf bloodhound-cli-linux-amd64.tar.gz
```
- Extracts the `bloodhound-cli` binary into the current folder (`/opt/bloodhound`).
- `-x`: Extract. `-v`: Verbose (show extracted files). `-z`: Decompress gzip. `-f`: Read from the named file.

```bash copy
chmod +x bloodhound-cli
```
- Marks the `bloodhound-cli` file as executable so you're allowed to run it.
- `+x`: Adds execute permission.

**Optional - make it runnable from anywhere:**
```bash copy
mv bloodhound-cli /usr/local/bin/
```
- Moves the binary to a folder that's already on your `PATH`, so you can type `bloodhound-cli` instead of `./bloodhound-cli` from any directory.
- If you skip this, just remember to type `./bloodhound-cli` (with `./`) while inside `/opt/bloodhound`. The rest of this guide assumes you did **not** move it, so it uses `./bloodhound-cli`.

## Step 5: Install BloodHound CE
```bash copy
./bloodhound-cli install
```
- Downloads the Docker images for BloodHound CE (database, graph database, API, web UI), creates a `docker-compose.yml` file in the current folder, and starts all the containers.
- This can take several minutes depending on your internet connection - let it finish.
- No switches.

> ## ⚠️ IMPORTANT - SAVE THE PASSWORD SHOWN AT THE END
> When the install finishes, the terminal prints something like:
> ```
> [+] BloodHound is ready to go!
> [+] You can log in as admin with this password: ************
> ```
> **Copy that password somewhere safe right now.** It is shown **only once**, and it's the password for the built-in `admin` account. If you lose it before logging in for the first time, see the "Day-2 Operations" section below for how to reset it.

## Step 6: First Login
1. Open a web browser and go to:
   ```
   http://localhost:8080/ui/login
   ```
   (If this is a remote VM and you've already done Step 7 below, use `http://<server-ip>:8080/ui/login` instead.)
2. Log in with:
   - **Username**: `admin`
   - **Password**: the one-time password you saved in Step 5.
3. You will be **forced to set a new password** immediately - choose a strong one and save it in your password manager.
4. You may also be prompted to set up multi-factor authentication (MFA) - follow the on-screen instructions if so.

## Step 7 (Optional): Allow Access From Other Machines
By default, BloodHound CE only listens on `127.0.0.1` (localhost), so it's only reachable from the machine it's running on. To reach it from other devices on your network:

```bash copy
nano /opt/bloodhound/docker-compose.yml
```
- Opens the compose file created in Step 5 for editing.
- Find the port mapping for the BloodHound web/UI service - it will look like `"127.0.0.1:8080:8080"`.
- Change `127.0.0.1` to `0.0.0.0` so it becomes `"0.0.0.0:8080:8080"`.
- Save and exit: press `Ctrl+O`, then `Enter`, then `Ctrl+X`.

```bash copy
docker compose restart
```
- Restarts the containers so the new port binding takes effect.
- Run this from `/opt/bloodhound` (where `docker-compose.yml` lives).

> **⚠️ Security note**: This makes the BloodHound UI reachable by anything that can reach this machine's IP on port 8080. Only do this on a trusted network, and consider firewall rules if needed.

## Step 8: Day-2 Operations Cheat Sheet
Run these from `/opt/bloodhound` (or with `./bloodhound-cli` replaced by the full path if you didn't move it to `/usr/local/bin`):

```bash copy
docker compose stop      # Stop all BloodHound containers
docker compose start     # Start them again
docker compose restart   # Restart (e.g. after editing docker-compose.yml)
./bloodhound-cli update   # Update BloodHound CE to the latest version
./bloodhound-cli resetpwd # Reset the admin password if you lost it
./bloodhound-cli logs     # View container logs (useful for troubleshooting)
```
- `stop` / `start` / `restart`: Standard Docker Compose commands for managing the containers as a group.
- `update`: Pulls newer images and re-deploys BloodHound CE.
- `resetpwd`: Regenerates a random password for the `admin` account and prints it - use this if you're locked out.
- `logs`: Shows recent log output from the containers - the first place to look if something isn't working.
- Run `./bloodhound-cli help` and `./bloodhound-cli <command> --help` to see the exact subcommands/flags for your installed version, since the CLI is actively developed and may add new options.

## SharpHound (Data Collector)

### Recommended: Download From the BloodHound CE UI
1. Log into BloodHound CE (Step 6).
2. Click the **gear/settings icon** and choose **Download Collectors**.
3. Download the **SharpHound** version listed there.
- **Why this is the recommended method**: the collector version offered here is guaranteed to be compatible with your BloodHound CE version. A SharpHound build downloaded separately from GitHub can be too new or too old for your API, causing import errors.

### Alternative: Download From GitHub
1. Go to `https://github.com/SpecterOps/SharpHound/releases`.
2. Download the `SharpHound_vX.X.X_windows_x86.zip` asset for the version you need (the version number is part of the filename, so there's no fixed link).
- Only use this if the in-UI download isn't available, and double-check the version matches what your BloodHound CE expects.

### Run SharpHound and Import the Results
1. Transfer the `SharpHound.exe` (from the unzipped download) to a **domain-joined Windows machine**.
2. Run it from a command prompt:
   ```cmd copy
   SharpHound.exe -c All
   ```
   - `-c All`: Collects all available data (sessions, ACLs, group memberships, trusts, etc.). This is the most thorough option and a good default for a full assessment.
3. SharpHound produces a `.zip` file (e.g. `20260101120000_BloodHound.zip`) in the same folder.
4. Back in the BloodHound CE UI, go to **File Ingest / Upload Files** and upload that `.zip` file.
5. Wait for the ingestion job to finish (you can watch progress in the UI) - the collected data will then appear in the graph.

## Troubleshooting
- **Docker isn't running**: `systemctl status docker` - if it's not `active (running)`, run `systemctl start docker`.
- **Port 8080 already in use**: Run `ss -tulpn | grep 8080` to find what's using it. Either stop that service, or change the port mapping in `docker-compose.yml` (e.g. to `8081:8080`) and use that port in the login URL instead.
- **Containers keep restarting / crash-looping**: Almost always low memory. Check with `docker stats` and `free -h` - BloodHound CE needs at least 8 GB RAM available.
- **Lost the one-time admin password before first login**: Run `./bloodhound-cli resetpwd` from `/opt/bloodhound` to generate a new one.
- **Can't reach the UI from another machine**: Make sure you completed Step 7 (port binding) and that no firewall is blocking port 8080.
