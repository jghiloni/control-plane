#!/bin/bash

set -e 

version=$(cat terraform-release/version)
DIR=$(pwd)

curl -o terraform.zip https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_amd64.zip
unzip terraform.zip -d terraform
export PATH=${DIR}/terraform:${PATH}

cp -rvf "${DIR}"/terraforming-aws/* "${DIR}"/terraform

cd "${DIR}"/terraform/terraforming-pas

cp -vf "${DIR}"/source/config/terraform/*.tf .

terraform init \
  --backend-config="access_key=${TF_VAR_access_key}" \
  --backend-config="secret_key=${TF_VAR_secret_key}" \
  --backend-config="region=${TF_VAR_region}" \
  --backend-config="bucket=${TF_VAR_bucket}" \
  --backend-config="key=${TF_VAR_key}"
