#!/bin/bash

# inspired from https://github.com/DeckerSU/komodo_scripts/blob/master/split_nn_sapling.sh#L60

P2SH_ADDRESS=bZdMzfVc7Ec1pC8m3RjirQK9fCPBMEtx3h

ALICE_PUBKEY=028007c3e1da677b084a0c3177e332cdda8d6c0fc18659d8bb781a4b9b2db944be
ALICE_PRIVKEY=***

curl -s https://kmdexplorer.io/insight-api-komodo/addr/$P2SH_ADDRESS/utxo > split_nn.utxos

utxos=$(<split_nn.utxos)
utxo=$(echo "$utxos" | jq "[.[] | select (.amount > $SPLIT_TOTAL and .confirmations > 0)][0]")
if [[ $utxo != "null" ]]; then
  txid=$(echo "$utxo" | jq -r .txid)
  vout=$(echo "$utxo" | jq -r .vout)
  amount=$(echo "$utxo" | jq -r .amount)
  satoshis=$(echo "$utxo" | jq -r .satoshis)
  scriptPubKey=$(echo "$utxo" | jq -r .scriptPubKey)

  #echo $txid $vout $amount $satoshis
  echo "Amount:" $amount "("$satoshis")"

  rev_txid=$(echo $txid | dd conv=swab 2> /dev/null | rev)
  vout_hex=$(printf "%08x" $vout | dd conv=swab 2> /dev/null | rev)
  rawtx="04000080" # tx header
  rawtx=$rawtx"85202f89" # versiongroupid
  rawtx=$rawtx"01" # number of inputs (1, as we take one utxo from explorer listunspent)
  rawtx=$rawtx$rev_txid$vout_hex"00ffffffff"
  # outputs
  
  oc=1
  outputCount=$(printf "%02x" $oc)



	rawtx=$rawtx$outputCount
	for (( i=1; i<=$SPLIT_COUNT; i++ ))
	do
	value=$(printf "%016x" $SPLIT_VALUE_SATOSHI | dd conv=swab 2> /dev/null | rev)
	rawtx=$rawtx$value
	rawtx=$rawtx"2321"$NN_PUBKEY"ac"
	done

        change=$(jq -n "($satoshis-$SPLIT_TOTAL_SATOSHI)/100000000")
	change_satoshis=$(jq -n "$satoshis-$SPLIT_TOTAL_SATOSHI")
	echo "Change:" $change "("$change_satoshis")"
	value=$(printf "%016x" $change_satoshis | dd conv=swab 2> /dev/null | rev)
	rawtx=$rawtx$value
	rawtx=$rawtx"1976a914"$FROM_HASH160"88ac" # len OP_DUP OP_HASH160 len hash OP_EQUALVERIFY OP_CHECKSIG
  else
	# more than 252 outputs not handled now (!) TODO
	echo -e $RED"Error!"$RESET" More than 252 outputs not handled now!"
	exit
  	rawtx=$rawtx"00"
  fi

  nlocktime=$(printf "%08x" $(date +%s) | dd conv=swab 2> /dev/null | rev)
  rawtx=$rawtx$nlocktime
  rawtx=$rawtx"000000000000000000000000000000" # sapling end of tx

  #echo $rawtx
else
  echo -e $RED"Error!"$RESET" Nothing to split ... :("
fi

# signrawtransaction hex "[]" "[\"privkey\"]"

curdir=$(pwd)
curluser=user
curlpass=pass
curlport=7771
signed=$(curl -s --user $curluser:$curlpass --data-binary '{"jsonrpc": "1.0", "id":"curltest", "method": "signrawtransaction", "params": ["'$rawtx'", [], ["'$FROM_PRIVKEY'"]]}' -H 'content-type: text/plain;' http://127.0.0.1:$curlport/ | jq -r .result.hex)

echo -e '\n'
echo -e ${YELLOW}'Unsigned TX: '${RESET}$rawtx
echo -e '\n'
echo -e ${YELLOW}'Signed TX: '${RESET}$signed
echo -e '\n'
