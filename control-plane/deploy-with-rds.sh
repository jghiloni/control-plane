#!/bin/bash

set -x

DIR=$(dirname $0)
gov=""
[[ "$#" == 4 ]] && gov="us-gov-"

bosh update-config --type=runtime --name=control-plane-dns "${DIR}/dns-runtime-config.yml" -l "${DIR}/vars.yml" -n
bosh -d control-plane deploy "${DIR}/manifest.yml" \
    -o "${DIR}/use-rds-ops.yml" -l "${DIR}/vars.yml" -l "${DIR}/resource-config.yml" \
    -v rds-hostname=$1 -v rds-username=$2 -v rds-password=$3 \
    --var-file=rds-ca-cert="${DIR}/rds-combined-ca-${gov}bundle.pem"