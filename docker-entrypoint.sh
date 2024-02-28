#!/usr/bin/env bash
/usr/sbin/crond -l 2
chmod +x /app/bin/adbconnect
echo "* * * * * /app/bin/adbconnect" | crontab -
exec "$@"