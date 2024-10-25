echo "Mnemonic from wallet_2 (send to):"
read -r WALLET_2_MNEM

echo $WALLET_2_MNEM | /root/go/bin/sided keys add wallet --recover --keyring-backend test

echo "Sleeping 0 seconds (0 hours)"
sleep 0

min_time_c=600
max_time_c=86400
sleep_time_c=$(shuf -i $min_time_c-$max_time_c -n 1)

echo "Unjail validator after $sleep_time_c seconds"
sleep $sleep_time_c

min_fee=1300
max_fee=1500
fees=$(shuf -i $min_fee-$max_fee -n 1)

PORT=$(grep -oP '(0\.0\.0\.0|127\.0\.0\.1):\K[0-9]*57' .side/config/config.toml)
/root/go/bin/sided --node tcp://0.0.0.0:$PORT tx slashing unjail --from wallet --keyring-backend test --gas auto --gas-adjustment 1.5 --fees ${fees}uside --chain-id sidechain-testnet-4 -y

/root/go/bin/sided keys delete wallet --keyring-backend test -y

rm side_unjail.sh
