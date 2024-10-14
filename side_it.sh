#!/bin/bash

source <(curl -s https://raw.githubusercontent.com/itrocket-team/testnet_guides/main/utils/common.sh)

read -p "Enter your MONIKER :" MONIKER
echo 'export MONIKER='$MONIKER

min_am=10
max_am=64
PORT=$(shuf -i $min_am-$max_am -n 1)
echo $PORT

echo "export MONIKER="$MONIKER"" >> $HOME/.bash_profile
echo "export SIDE_PORT="$PORT"" >> $HOME/.bash_profile
echo "export SIDE_CHAIN_ID="sidechain-testnet-4"" >> $HOME/.bash_profile

cd $HOME
VER="1.21.3"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin

echo $(go version) && sleep 1

source <(curl -s https://raw.githubusercontent.com/itrocket-team/testnet_guides/main/utils/dependencies_install)

cd $HOME
rm -rf side
git clone https://github.com/sideprotocol/side.git
cd side
git checkout v0.9.1
make install

sided config node tcp://localhost:${SIDE_PORT}657
sided config keyring-backend os
sided config chain-id sidechain-testnet-4
sided init $MONIKER --chain-id sidechain-testnet-4
sleep 1

wget -O $HOME/.side/config/genesis.json https://server-5.itrocket.net/testnet/side/genesis.json
wget -O $HOME/.side/config/addrbook.json  https://server-5.itrocket.net/testnet/side/addrbook.json

SEEDS="9c14080752bdfa33f4624f83cd155e2d3976e303@side-testnet-seed.itrocket.net:45656"
PEERS="bbbf623474e377664673bde3256fc35a36ba0df1@side-testnet-peer.itrocket.net:45656,6cabe5f47ae9c986c7c86445572e7f8e3ec2e4ca@85.10.201.125:56656,8722deed81cf55f175a0af40e026fe928b90d02b@65.108.73.186:26656,85a16af0aa674b9d1c17c3f2f3a83f28f468174d@167.235.242.236:26656,9064de4e4b9a7990bb5e466962aa2fc5aaf5b74c@95.216.78.250:26656,027ef6300590b1ca3a2b92a274247e24537bd9c9@65.109.65.248:49656,0877bfe53645c830b21ab4098335b2061dac1efa@69.67.150.107:21396,be133ebd4d4bc4adfc0b06114a96d581a9290c98@212.90.120.2:26656,8f6480016794da4a5a876fdbee6aaaca6ea688fd@[2a03:cfc0:8000:13::b910:27be]:13556,b60a5456c46eb9d2a079fc88f7b3dd04cd826be5@93.159.130.38:36656,28e19707ef34b2c7f9ebc388e4cfc618a010490f@65.109.82.230:22656"
sed -i -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*seeds *=.*/seeds = \"$SEEDS\"/}" \
       -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*persistent_peers *=.*/persistent_peers = \"$PEERS\"/}" \
       $HOME/.side/config/config.toml

# set custom ports in app.toml
sed -i.bak -e "s%:1317%:${SIDE_PORT}317%g;
s%:8080%:${SIDE_PORT}080%g;
s%:9090%:${SIDE_PORT}090%g;
s%:9091%:${SIDE_PORT}091%g;
s%:8545%:${SIDE_PORT}545%g;
s%:8546%:${SIDE_PORT}546%g;
s%:6065%:${SIDE_PORT}065%g" $HOME/.side/config/app.toml

sed -i.bak -e "s%:26658%:${SIDE_PORT}658%g;
s%:26657%:${SIDE_PORT}657%g;
s%:6060%:${SIDE_PORT}060%g;
s%:26656%:${SIDE_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${SIDE_PORT}656\"%;
s%:26660%:${SIDE_PORT}660%g" $HOME/.side/config/config.toml

sudo tee /etc/systemd/system/side.service > /dev/null <<EOF
[Unit]
Description=side node
After=network-online.target
[Service]
User=root
WorkingDirectory=$HOME/.side
ExecStart=$(which sided) start --home $HOME/.side
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sided tendermint unsafe-reset-all --home $HOME/.side
if curl -s --head curl https://server-5.itrocket.net/testnet/side/side_2024-10-14_199435_snap.tar.lz4 | head -n 1 | grep "200" > /dev/null; then
  curl https://server-5.itrocket.net/testnet/side/side_2024-10-14_199435_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.side
    else
  echo "no snapshot founded"
fi

# enable and start service
sudo systemctl daemon-reload
sudo systemctl enable side
sudo systemctl restart side && sudo journalctl -u side
