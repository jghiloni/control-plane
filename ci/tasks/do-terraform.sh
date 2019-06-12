#!/bin/bash

set -e 

DIR=$(pwd)

curl -o terraform.zip https://releases.hashicorp.com/terraform/0.11.14/terraform_0.11.14_linux_amd64.zip
unzip terraform.zip -d terraform
export PATH=${PWD}/terraform:${PATH}

cd "${DIR}/terraforming-aws/terraforming-pas"

cp -vf ${DIR}/source/config/terraform/*.tf .

AWS_ACCESS_KEY="${TF_VAR_access_key}" \
AWS_SECRET_KEY="${TF_VAR_secret_key}" \
AWS_DEFAULT_REGION="${TF_VAR_region}" \
terraform init \
  --backend-config="bucket=${TF_VAR_bucket}" \
  --backend-config="key=${TF_VAR_key}"
terraform plan -var-file="${DIR}/source/config/terraform/terraform.tfvars" -out=plan
terraform apply plan 