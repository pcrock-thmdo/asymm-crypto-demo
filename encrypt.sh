#!/usr/bin/env bash

set -Eeuo pipefail

panic() {
    echo "${@}"
    exit 1
}

test "${#}" -ge 1 || panic "Usage: ./encrypt.sh [RECIPIENT_EMAIL_ADDRESS]"

readonly RECIPIENT_EMAIL_ADDRESS="${1}"

test -f .env || panic "You haven't created your .env file yet"
test -f allowed-signers || panic "You haven't created your allowed-signers file yet"

# Read settings in .env file
# shellcheck disable=1091
source .env

# Cleanup temp files that may be hanging around from last time we ran this script
rm -Rf .temp
mkdir -p .temp

# Find the public key of your recipient in the allowed-signers file
get_recipient_pub_key() {
    grep -F "${RECIPIENT_EMAIL_ADDRESS}" allowed-signers | cut -d " " -f "2-"
}

if ! get_recipient_pub_key; then
    panic "Unable to find ${RECIPIENT_EMAIL_ADDRESS} in allowed-signers file."
fi

RECIPIENT_PUB_KEY="$(get_recipient_pub_key)"

# Save plaintext user input to a file
echo "
Enter message and press Ctrl + D when finished:
"
cat > .temp/plaintext

# Encrypt plaintext with recipient's public key and save into a ciphertext file
age --recipient "${RECIPIENT_PUB_KEY}" --armor > .temp/ciphertext < .temp/plaintext

# Sign plaintext with MY private key and save signature into a plaintext.sig file
ssh-keygen -Y sign -f "${USER_PRIVATE_KEY}" -n demo > .temp/plaintext.sig < .temp/plaintext

echo "
Encrypted message:

$(cat .temp/ciphertext)

Signature:

$(cat .temp/plaintext.sig)
"

rm .temp/plaintext
