const { cryptoUtils, EcKeyPair, nodeUtils } = require('@coti-io/crypto');

const fs = require('fs');

// api key that Coti provides, only to be used one time for each seed to insert the public key to the trust score node
global.arrToJson = {};
global.jsonObj = [];
apiKey = "";
network = "testnet";



function addToJsonObj(akey,val){

  global.arrToJson[akey] = val;
//arr.value = val;
//global.jsonObj.push(arr);
}



// check if API Key passed in as an argument, if not leave empty
if(process.argv[2] === null || process.argv[2] === undefined){
  console.log('No API Key passed in to app.js as an argument');
  addToJsonObj("APIKey","");
} else {
  apiKey = process.argv[2];
  console.log('API Key is ' + process.argv[2]);
  addToJsonObj("APIKey",process.argv[2]);
}




//Check if the network type: testnet or mainnet was passed in as an argument, if not it defaults to testnet anyway at top of script
if(process.argv[3] === null || process.argv[3] === undefined){
} else {
  network = process.argv[3];
}
 addToJsonObj("Network",network);









(async () => {
  try {
console.log(`## WARNING - PLEASE KEEP MNEMONIC, SEED AND PRIVATE KEY SAFE, DO NOT GIVE IT TO ANYONE! ##`);

    // generate bip39 mnemonic to be stored for recovery of seed
    const mnemonic = cryptoUtils.generateMnemonic();
    console.log(`Mnemonic: ${mnemonic}`);
    addToJsonObj('Mnemonic',mnemonic);


// generate seed from mnemonic
    const seed = await cryptoUtils.generateSeedFromMnemonic(mnemonic);
    console.log(`Seed: ${seed}`);
    addToJsonObj("Seed",seed);

    // ec to be used to sign all messages
    const userKeyPair = new EcKeyPair(seed);

    // user private key
    const userPrivateKey = userKeyPair.getPrivateKey();
    console.log(`Private key: ${userPrivateKey}`);
    addToJsonObj("PrivateKey",userPrivateKey);

    // user public key
    const userHash = userKeyPair.getPublicKey();
    console.log(`User public key: ${userHash}`);
    addToJsonObj("UserPublicKey",userHash);



    try {
      /* check if trust score node has the user public key. Without having trust score, you can receive Coti from other addresses.
           But when you need to spend your coti from your address, trustscore should be previously set for address owner
        */
      const trustScoreResponse = await nodeUtils.getUserTrustScore(userHash, network);
      console.log(`Trust score taken from TS node:`);
      console.log(trustScoreResponse);
    } catch (e) {
      if (e.message === 'User does not exist!') {
        // seeting trust score. Only one time action.
        const trustScoreResponse = await nodeUtils.setTrustScore(apiKey, userHash, network);
        console.log(`Trust score inserted:`);
        console.log(trustScoreResponse);
      }
    }

    const updateUserTypeToFullnode = await nodeUtils.updateUserType(apiKey, userHash, network, 'fullnode');
    console.log(`Update to fullnode response: ${updateUserTypeToFullnode}`);

const dateCreated = new Date().toISOString()
addToJsonObj("dateCreated",dateCreated);

global.jsonObj.push(arrToJson);

let jsondata = JSON.stringify(global.jsonObj, null, 2);

fs.writeFile('keys.json', jsondata, (err) => {
    if (err) throw err;
    console.log('Data written to keys.json');
});





  } catch (e) {
    console.log(e);
  }
})();
