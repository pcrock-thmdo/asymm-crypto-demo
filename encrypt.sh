#!/usr/bin/env bash

set -Eeuo pipefail

panic() {
    echo "${1}"
    exit 1
}

test "${#}" -ge 1 || panic "Usage: encrypt.sh [RECIPIENT_PUB_KEY_PATH]"

readonly RECIPIENT_PUB_KEY_PATH="${1}"

test -f .env || panic "You haven't created your .env file yet"

# shellcheck disable=1091
source .env

rm -Rf .temp
mkdir -p .temp

cat > .temp/plaintext
age --recipients-file "${RECIPIENT_PUB_KEY_PATH}" --armor > .temp/ciphertext < .temp/plaintext
ssh-keygen -Y sign -f "${USER_PRIVATE_KEY}" -n demo > .temp/plaintext.sig < .temp/plaintext

echo "
Encrypted message:

$(cat .temp/ciphertext)

Signature:

$(cat .temp/plaintext.sig)
"

rm .temp/plaintext
