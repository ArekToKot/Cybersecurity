# On Linux:

1. Set the SSLKEYLOGFILE environment variable to specify the file where session keys will be logged. You can do this by adding the following line to your shell configuration file (e.g., .bashrc or .zshrc):

```export SSLKEYLOGFILE=~/sslkeys.log```

2. Restart your terminal or run source ~/.bashrc (or the appropriate configuration file) to apply the changes.

3. Open your browser or application, and the session keys will be logged to the specified file.

# On Windows:

1. Set the SSLKEYLOGFILE environment variable to specify the file where session keys will be logged. You can do this by opening a Command Prompt and running the following command:

```set SSLKEYLOGFILE=%USERPROFILE%\Desktop\sslkeys.log```

2. Alternatively, you can set the environment variable through the System Properties:

    Right-click on "This PC" or "Computer" on the desktop or in File Explorer.
    Select "Properties".
    Click on "Advanced system settings" on the left.
    In the System Properties window, click on the "Environment Variables" button.
    Under "User variables", click "New" and enter SSLKEYLOGFILE as the variable name and %USERPROFILE%\sslkeys.log as the variable value.
    Click "OK" to close the dialogs.

3. Open your browser or application, and the session keys will be logged to the specified file.

# On Wireshark:

Next, use Wireshark to load the session key log file and decrypt the captured TLS traffic. Follow these steps:

1. Go to Edit > Preferences > Protocols > TLS and specify the path to the session key log file.

2. Open the captured PCAP file in Wireshark, and it will automatically use the session keys to decrypt the traffic.