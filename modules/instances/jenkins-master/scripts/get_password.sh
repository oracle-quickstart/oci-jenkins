#!/bin/bash

# Exit if any of the intermediate steps fail
set -uex

# Extract "private_key" and "host" arguments from the input into
# PRIVATE_KEY and HOST shell variables.
# jq will ensure that the values are properly quoted
# and escaped for consumption by the shell.
eval "$(jq -r '@sh "PRIVATE_KEY=\(.private_key) HOST=\(.host)"')"

# SSH to Jenkins Master host using private key to get initial AdminPassword
PASSWD="$(ssh -oStrictHostKeyChecking=no -i ${PRIVATE_KEY} opc@${HOST} 'sudo cat /tmp/secret')"

# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.
jq -n --arg password "$PASSWD" '{"password":$password}'
