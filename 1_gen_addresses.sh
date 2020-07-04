#!/bin/bash
echo "P2SH Example"

echo "---> Bob:"
bob_address=$(./komodo-cli getnewaddress)
echo "Address: "$bob_address
bob_validateaddress=$(./komodo-cli validateaddress $bob_address)
bob_pubkey=$(echo $bob_validateaddress | jq -r '.pubkey')
echo "Pubkey: "$bob_pubkey

echo "---> Alice:"
alice_address=$(./komodo-cli getnewaddress)
echo "Address: "$alice_address
alice_validateaddress=$(./komodo-cli validateaddress $alice_address)
alice_pubkey=$(echo $alice_validateaddress | jq -r '.pubkey')
echo "Pubkey: "$alice_pubkey

# TODO: Check that config file doesn't exist

echo "bob_address="$bob_address >> config
echo "bob_pubkey="$bob_pubkey >> config
echo "alice_address="$alice_address >> config
echo "alice_pubkey="$alice_pubkey >> config

echo "Addresses generated, please run the Script 2 to generate script and P2SH address"
