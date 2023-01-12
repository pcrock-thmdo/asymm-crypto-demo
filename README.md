# Asymmetric Cryptography Demo

Work in progress.

Demonstrates how asymmetric cryptography works using basic CLI tools. Specifically, it uses SSH keys which you
_probably_ already have configured on your dev machine.

## Getting Started

### Install dependencies

Make sure [age](https://github.com/FiloSottile/age) is installed:

* macOS: `brew install age`
* Ubuntu: `sudo apt update && sudo apt install age`

### Set up your repo

Copy [.env.example](.env.example) to `.env` and fill it out with your information.

Do the same for [allowed-signers.example](allowed-signers.example). The `allowed-signers` file simply maps email
addresses to public SSH keys.

## Usage

If you want to encrypt a message that only Phil can decrypt:

```bash
./encrypt.sh [phil's email address]
```

Follow the prompts and a message + signature will be printed which you can copy / paste and send to Phil.

If you want to decrypt a message and verify that it _actually_ came from Phil:

```bash
./decrypt_and_verify.sh [phil's email address]
```

Follow the prompts and you will see the encrypted message + signature verification results.

