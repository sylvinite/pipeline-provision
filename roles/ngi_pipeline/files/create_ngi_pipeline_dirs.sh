#!/bin/bash

# Minimalistic script that initiates project/site specific
# directories for ngi_pipeline logs and dbs under respective
# site's project dirs.

# To be run as respective func account:
#
# funk_004 -> ngi2016001
# funk_006 -> ngi2016003

if [ $# -ne 1 ]; then
        echo "$0: usage: create_ngi_pipeline_dirs.sh <project id>"
        exit 1
fi

mkdir -p /proj/$1/private/ngi_pipeline/log
mkdir -p /proj/$1/private/ngi_pipeline/db
mkdir -p /proj/$1/private/ngi_pipeline/log/supervisord
find /proj/$1/private/ngi_pipeline -ls
