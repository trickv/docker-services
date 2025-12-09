#!/bin/sh

date

# install git
if ! command -v git > /dev/null 2>&1; then
    apk add --no-cache git
fi

if ! command -v python > /dev/null 2>&1; then
    apk add --no-cache python3
fi

git config --global --add safe.directory /website

cd /website
rm -rf venv
python3 -m venv venv
venv/bin/pip install -r requirements.txt
./get-schedule.sh
git pull origin main
venv/bin/python3 render-all-lines.py
#chown -Rv 101:101 .
