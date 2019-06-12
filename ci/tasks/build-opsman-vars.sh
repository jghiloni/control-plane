#!/bin/bash

export PATH="$(pwd)/jq":${PATH}

jq=jq-linux64
json=$(cat $(pwd)/terraform-state/terraform.tfstate)

echo -n "region: " >> opsman-vars/vars.yml
echo "${json}" | $jq -r '.modules[] | select(.outputs.region?) | .outputs.region.value' >> opsman-vars/vars.yml

echo "opsman-name: ${ENV_NAME}-ops-manager" >> opsman-vars/vars.yml

echo -n "public-subnet-id: " >> opsman-vars/vars.yml
echo "${json}" | $jq -r '.modules[] | select(.outputs.public_subnet_ids?) | select(.path==["root"]) | .outputs.public_subnet_ids.value[0]' >> opsman-vars/vars.yml

echo -n "opsman-security-group: " >> opsman-vars/vars.yml
echo "${json}" | $jq -r '.modules[] | select(.outputs.ops_manager_security_group_id?) | select(.path==["root"]) | .outputs.ops_manager_security_group_id.value' >> opsman-vars/vars.yml

echo "opsman-iam-profile: ${ENV_NAME}_ops_manager" >> opsman-vars/vars.yml

echo -n "opsman-public-ip: " >> opsman-vars/vars.yml
echo "${json}" | $jq -r '.modules[] | select(.outputs.ops_manager_public_ip?) | select(.path==["root"]) | .outputs.ops_manager_public_ip.value' >> opsman-vars/vars.yml

cat opsman-vars/vars.yml