systemctl stop sided

mkdir -p /root/.side/cosmovisor/upgrades/v0.9.2/bin/
wget http://148.251.46.18:11558/sided && mv sided /root/.side/cosmovisor/upgrades/v0.9.2/bin/
chmod +x /root/.side/cosmovisor/upgrades/v0.9.2/bin/sided

curl -Ls https://snapshots.kjnodes.com/side-testnet/addrbook.json > $HOME/.side/config/addrbook.json

cp $HOME/.side/data/priv_validator_state.json $HOME/.side/priv_validator_state.json.backup
rm -rf $HOME/.side/data
rm -rf $HOME/.side/data $HOME/.side/wasm
curl https://server-5.itrocket.net/testnet/side/side_2024-10-18_255075_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.side
mv $HOME/.side/priv_validator_state.json.backup $HOME/.side/data/priv_validator_state.json

rm side_upd.sh

systemctl daemon-reload && systemctl restart sided && journalctl -fu sided
