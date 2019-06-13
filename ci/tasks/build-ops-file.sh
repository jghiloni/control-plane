#!/bin/bash

set -euo pipefail

DIR=$(pwd)
jq="${DIR}"/jq/jq-linux64
chmod +x "$jq"

echo -n "" > "${DIR}"/vars/ops.yml

cd "${DIR}"/terraform/terraforming-pas

tfJSON=$("${DIR}"/terraform/terraform output -json)

get_value() {
    echo "${tfJSON}" | $jq "$@"
}

write_ops() {
    local path=$1
    local value=$2

cat >> "${DIR}"/vars/ops.yml <<EOF
- type: replace
  path: $path
  value: $value

EOF
}

instanceProfile=$(get_value -r '.ops_manager_iam_instance_profile_name.value')
write_ops "/iaas-configurations/name=default/iam_instance_profile" "${instanceProfile}"

cat "${DIR}"/vars/ops.yml