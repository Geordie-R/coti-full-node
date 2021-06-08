//Arguments arriving in to this script
// process.argv[2] is the API Key
// process.argv[3] is the network (mainnet or testnet)
// process.argv[4] is the seed


//NOTE: If generating a complete fresh mneumonic, seed and private key, leave the seed and private key empty.




const { cryptoUtils, EcKeyPair, nodeUtils } = require('@coti-io/crypto');

const fs = require('fs');

// api key that Coti provides, only to be used one time for each seed to insert the public key to the trust score node
global.arrToJson = {};
global.jsonObj = [];
global.apiKey = "";
global.network = "testnet";
global.seed = "";
global.mnemonic = "";

function addToJsonObj(akey,val){
  global.arrToJson[akey] = val;
}



function addAPIKey(apiarg){
  // check if API Key passed in as an argument, if not leave empty
  if(apiarg  === null || apiarg === undefined || apiarg == ""){
    console.log('No API Key passed in to app.js as an argument');
    global.apiKey = "";
   // addToJsonObj("APIKey","");
  } else {
    global.apiKey = apiarg;
    console.log('API Key is ' + apiarg);
   // addToJsonObj("APIKey",apiarg);
  }
}



addAPIKey(process.argv[2]);
addToJsonObj("APIKey",global.apiKey);

// check if API Key passed in as an argument, if not leave empty
//if(process.argv[2] === null || process.argv[2] === undefined){
 // console.log('No API Key passed in to app.js as an argument');
//  addToJsonObj("APIKey","");
//} else {
//  apiKey = process.argv[2];
//  console.log('API Key is ' + process.argv[2]);
//  addToJsonObj("APIKey",process.argv[2]);
//}




function addNetwork(network){
  //Check if the network type: testnet or mainnet was passed in as an argument, if not it defaults to testnet anyway at top of script
  if(!(network === null || network === undefined)){
    global.network = network;
  } else {
    global.network =  "testnet";
  }
//  addToJsonObj("Network",global.network);
}



addNetwork(process.argv[3]);
addToJsonObj("Network",global.network);



function addSeed(seed){
  //Check if the network type: testnet or mainnet was passed in as an argument, if not it defaults to testnet anyway at top of script
  if(!(seed === null || seed === undefined || seed == "")){
    global.seed = seed;
  } else {
    global.seed = "";
  }
//addToJsonObj("Seed",global.seed);
}

addSeed(process.argv[4]);
















(async () => {
  try {
console.log(`## WARNING - PLEASE KEEP MNEMONIC, SEED AND PRIVATE KEY SAFE, DO NOT GIVE IT TO ANYONE! ##`);




let isSeedMissing = (seed === null || seed === undefined || seed == "");


if(isSeedMissing){
  //We need NEW!
  console.log('No seed and private key passed in to app.js as an argument.  Generate fresh!');

  //MNEMONIC
  global.mnemonic = cryptoUtils.generateMnemonic();
  console.log(`Mnemonic: ${mnemonic}`);
  addToJsonObj('Mnemonic',global.mnemonic);

  //SEED
  global.seed = await cryptoUtils.generateSeedFromMnemonic(global.mnemonic);
//  console.log('1Seed: ' + global.seed);
} else {
  //DETAILS WERE PROVIDED - SEED AND/OR PRIVATE KEY WAS NOT EMPTY
  console.log('SEED was provided');
}

console.log('Seed: ' + global.seed);
addToJsonObj('Seed',global.seed);

// ec to be used to sign all messages
const userKeyPair = new EcKeyPair(global.seed);

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
      const trustScoreResponse = await nodeUtils.getUserTrustScore(userHash,global.network);
      console.log(`Trust score taken from TS node:`);
      console.log(trustScoreResponse);
    } catch (e) {
      if (e.message === 'User does not exist!') {
        // seeting trust score. Only one time action.

        const trustScoreResponse = await nodeUtils.setTrustScore(global.apiKey, userHash, global.network);
        console.log(`Trust score inserted:`);
        console.log(trustScoreResponse);
      }
    }

console.log("apiKey" + apiKey + 'userhash ' + userHash + ' network: ' + network);




try{

const updateUserTypeToFullnode = await nodeUtils.updateUserType(global.apiKey, userHash, global.network, 'fullnode');
    console.log(`Update to fullnode response: ${updateUserTypeToFullnode}`);

} catch (e) {
console.log(e);
}

//const updateUserTypeToFullnode = await nodeUtils.updateUserType(global.apiKey, userHash, global.network, 'fullnode');
 //   console.log(`Update to fullnode response: ${updateUserTypeToFullnode}`);
console.log("2");
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
