# Coti Full Node Install
Please find below a working solution to run the coti full node on testnet, mainnet install is under construction. The latest version will be pulled down.

```
wget -O installfullnode.sh https://raw.githubusercontent.com/Geordie-R/coti-full-node/New-API-Integration-v1/installfullnode.sh
chmod +x installfullnode.sh
./installfullnode.sh

```


# Coti Full Node - Retrieve Seed and Keys
Are you an exchange that has used an API key whilst installing and want to retrieve your seed and keys before deleting the keys file? Run the following after you have ran the install above.

```
wget -O getkeys.sh https://raw.githubusercontent.com/Geordie-R/coti-full-node/New-API-Integration-v1/getkeys.sh
chmod +x getkeys.sh
./getkeys.sh

```




# Coti Full Node Uninstall
Please find below code to uninstall the coti full node on testnet and mainnet.  This is still under construction.

```
wget -O uninstallfullnode.sh https://raw.githubusercontent.com/Geordie-R/coti-full-node/New-API-Integration-v1/uninstallfullnode.sh
chmod +x uninstallfullnode.sh
./uninstallfullnode.sh

```



