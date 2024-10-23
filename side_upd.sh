systemctl stop side

wget -O $HOME/.side/config/addrbook.json https://server-5.itrocket.net/testnet/side/addrbook.json

mkdir -p /root/.side/cosmovisor/upgrades/v0.9.3/bin/
wget http://162.55.92.13:12312/sided && cp sided /root/.side/cosmovisor/upgrades/v0.9.2/bin/ && mv sided /root/.side/cosmovisor/upgrades/v0.9.3/bin/
chmod +x /root/.side/cosmovisor/upgrades/v0.9.2/bin/sided
chmod +x /root/.side/cosmovisor/upgrades/v0.9.3/bin/sided

cp $HOME/.side/data/priv_validator_state.json $HOME/.side/priv_validator_state.json.backup
rm -rf $HOME/.side/data
rm -rf $HOME/.side/data $HOME/.side/wasm
curl https://server-5.itrocket.net/testnet/side/side_2024-10-23_327970_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.side
mv $HOME/.side/priv_validator_state.json.backup $HOME/.side/data/priv_validator_state.json

rm side_upd.sh

systemctl daemon-reload && systemctl restart side && journalctl -fu side
