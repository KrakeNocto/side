#!/bin/bash

echo "Mnemonic from wallet_2 (send to):"
read -r WALLET_2_MNEM
echo "Enter Moniker:"
read -r MONIKER

echo $WALLET_2_MNEM | /root/go/bin/sided keys add wallet_2 --recover --keyring-backend test

echo "Sleeping 0 seconds (0 hours)"
sleep 0

WALLET_2=""

echo "wallet_2: $WALLET_2"

min_time_c=1200
max_time_c=50400
sleep_time_c=$(shuf -i $min_time_c-$max_time_c -n 1)

echo "Creating validator after $sleep_time_c seconds"
sleep $sleep_time_c

min_fee=1300
max_fee=1500
fees=$(shuf -i $min_fee-$max_fee -n 1)

PORT=$(grep -oP '127\.0\.0\.1:\K[0-9]*57' .side/config/config.toml)

min_r=5
max_r=10
rate=$(shuf -i $min_r-$max_r -n 1)
rate=$(printf "%02d" $rate)

min_com=10
max_com=20
comission=$(shuf -i $min_com-$max_com -n 1)

min_am=2100000
max_am=4700000
am=$(shuf -i $min_am-$max_am -n 1)

/root/go/bin/sided --node tcp://0.0.0.0:$PORT tx staking create-validator \
--amount ${am}uside \
--from wallet_2 \
--commission-rate 0.${rate} \
--commission-max-rate 0.${comission} \
--commission-max-change-rate 0.01 \
--min-self-delegation 1 \
--pubkey $(/root/go/bin/sided tendermint show-validator) \
--moniker "$MONIKER" \
--identity "" \
--website "" \
--details "" \
--chain-id sidechain-testnet-4 \
--gas auto --gas-adjustment 1.5 --fees ${fees}uside \
--keyring-backend test \
-y

/root/go/bin/sided keys delete wallet_2 --keyring-backend test -y

rm tx_to_create_val.sh
