# coti-fullnode (pulls down latest version)
Please find below a working solution to run the coti full node on the testnet.
Just follow the wolf script here: https://medium.com/wolf-crypto/how-to-setup-a-coti-testnet-node-on-vultr-a3710d24f892 as per usual until wolf mentions using the install.sh script.

Use the below code instead.

```
wget -O installfullnode.sh https://raw.githubusercontent.com/Geordie-R/coti-full-node/main/installfullnode.sh
chmod +x installfullnode.sh
./installfullnode.sh

```

rm -rf upgrade.sh
wget -O upgrade.sh https://raw.githubusercontent.com/Geordie-R/coti-node-upgrade/main/upgrade.sh && chmod +x upgrade.sh
./upgrade.sh
