#!/bin/bash
echo "P2SH Example: 2. Generate P2SH script and P2SH address"

# https://unix.stackexchange.com/questions/175648/use-config-file-for-my-shell-script

typeset -A config # init array
config=( # set default values in config array
    [bob_address]=""
    [bob_pubkey]=""
    [alice_address]=""
    [alice_pubkey]=""
    [address]=""
    [script]=""
    [blockheight]=123456
)

while read line
do
    if echo $line | grep -F = &>/dev/null
    then
        varname=$(echo "$line" | cut -d '=' -f 1)
        config[$varname]=$(echo "$line" | cut -d '=' -f 2-)
    fi
done < config

while read line
do
    if echo $line | grep -F = &>/dev/null
    then
        varname=$(echo "$line" | cut -d '=' -f 1)
        config[$varname]=$(echo "$line" | cut -d '=' -f 2-)
    fi
done < config2

# Old LN Invoice:
invoice="lnbc1331180n1pwc38rwpp540n2natulewufet0mglmtse42v7uu702shfxal76a3tqakumyu3qdpc2pskjepqw3hjq4rgv5syymr0vd4jqsmpvejjq2z0wfjx2u3q$

# Payment hash
payment_hash="abe6a9f57cfe5dc4e56fda3fb5c335533dce79ea85d26effdaec560edb9b2722"

# Preimage (preimage is secret known by the invoicer and revealed to invoice payer after successfull payment):
preimage="f40b4934faf31658821415ff2bf8bf54e30d5b2fa09d9f706cc6f0e2a28d1d9a"

utxos=$(curl -s https://kmdexplorer.io/insight-api-komodo/addr/${config[address]}/utxo)
utxos=$(curl -s https://kmdexplorer.io/insight-api-komodo/addr/bZdMzfVc7Ec1pC8m3RjirQK9fCPBMEtx3h/utxo)
txid=$(echo $utxos | jq -r '.[0].txid')
vout=$(echo $utxos | jq -r '.[0].vout')
echo $txid
echo $vout
vout_hex=$(printf "%08x" $vout | dd conv=swab 2> /dev/null | rev)
echo $vout_hex
printf '%x\n' $vout

awtx="04000080" # tx header
rawtx=$rawtx"85202f89" # versiongroupid
rawtx=$rawtx"01" # number of inputs
rawtx=$rawtx$txid # txid of the funding tx
rawtx=$rawtx$vout_hex # vout of the funding tx
rawtx=$rawtx"00ffffffff" # locktime
rawtx=$rawtx"01" # output count
rawtx=$rawtx"40420f0000000000" # 0.01 KMD
rawtx=$rawtx"2321"
rawtx=$rawtx${config[alice_pubkey]}
rawtx=$rawtx"ac"
nlocktime=$(printf "%08x" $(date +%s) | dd conv=swab 2> /dev/null | rev)
rawtx=$rawtx$nlocktime
rawtx=$rawtx"000000000000000000000000000000"

echo $rawtx

signed=$(./komodo-cli signrawtransaction $rawtx | jq -r '.hex')
echo $signed

