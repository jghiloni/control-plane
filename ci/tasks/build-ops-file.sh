#!/bin/bash

set -euo pipefail

DIR=$(pwd)
jq="${DIR}"/jq/jq-linux64
chmod +x "$jq"

echo "---" > "${DIR}"/vars/ops.yml

cd "${DIR}"/terraform/terraforming-pas

tfJSON=$("${DIR}"/terraform/terraform output -json)

get_value() {
    echo "${tfJSON}" | $jq "$@"
}

write_ops() {
    local path=$1
    local value=$2

    block=$(echo "{}" | $jq --arg path $path --argjson value "$value" '. |= . + {"type": "replace","path":$path,"value":$value}'
    echo "- $block" | bosh int - >> "${DIR}"/vars/ops.yml
}

write_ops "/iaas-configurations/name=default/iam_instance_profile" "$(get_value -r '.ops_manager_iam_instance_profile_name.value')"
write_ops "/iaas-configurations/name=default/key_pair_name" "$(get_value -r '.ops_manager_ssh_public_key_name.value')"
write_ops "/iaas-configurations/name=default/region" "$(get_value -r '.region.value')"
write_ops "/iaas-configurations/name=default/security_group" "$(get_value -r '.ops_manager_security_group_id.value')"
write_ops "/iaas-configurations/name=default/ssh_private_key" "$(get_value '.ops_manager_ssh_private_key.value'"
numAZs=$(get_value '.azs.value | length')
for i in $(seq 0 $((numAZs-1))); do


cat "${DIR}"/vars/ops.yml