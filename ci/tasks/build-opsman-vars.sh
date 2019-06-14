#!/bin/bash

set -e

export DIR=$(pwd)

chmod +x "${DIR}"/jq/jq-linux64
jq="${DIR}"/jq/jq-linux64

cd "${DIR}"/terraform/terraforming-pas

tfJSON=$("${DIR}"/terraform/terraform output -json)
get_value() {
    echo "${tfJSON}" | $jq "$@"
}

echo "---" > "${DIR}"/opsman-vars/vars.yml
write_var() {
   echo "$@" >> "${DIR}"/opsman-vars/vars.yml
}

write_var "region: $(get_value '.region.value')"
write_var "opsman-name: ${ENV_NAME}-ops-manager"
write_var "public-subnet-id: $(get_value '.public_subnet_ids.value[0]')"
write_var "opsman-security-group: $(get_value '.ops_manager_security_group_id.value')"
write_var "opsman-keypair-name: ${ENV_NAME}-ops-manager-key"
write_var "access-key-id: $(get_value '.ops_manager_iam_user_access_key.value')"
write_var "secret-access-key: $(get_value '.ops_manager_iam_user_secret_key.value')"
write_var "opsman-public-ip: $(get_value '.ops_manager_public_ip.value')"
write_var "environment: ${ENV_NAME}"