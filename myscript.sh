#!/bin/bash
if [ 1 -eq 1 ]; then echo "Matched!"; fi

echo ""
echo ""

echo "Setting display env"
set -x DISPLAY | (cat /etc/resolv.conf | grep nameserver | awk '{print $2}')

echo ""
echo ""

echo "Spawning dbus-daemon"
grep dbus-daemon 2&> /dev/null
# grep -rq pam_gnome_keyring.so /etc/pam.* && echo "Have PAM Support"
if [ test $status -eq 1 ]; then 
  echo "Launching dbus"
##   IFS - Internal Fields Separators
#   IFS_1=bus_address
#   IFS_2=ignored
#   IFS_3=bus_pid
#   IFS_4=bus_windowid
  dbus-launch --sh-syntax | read -r bus_address ignored bus_pid bus_windowid 
  
  set -Ux DBUS_SESSION_BUS_ADDRESS -r "'(.*)'" bus_address[2]
  set -Ux DBUS_SESSION_BUS_ID -r "=(.*);" bus_pid[2]
  set -Ux DBUS_SESSION_BUS_WINDOWID -r "=(.*);" bus_windowid[2]
  
fi


# grep limited to 15 chars, so truncate `daemon`
echo ""
echo ""

echo "Spawning gnome-keyring-daemon"
grep gnome-keyring-d 2&> /dev/null

if [ test $status -eq 1 ]; then
#   IFS_5=gnome_keyring_control
#   IFS_6=ssh_auth_sock
  gnome-keyring-daemon | read -r gnome_keyring_control ssh_auth_sock
  
  set -Ux GNOME_KEYRING_CONTROL -m 1 gnome_keyring_control
  set -Ux SSH_AUTH_SOCK -m 1 ssh_auth_sock
  
fi

echo ""
echo ""

echo "Set env for DBUS"
env "eval `dbus-launch`"

echo ""
echo ""

echo "Unlocking keyring"
env "$(printf '\n' | gnome-keyring-daemon --unlock)"

echo "Fin"
