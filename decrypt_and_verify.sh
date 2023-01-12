#!/usr/bin/env bash

set -Eeuo pipefail

panic() {
    echo "${@}"
    exit 1
}

test "${#}" -ge 1 || panic "Usage: ./decrypt_and_verify.sh [SENDER_EMAIL_ADDRESS]"

readonly SENDER_EMAIL_ADDRESS="${1}"

test -f .env || panic "You haven't created your .env file yet"
test -f allowed-signers || panic "You haven't created your allowed-signers file yet"

# Read settings in .env file
# shellcheck disable=1091
source .env

# Cleanup temp files that may be hanging around from last time we ran this script
rm -Rf .temp
mkdir -p .temp

# Save ciphertext in a file
echo "
Paste CIPHERTEXT and press Ctrl + D when finished:
"
cat > .temp/ciphertext

# Decrypt ciphertext, saving the result in a plaintext file
age --identity "${USER_PRIVATE_KEY}" \
    --decrypt \
    --output .temp/plaintext \
    .temp/ciphertext

echo "
Decrypted message:

$(cat .temp/plaintext)
"

# Save signature in a .sig file
echo "
Paste SIGNATURE and press Ctrl + D when finished:
"
cat > .temp/plaintext.sig

# Verify signature for plaintext
ssh-keygen -Y verify \
    -f "allowed-signers" \
    -I "${SENDER_EMAIL_ADDRESS}" \
    -n "demo" \
    -s ".temp/plaintext.sig" < .temp/plaintext

