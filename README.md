# Coti Full Node Install
Please find below a working solution to run the coti full node on testnet, mainnet install is under construction. The latest version will be pulled down.

```
rm -rf installfullnode.sh
wget -O installfullnode.sh https://raw.githubusercontent.com/Geordie-R/coti-full-node/New-API-Integration-v1/installfullnode.sh
chmod +x installfullnode.sh
./installfullnode.sh

```


# Coti Full Node - Retrieve Seed and Keys then delete
Are you an exchange that has used an API key whilst installing and want to retrieve your seed and keys before deleting the keys file? Run the following after you have ran the install above.

```
rm -rf getkeysthendelete.sh
wget -O getkeysthendelete.sh https://raw.githubusercontent.com/Geordie-R/coti-full-node/New-API-Integration-v1/getkeysthendelete.sh
chmod +x getkeysthendelete.sh
./getkeysthendelete.sh

```




# Coti Full Node Uninstall
Please find below code to uninstall the coti full node on testnet and mainnet.  This is still under construction.

```
rm -rf uninstallfullnode.sh
wget -O uninstallfullnode.sh https://raw.githubusercontent.com/Geordie-R/coti-full-node/New-API-Integration-v1/uninstallfullnode.sh
chmod +x uninstallfullnode.sh
./uninstallfullnode.sh

```



