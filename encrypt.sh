#!/usr/bin/env bash

set -Eeuo pipefail

panic() {
    echo "${@}"
    exit 1
}

test "${#}" -ge 1 || panic "Usage: encrypt.sh [RECIPIENT_PUB_KEY_PATH]"

readonly RECIPIENT_PUB_KEY_PATH="${1}"

test -f .env || panic "You haven't created your .env file yet"

# shellcheck disable=1091
source .env

# Cleanup temp files that may be hanging around from last time we ran this script
rm -Rf .temp
mkdir -p .temp

# Save plaintext user input to a file
cat > .temp/plaintext

# Encrypt plaintext with recipient's public key and save into a ciphertext file
age --recipients-file "${RECIPIENT_PUB_KEY_PATH}" --armor > .temp/ciphertext < .temp/plaintext

# Sign plaintext with MY private key and save signature into a plaintext.sig file
ssh-keygen -Y sign -f "${USER_PRIVATE_KEY}" -n demo > .temp/plaintext.sig < .temp/plaintext

echo "
Encrypted message:

$(cat .temp/ciphertext)

Signature:

$(cat .temp/plaintext.sig)
"

rm .temp/plaintext
