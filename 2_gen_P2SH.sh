#!/bin/bash
echo "P2SH Example: 2. Generate P2SH script and P2SH address"

# https://unix.stackexchange.com/questions/175648/use-config-file-for-my-shell-script

typeset -A config # init array
config=( # set default values in config array
    [bob_address]=""
    [bob_pubkey]=""
    [alice_address]=""
    [alice_pubkey]=""
)

while read line
do
    if echo $line | grep -F = &>/dev/null
    then
        varname=$(echo "$line" | cut -d '=' -f 1)
        config[$varname]=$(echo "$line" | cut -d '=' -f 2-)
    fi
done < config

#echo ${config[username]} # should be loaded from defaults
#echo ${config[password]} # should be loaded from config file
#echo ${config[hostname]} # includes the "injected" code, but it's fine here
#echo ${config[PROMPT_COMMAND]} # also respects variables that you may not have
               # been looking for, but they're sandboxed inside the $config array

# Old LN Invoice:
invoice="lnbc1331180n1pwc38rwpp540n2natulewufet0mglmtse42v7uu702shfxal76a3tqakumyu3qdpc2pskjepqw3hjq4rgv5syymr0vd4jqsmpvejjq2z0wfjx2u3qf9zr5gpf$

# Payment hash
payment_hash="abe6a9f57cfe5dc4e56fda3fb5c335533dce79ea85d26effdaec560edb9b2722"

# Preimage (preimage is secret known by the invoicer and revealed to invoice payer after successfull payment):
preimage="f40b4934faf31658821415ff2bf8bf54e30d5b2fa09d9f706cc6f0e2a28d1d9a"

#echo ${config[bob_address]}

# the delay in block (ctlvExpiry) is the little-endian byte order of the blockheight + delay
# On komodo.com last block is 1897939
blockheight=$(curl -s https://kmdexplorer.io/insight-api-komodo/status?q=getInfo | jq '.info.blocks')
echo "blockheight = "$blockheight
# delay of 100 blocks is chosen to test (but it should be in accordance to the LN invoice expiry, TODO)
blockheight=$(($blockheight+100))

# I'll use int2lehex.sh to convert integer to little endian
# Copy: https://gist.githubusercontent.com/phm87/d549102e2ac92a7df47c3a1339b46319/raw/e361f6626a1def29474adfdbd3cecb2a253052ef/int2lehex.sh
# Original: https://gist.github.com/Janaka-Steph/0202836ac3a1caf8b9359207df7379eb
blockheight_le=$(./int2lehex.sh $blockheight)
echo "Blockheight + 100 little endian= "$blockheight_le
# 37f61c

# P2SH script based on mm2:
# But each pubkey and the little endian blockheight must be prefixed by the length of the data divided by 2 in hex on a even number of characte$

hash160() {
    openssl dgst -sha256 -binary |
    openssl dgst -rmd160 -binary |
    xxd -p -c 80
}
# https://gist.github.com/colindean/5239812#file-generate_bitcoin_address-sh-L51

#function generate_swap_address_mm2like($timelock, $pub_0, $secret_hash, $pub_1) {
#// https://github.com/KomodoPlatform/atomicDEX-API/blob/mm2/mm2src/coins/utxo.rs#L343
#$out = "63";
secret_hash=$(echo $preimage | hash160);
script="63"$blockheight_le"b175"${config[bob_pubkey]}"ac6782""88a9"$secret_hash"88"${config[alice_pubkey]}"ac68"
echo $script;
#$out .= $timelock;
#// Return the memory representation of this integer as a byte array in little-endian byte order.
#$out .= "b1";
#$out .= "75";
#$out .= $pub_0;
#$out .= "ac";
#$out .= "67";
#$out .= "82";
#// $out .= "32 bytes ?
#$out .= "88";
#$out .= "a9";
#$out .= $secret_hash;
#$out .= "88";
#$out .= $pub_1;
#$out .= "ac";
#$out .= "68";
#return $out;
#}

