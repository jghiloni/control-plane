#!/bin/bash

set -euo pipefail

DIR=$(dirname $0)
OUT="${DIR}/out"
domain=$1

mkdir -p "${OUT}"
certJSON=$(om generate-certificate -d "plane.$domain,uaa.$domain,credhub.$domain,uaa.service.cf.internal,credhub.service.cf.internal")
echo "${certJSON}" | jq -r '.certificate' > "${OUT}/control-plane.crt"
echo "${certJSON}" | jq -r '.key' > "${OUT}/control-plane.key"
