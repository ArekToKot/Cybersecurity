# Git Commands
Commands for enumerating and exploiting exposed .git repositories

## Useful Links
- [GitTools](https://github.com/internetwache/GitTools/)

## GitDumper
Tool for downloading .git repositories from webservers without directory listing.

### Download .git repository
```bash copy
bash gitdumper.sh http://10.10.10.10/.git clone
```
- Downloads a .git repository from the target server to the `clone` directory.

- **Note**: May not fully recover repositories with compressed `pack` files.

## GitExtractor
Script for recovering incomplete .git repositories by restoring commit contents.

### Extract .git repository
```bash copy
bash extractor.sh /tmp/mygitrepo /tmp/mygitrepodump
```
- Recovers contents from an incomplete .git repository into a destination directory.

- **Context**: Use after `GitDumper` if the downloaded repository is incomplete.
- `/tmp/mygitrepo`: Directory containing the .git folder.
- `/tmp/mygitrepodump`: Destination for extracted contents.

## GitFinder
Python script to identify websites with publicly accessible .git repositories by checking for `.git/HEAD`.

### Setup GitFinder
```bash copy
pip3 install -r requirements.txt
```
- Installs dependencies required for GitFinder.
- `-r requirements.txt`: Specifies the requirements file.

### Run GitFinder with input file
```bash copy
python3 gitfinder.py -i targets.txt -o output.txt -t 10
```
- Scans targets from an input file for accessible .git repositories.
- `-i targets.txt`: Specifies input file with target URLs (one per line).
- `-o output.txt`: Specifies output file for results.
- `-t 10`: Sets number of threads to 10.
- **Note**: Outputs discovered domains in the format `[*] Found: DOMAIN`.

## Git Repository Analysis
### Check git status
```bash copy
cd clone
```
- Changes to the cloned .git repository directory.


### View commit history
```bash copy
git log
```
- Shows the commit history of the repository.


### Example Usage
1. Use `GitFinder` to identify accessible .git repositories:
   ```bash copy
   python3 gitfinder.py -i targets.txt -o output.txt -t 10
   ```
2. Use `GitDumper` to download the .git repository:
   ```bash copy
   bash gitdumper.sh http://10.10.10.10/.git clone
   ```
3. If incomplete, use `GitExtractor` to recover contents:
   ```bash copy
   bash extractor.sh /tmp/mygitrepo /tmp/mygitrepodump
   ```
4. Analyze the repository:
   ```bash copy
   cd clone
   git status
   git log
   ```