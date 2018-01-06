#!/bin/bash

set -e

GREEN="\\033[1;32m"
DEFAULT="\\033[0;39m"
RED="\\033[1;31m"

[ -z "$DASH_HOME" ] && echo "Needs the env var DASHENV. (Did you: . ./DASHENV/bin/activate ) Please run the script from the virtual environment." && exit 1;

redis_dir="${DASH_HOME}/../redis/src/"
if [ -e "${redis_dir}" ]; then
    redis_dir=""
fi

[ -f "`which redis-server`" ] || [ ! -e "${redis_dir}" ] && echo "Either ${DASH_HOME}/../redis/src/ does not exist or 'redis-server' is not installed/not on PATH. Please fix and run again." && exit 1

conf_dir="${DASH_HOME}/config/"

screenName="Misp-Dashboard"

screen -dmS "$screenName"
sleep 0.1
echo -e $GREEN"\t* Launching Redis servers"$DEFAULT
screen -S "$screenName" -X screen -t "redis-server" bash -c $redis_dir'redis-server '$conf_dir'6250.conf; read x'

echo -e $GREEN"\t* Launching zmq subscriber"$DEFAULT
screen -S "$screenName" -X screen -t "zmq-subscriber" bash -c './zmq_subscriber.py; read x'

echo -e $GREEN"\t* Launching zmq dispatcher"$DEFAULT
screen -S "$screenName" -X screen -t "zmq-dispatcher" bash -c './zmq_dispatcher.py; read x'

echo -e $GREEN"\t* Launching flask server"$DEFAULT
screen -S "$screenName" -X screen -t "flask" bash -c './server.py; read x'
