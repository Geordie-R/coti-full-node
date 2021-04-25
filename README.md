# coti-fullnode (pulls down latest version)
Please find below a working solution to run the coti full node on the testnet.
Just follow the wolf script here: https://medium.com/wolf-crypto/how-to-setup-a-coti-testnet-node-on-vultr-a3710d24f892 as per usual until wolf mentions using the install.sh script.

Use the below code instead.

```
wget -O installfullnode.sh https://raw.githubusercontent.com/Geordie-R/coti-full-node/main/installfullnode.sh
chmod +x installfullnode.sh
./installfullnode.sh

```

# Mainnet DB Restore

This will add the following entries to the fullnode.properties file if they dont exist and it will listen to the argument you give the file.  See <TRUE_OR_FALSE_VARIABLE> below.
```
db.restore=<TRUE_OR_FALSE_VARIABLE>
db.restore.source=Remote
db.restore.hash=8eeae832927ed4a95cac73ede5c8b3082e6d3c16c5f98a97d6a7f3fa5b9c8ac364b5e7e8c1cf8d8b09bb23003e4029205d0946d676c6c907d6dccbe35dcbac7b
```

The true or false variable will depend on what you give for example: ./dbrecovery.sh "true" or ./dbrecovery.sh "false"

## Misc Options

### DB Restore ON
```
wget -O dbrecovery.sh https://raw.githubusercontent.com/Geordie-R/coti-full-node/v2.0/dbrecovery.sh
chmod +x dbrecovery.sh
./dbrecovery.sh "true"

```

### DB Restore OFF
```
wget -O dbrecovery.sh https://raw.githubusercontent.com/Geordie-R/coti-full-node/v2.0/dbrecovery.sh
chmod +x dbrecovery.sh
./dbrecovery.sh "true"

```
