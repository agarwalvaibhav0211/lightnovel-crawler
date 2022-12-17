#!/usr/bin/env bash

#==============================================
# OpenShift or non-sudo environments support
# https://docs.openshift.com/container-platform/3.11/creating_images/guidelines.html#openshift-specific-guidelines
#==============================================

if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi

/usr/bin/supervisord --configuration /etc/supervisord.conf &
SUPERVISOR_PID=$!


function shutdown {
    echo "Trapped SIGTERM/SIGINT/x so shutting down supervisord..."
    kill -s SIGTERM ${SUPERVISOR_PID}
    wait ${SUPERVISOR_PID}
    echo "Shutdown complete"
}

trap shutdown SIGTERM SIGINT

sleep 30

export BOT=discord
export DISCORD_TOKEN=""
export LOG_LEVEL=CRITICAL
export APP_ID=1053554057580662794
export PUBLIC_KEY=d7f3fc236b5e0c57688a2101ed8fe618fb64f5094362cf49ffe6e3b8be66fc89

echo $DISCORD_TOKEN

exec /usr/bin/python3 -m lncrawl --bot discord --shard-id 0 --shard-count 1 $@ &
wait ${SUPERVISOR_PID}
