#!/bin/bash

echo "Mnemonic from wallet_1 (send from):"
read -r WALLET_1_MNEM
echo "Mnemonic from wallet_2 (send to):"
read -r WALLET_2_MNEM
echo "Enter Moniker:"
read -r MONIKER

echo $WALLET_1_MNEM | /root/.side/cosmovisor/upgrades/v0.9.2/bin/sided keys add wallet_1 --keyring-backend test --key-type="taproot" --recover --hd-path="m/86'/1'/0'/0/0"
echo $WALLET_2_MNEM | /root/.side/cosmovisor/upgrades/v0.9.2/bin/sided keys add wallet_2 --recover --keyring-backend test

min_time_s=600
max_time_s=43200
sleep_time_s=$(shuf -i $min_time_s-$max_time_s -n 1)

WALLET_1=""
WALLET_2=""

while read -r line; do
  if echo "$line" | grep -q "address:"; then
    if [ -n "$WALLET_1" ]; then
      WALLET_2=$(echo "$line" | sed 's/.*address: //g')
    else
      WALLET_1=$(echo "$line" | sed 's/.*address: //g')
    fi
  fi
done < <(/root/.side/cosmovisor/upgrades/v0.9.2/bin/sided keys list --keyring-backend test)

echo "wallet_1: $WALLET_1"
echo "wallet_2: $WALLET_2"

echo "Sending tokens after $sleep_time_s seconds"
sleep $sleep_time_s

min_sum=600
max_sum=43200
sum_to_send=$(shuf -i $min_sum-$max_sum -n 1)

min_fee=600
max_fee=43200
fees=$(shuf -i $min_fee-$max_fee -n 1)

PORT=$(grep -oP '127\.0\.0\.1:\K[0-9]*57' .side/config/config.toml)
/root/.side/cosmovisor/upgrades/v0.9.2/bin/sided --node tcp://0.0.0.0:$PORT tx bank send $WALLET_1 $WALLET_2 ${sum_to_send}uside --chain-id sidechain-testnet-4 --gas auto --gas-adjustment 1.5 --fees ${fees}uside -y --keyring-backend test -y

/root/.side/cosmovisor/upgrades/v0.9.2/bin/sided keys delete wallet_1 --keyring-backend test -y

min_time_c=600
max_time_c=43200
sleep_time_c=$(shuf -i $min_time_c-$max_time_c -n 1)

echo "Creating validator after $sleep_time_c seconds"
sleep $sleep_time_c

min_am=600
max_am=43200
am=$(shuf -i $min_am-$max_am -n 1)

min_r=5
max_r=10
rate=$(shuf -i $min_r-$max_r -n 1)
rate=$(printf "%02d" $rate)

min_com=10
max_com=20
comission=$(shuf -i $min_com-$max_com -n 1)

/root/.side/cosmovisor/upgrades/v0.9.2/bin/sided --node tcp://0.0.0.0:$PORT tx staking create-validator \
--amount ${am}uside \
--from wallet_2 \
--commission-rate 0.${rate} \
--commission-max-rate 0.${comission} \
--commission-max-change-rate 0.01 \
--min-self-delegation 1 \
--pubkey $(/root/.side/cosmovisor/upgrades/v0.9.2/bin/sided tendermint show-validator) \
--moniker "$MONIKER" \
--identity "" \
--website "" \
--details "" \
--chain-id sidechain-testnet-4 \
--gas auto --gas-adjustment 1.5 --fees ${fees}uside \
-y

/root/.side/cosmovisor/upgrades/v0.9.2/bin/sided keys delete wallet_2 --keyring-backend test -y

rm create_validator.sh
