#!/bin/bash

set -euo pipefail

DIR=$(pwd)
jq="${DIR}"/jq/jq-linux64

cd "${DIR}"/terraform/terraforming-pas

tfJSON=$("${DIR}"/terraform/terraform output -json)

echo "${tfJSON}" | $jq '.'