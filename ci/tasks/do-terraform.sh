#!/bin/bash

set -e 

DIR=$(pwd)
export PATH="${DIR}"/terraform:${PATH}

cd "${DIR}/terraform/terraforming-pas"

terraform plan -var-file="${DIR}/source/config/terraform/terraform.tfvars" -out=plan
terraform apply plan 