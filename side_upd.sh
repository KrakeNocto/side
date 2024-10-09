systemctl stop sided

wget http://162.55.92.13:11558/sided && mv sided /root/.side/cosmovisor/genesis/bin/
chmod +x /root/.side/cosmovisor/genesis/bin/sided

curl -L https://snapshots.kjnodes.com/side-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.side
[[ -f $HOME/.side/data/upgrade-info.json ]] && cp $HOME/.side/data/upgrade-info.json $HOME/.side/cosmovisor/genesis/upgrade-info.json

rm side_upd.sh

systemctl restart sided && journalctl -fu sided
