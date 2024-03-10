const HDWalletProvider = require('@truffle/hdwallet-provider');
const fs = require('fs');
const path = require('path');
const mnemonic = fs.readFileSync(".secret").toString().trim();
const infura_key = fs.readFileSync(".infura_key").toString().trim();
const etherscan_key = fs.readFileSync(".etherscan_key").toString().trim();

module.exports = {
  contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  networks: {
    ganache: {
      provider: () => new HDWalletProvider(mnemonic, `HTTP://127.0.0.1:7545`), // Default Ganache UI RPC server
      network_id: "*", // Match any network id
      gas: 5500000, // Gas limit, how much gas is allowed for a transaction
      confirmations: 0, // Number of confirmations to wait between deployments
      timeoutBlocks: 20000, // Number of blocks before a deployment times out
      skipDryRun: true, // Skip dry run before migrations? (true for development networks)
      disableConfirmationListener: true,
      timeoutBlocks: 2000,  
      pollingInterval: 1800000,
    },
    sepolia: {
      provider: () => new HDWalletProvider(mnemonic, `https://sepolia.infura.io/v3/${infura_key}`),
      network_id: 11155111,   
      gas: 5500000,        
      confirmations: 1,    
      timeoutBlocks: 2000,  
      pollingInterval: 1800000,
      disableConfirmationListener: true,
      skipDryRun: true     
    }
  },
  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.19",   // Fetch exact version from solc-bin (default: truffle's version)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
       optimizer: {
         enabled: false,
         runs: 1000
       },
       evmVersion: null
     }
   }
 }, 
 plugins : [
  "truffle-plugin-verify"
 ], 
 api_keys: {
  etherscan: etherscan_key
 }
};
