#!/bin/bash

DIR=$(pwd)

curl -o terraform.zip https://releases.hashicorp.com/terraform/0.11.14/terraform_0.11.14_linux_amd64.zip
unzip terraform.zip -d terraform
export PATH=${PWD}/terraform:${PATH}

cd "${DIR}/terraforming-aws/terraforming-pas"

cp "${DIR}/source/config/terraform/*.tf" .

terraform init 
terraform plan -var-file="${DIR}/source/config/terraform/terraform.tfvars" -state="${DIR}/terraform-state/terraform.tfstate" -out=plan
terraform apply plan 