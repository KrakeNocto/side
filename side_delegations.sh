#!/bin/bash

MNEMONICS_FILE="mnemonics"
VALIDATORS_FILE="validators"
LOG_FILE="delegations"

CHAIN_ID="sidechain-testnet-4"         
DENOM="uside"                 
AMOUNT_MIN=39000000               
AMOUNT_MAX=48999999              
MIN_DELEGATORS=6               
MAX_DELEGATORS=15
SLEEP_MIN=0
SLEEP_MAX=30

echo "Tx logs file" > "$LOG_FILE"
echo "------------------------------------------" >> "$LOG_FILE"

delegate() {
    local mnemonic="$1"
    local validator="$2"
    local amount="$3"

    min_fee=1300
    max_fee=1500
    fees=$(shuf -i $min_fee-$max_fee -n 1)

    wallet_name=$(echo "$mnemonic" | shasum | awk '{print $1}')
    echo "$mnemonic" | cosmosd keys add "$wallet_name" --recover --key-type="taproot" --hd-path="m/86'/1'/0'/0/0" --keyring-backend test --output json > /dev/null

    delegator_address=$(cosmosd keys show "$wallet_name" -a --keyring-backend test)

    cosmosd tx staking delegate "$validator" "$amount$DENOM" --from "$delegator_address" --chain-id "$CHAIN_ID" --gas auto --gas-adjustment 1.5 --fees ${fees}uside --keyring-backend test --yes

    echo "Wallet: $delegator_address -> Validator: $validator, Sum: $amount$DENOM" >> "$LOG_FILE"

    cosmosd keys delete "$wallet_name" --keyring-backend test --yes > /dev/null

    sleep_time=$((RANDOM % (SLEEP_MAX - SLEEP_MIN + 1) + SLEEP_MIN))
    echo "Sleeping $sleep_time seconds..."
    sleep "$sleep_time"
}

readarray -t mnemonics < "$MNEMONICS_FILE"
readarray -t validators < "$VALIDATORS_FILE"

for validator in "${validators[@]}"; do
    num_delegators=$((RANDOM % (MAX_DELEGATORS - MIN_DELEGATORS + 1) + MIN_DELEGATORS))
    
    for ((i=0; i<num_delegators; i++)); do
        mnemonic=${mnemonics[RANDOM % ${#mnemonics[@]}]}
        
        amount=$((RANDOM % (AMOUNT_MAX - AMOUNT_MIN + 1) + AMOUNT_MIN))
        
        delegate "$mnemonic" "$validator" "$amount"
    done
done

echo "Delegation complete. Addresses saved"








rm side_delegations.sh