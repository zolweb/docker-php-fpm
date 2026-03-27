#!/usr/bin/env bash
set -o errexit

cron -L 15

# Add host ip as an alias in /etc/hosts to allow container to ping it without guessing it's ip everytime
HOST_MACHINE_IP=$(ip route | awk '/default/ { print $3 }')
echo "$HOST_MACHINE_IP host-machine" >> /etc/hosts

php-fpm --nodaemonize
