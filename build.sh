#!/usr/bin/env bash
# exit on error
set -o errexit

poetry install 

python ./myProj/manage.py collectstatic --no-input
python ./myProj/manage.py migrate 