#!/usr/bin/env bash
set -e

## Install the repo
if [ ! -d /opt/frontline ]; then
  echo "$1" | sudo -S bash -c '
    apt-get install -y git make;
    git config --global --add safe.directory /opt/frontline;
    git clone https://github.com/javanile/frontline /opt/frontline;
  '
fi

cd /opt/frontline

echo "==> Update"
echo "$1" | sudo -S git pull

if [ ! -f .env ]; then
  echo "$1" | sudo -S cp .env.prod .env
fi

echo "==> Restart"
echo "$1" | sudo -S make restart
