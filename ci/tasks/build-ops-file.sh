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

    block=$(echo "{}" | $jq --arg path $path --argjson value "$value" '. |= . + {"type": "replace","path":$path,"value":$value}')
    echo "- ${block}" | bosh int - >> ${DIR}/vars/ops.yml
}

cidrhost() {
    echo "cidrhost($1, $2)" | "${DIR}"/terraform/terraform console)
}

numAZs=$(get_value '.azs.value | length')
for i in $(seq 0 $((numAZs-1))); do
    write_ops "/az-configuration/-" "{\"name\": $(get_value --argjson i $i '.azs.value[$i]')}"
done

write_ops "/iaas-configurations/name=default/iam_instance_profile" "$(get_value '.ops_manager_iam_instance_profile_name.value')"
write_ops "/iaas-configurations/name=default/key_pair_name" "$(get_value '.ops_manager_ssh_public_key_name.value')"
write_ops "/iaas-configurations/name=default/region" "$(get_value '.region.value')"
write_ops "/iaas-configurations/name=default/security_group" "$(get_value '.ops_manager_security_group_id.value')"
write_ops "/iaas-configurations/name=default/ssh_private_key" "$(get_value '.ops_manager_ssh_private_key.value')"

write_ops "/network-assignment/singleton_availability_zone/name" "$(get_value '.azs.value[0]')"

networkBlock='{
    "availability_zone_names": [$az],
    "cidr": $cidr,
    "dns": $dns,
    "gateway": $gateway,
    "iaas_identifier": $subnetId,
    "reserved_ip_ranges": $reservedRanges
}'

set +euo pipefail
vpc_cidr=$(cat "${DIR}"/source/config/terraform/terraform.tfvars | grep 'vpc_cidr' | awk '{print $(NF)}')
[[ -z "${vpc_cidr}" ]] && vpc_cidr='"10.0.0.0/16"'
set -euo pipefail

dns=$(cidrhost "${vpc_cidr}" 2)
for network in pas infrastructure public; do
    for i in $(seq 0 $((numAZs-1))); do
        az=$(get_value --argjson i $i '.azs.value[$i]')
        cidr=$(get_value --arg network $network --argjson i $i '.[$network+"_subnet_cidrs"].value[$i]')
        gateway=$(get_value --arg network $network --argjson i $i '.[$network+"_subnet_gateways"].value[$i]')
        subnetId=$(get_value --arg network $network --argjson i $i '.[$network+"_subnet_ids"].value[$i]')

        firstIP=$(cidrhost "${cidr}" 1)
        midIP=$(cidrhost "${cidr}" 10)
        lastIP=$(cidrhost "${cidr}" -1)
        reservedRanges="$firstIP-$midIP,$lastIP"
        subnet=$(echo '{}' | jq --argjson az "$az" \
            --argjson cidr "$cidr" \
            --argjson gateway "$gateway" \
            --argjson subnetId "$subnetId" \
            --arg reservedRanges "$reservedRanges" \
            ". |= . + ${networkBlock}")
        
        write_ops "/networks-configuration/networks/name=$network/subnets/-" "${subnet}"
    done
done

cat "${DIR}"/vars/ops.yml