systemctl stop sided

wget http://162.55.92.13:11558/sided && mv sided /root/.side/cosmovisor/genesis/bin/
chmod +x /root/.side/cosmovisor/genesis/bin/sided

sed -i 's|ExecStart=/root/go/bin/cosmovisor run start --home /root/.side|ExecStart=/root/go/bin/cosmovisor start --home /root/.side|' /etc/systemd/system/sided.service
sed -i 's|Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"|Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"|' /etc/systemd/system/sided.service

curl -Ls https://snapshots.kjnodes.com/side-testnet/addrbook.json > $HOME/.side/config/addrbook.json
curl -Ls https://snapshots.kjnodes.com/side-testnet/genesis.json > $HOME/.side/config/genesis.json

cp $HOME/.side/data/priv_validator_state.json $HOME/.side/priv_validator_state.json.backup
rm -rf $HOME/.side/data
curl -L https://snapshots.kjnodes.com/side-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.side
[[ -f $HOME/.side/data/upgrade-info.json ]] && cp $HOME/.side/data/upgrade-info.json $HOME/.side/cosmovisor/genesis/upgrade-info.json
mv $HOME/.side/priv_validator_state.json.backup $HOME/.side/data/priv_validator_state.json

rm side_upd.sh

systemctl daemon-reload && systemctl restart sided && journalctl -fu sided
