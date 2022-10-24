# Coti Full Node Install
### Now achieves SSL A+ rating at https://www.ssllabs.com/ssltest/
Please find below a working solution to run the coti full node on testnet and mainnet. The latest version will be pulled down. Mainnet and exchange users should be provided with a version number so they should use that.

I advise you to refer to this comprehensive manual here: https://geordier.gitbook.io/geordie-docs/

```
rm -rf installfullnode.sh
wget -O installfullnode.sh https://raw.githubusercontent.com/Geordie-R/coti-full-node/main/installfullnode.sh
chmod +x installfullnode.sh
./installfullnode.sh

```


# Coti Full Node - Retrieve Seed and Keys then delete
Are you an exchange that has used an API key whilst installing and want to retrieve your seed and keys before deleting the keys file? Run the following after you have ran the install above.

```
rm -rf getkeysthendelete.sh
wget -O getkeysthendelete.sh https://raw.githubusercontent.com/Geordie-R/coti-full-node/main/getkeysthendelete.sh



chmod +x getkeysthendelete.sh
./getkeysthendelete.sh

```




# Coti Full Node Uninstall
Please find below code to uninstall the coti full node on testnet and mainnet.

```
rm -rf uninstallfullnode.sh
wget -O uninstallfullnode.sh https://raw.githubusercontent.com/Geordie-R/coti-full-node/main/uninstallfullnode.sh
chmod +x uninstallfullnode.sh
./uninstallfullnode.sh

```

## Corrupt database?
If you get a corrupt database run the following code to set a reset.transactions=true in your config and restart your cnode.service.
### Step 1 - Set reset.transactions to true
```
cd ~
rm -rf reset_transactions.sh
wget -O reset_transactions.sh https://raw.githubusercontent.com/Geordie-R/coti-node-upgrade/main/reset_transactions.sh && chmod +x reset_transactions.sh
./reset_transactions.sh "true"
```

### Step 2 - Reboot the cnode.service
```
sudo systemctl stop cnode.service
sudo systemctl start cnode.service
```
### Step 3 - Set reset.transactions back to false
Finally once your node is back up and running, set the reset to false so that we dont wipe the transactions on the next reboot.
```
./reset_transactions.sh "false"
```



