#!/bin/bash

set -euo pipefail

cat > auth-file/auth.yml <<EOF
---
username: ${USERNAME}
password: ${PASSWORD}
decryption-passphrase: ${DECRYPTION_PASSPHRASE}
EOF