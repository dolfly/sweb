#!/usr/bin/env bash
/usr/sbin/crond -l 2
cat <<::-> /etc/periodic/1min/adbconnect
#!/bin/bash
net=${NET:-192.168.100}
port=5555
ips=$(nmap -n -sP ${net}.0/24 -oG - 2>/dev/null | tail -n +2 | grep "$net" | cut -d " " -f2)
for ip in ${ips[@]}; do
    adb connect ${ip}:${port}
done
::-
chmod +x /etc/periodic/1min/adbconnect
exec "$@"