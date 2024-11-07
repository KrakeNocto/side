systemctl stop side

wget http://162.55.92.13:12312/sided && mv sided /root/go/bin/
chmod +x /root/go/bin/sided

wget -O $HOME/.side/config/addrbook.json https://server-5.itrocket.net/testnet/side/addrbook.json

cp $HOME/.side/data/priv_validator_state.json $HOME/.side/priv_validator_state.json.backup
rm -rf $HOME/.side/data
rm -rf $HOME/.side/data $HOME/.side/wasm
curl https://server-5.itrocket.net/testnet/side/side_2024-11-07_552627_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.side
mv $HOME/.side/priv_validator_state.json.backup $HOME/.side/data/priv_validator_state.json

rm side_upd_it.sh

systemctl daemon-reload && systemctl restart side && journalctl -fu side
