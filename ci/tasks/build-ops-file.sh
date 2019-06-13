#!/bin/bash

set -euo pipefail

DIR=$(pwd)
jq="${DIR}"/jq/jq-linux64
chmod +x "$jq"

cd "${DIR}"/terraform/terraforming-pas

tfJSON=$("${DIR}"/terraform/terraform output -json)

get_value() {
    echo "${tfJSON}" | $jq "$@"
}

write_ops() {
    local path=$1
    local value=$2

cat >> vars/ops.yml <<EOF
- type: replace
  path: $path
  value: $value

EOF
}

instanceProfile=$(get_query '.ops_manager_instance_profile_name.value')
write_ops "/iaas-configurations/name=default/iam_instance_profile" "${instanceProfile}"

cat vars/ops.yml