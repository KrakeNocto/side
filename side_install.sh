sudo apt -q update
sudo apt -qy install curl git jq lz4 build-essential
sudo apt -qy upgrade

echo "Moniker:"
read -r MONIKER

cd $HOME
rm -rf side
git clone https://github.com/sideprotocol/side.git

mkdir -p $HOME/.side/cosmovisor/genesis/bin

wget http://162.55.92.13:11558/sided && mv sided /root/.side/cosmovisor/genesis/bin/
chmod +x /root/.side/cosmovisor/genesis/bin/sided

go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.6.0

$HOME/.side/cosmovisor/genesis/bin/sided config chain-id sidechain-testnet-4

$HOME/.side/cosmovisor/genesis/bin/sided init $MONIKER --chain-id sidechain-testnet-4

curl -Ls https://snapshots.kjnodes.com/side-testnet/genesis.json > $HOME/.side/config/genesis.json
curl -Ls https://snapshots.kjnodes.com/side-testnet/addrbook.json > $HOME/.side/config/addrbook.json

sudo tee /etc/systemd/system/side.service > /dev/null << EOF
[Unit]
Description=side node service
After=network-online.target

[Service]
User=root
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.side"
Environment="DAEMON_NAME=sided"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.side/cosmovisor/current/bin"

[Install]
WantedBy=multi-user.target
EOF

min_am=10
max_am=64
PORT=$(shuf -i $min_am-$max_am -n 1)
echo $PORT

sed -i.bak -e "s|^laddr = \"tcp://127.0.0.1:26657\"|laddr = \"tcp://127.0.0.1:2${PORT}57\"|" $HOME/.side/config/config.toml
sed -i.bak -e "s|^laddr = \"tcp://0.0.0.0:26656\"|laddr = \"tcp://0.0.0.0:2${PORT}56\"|" $HOME/.side/config/config.toml
sed -i.bak -e "s|^pprof_laddr = \"localhost:6060\"|pprof_laddr = \"localhost:60${PORT}\"|" $HOME/.side/config/config.toml
sed -i.bak -e "s|^address = \"localhost:9090\"|address = \"localhost:90${PORT}\"|" $HOME/.side/config/app.toml

sed -i -e "s|^seeds *=.*|seeds = \"3f472746f46493309650e5a033076689996c8881@side-testnet.rpc.kjnodes.com:17459\"|" $HOME/.side/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.005uside\"|" $HOME/.side/config/app.toml
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
  $HOME/.side/config/app.toml

curl -L https://snapshots.kjnodes.com/side-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.side
[[ -f $HOME/.side/data/upgrade-info.json ]] && cp $HOME/.side/data/upgrade-info.json $HOME/.side/cosmovisor/genesis/upgrade-info.json

rm side_install.sh

sudo systemctl daemon-reload
sudo systemctl enable side.service
sudo systemctl start side.service && sudo journalctl -u side.service -f --no-hostname -o cat
