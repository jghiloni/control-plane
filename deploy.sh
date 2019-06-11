#!/bin/bash

DIR=$(dirname $0)

bosh update-config --type=runtime --name=control-plane-dns "${DIR}/dns-runtime-config.yml" -l "${DIR}/vars.yml" -n
bosh -d control-plane deploy "${DIR}/manifest.yml" -l "${DIR}/vars.yml" -l "${DIR}/resource-config.yml" -n
