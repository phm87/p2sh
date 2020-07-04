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
