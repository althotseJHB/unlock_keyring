echo "Setting display env"
set -x DISPLAY (cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0

echo "Spawning dbus-daemon"
pgrep dbus-daemon > /dev/null

if test $status -eq 1
  echo "Launching dbus"
  dbus-launch --sh-syntax | read --line bus_address ignored bus_pid bus_windowid

  set -Ux DBUS_SESSION_BUS_ADDRESS (string match -r "'(.*)'" $bus_address)[2]
  set -Ux DBUS_SESSION_BUS_ID (string match -r "=(.*);" $bus_pid)[2]
  set -Ux DBUS_SESSION_BUS_WINDOWID (string match -r "=(.*);" $bus_windowid)[2]
end

# pgrep limited to 15 chars, so truncate `daemon`
echo "Spawning gnome-keyring-daemon"
pgrep gnome-keyring-d > /dev/null

if test $status -eq 1
  gnome-keyring-daemon | read --line gnome_keyring_control ssh_auth_sock

  set -Ux GNOME_KEYRING_CONTROL (string split -m 1 = $gnome_keyring_control)[2]
  set -Ux SSH_AUTH_SOCK (string split -m 1 = $ssh_auth_sock)[2]
end

echo "Set env for DBUS"
fenv "eval `dbus-launch`"

echo "Unlocking keyring"
fenv "eval \"\$(printf '\n' | gnome-keyring-daemon --unlock)\""
