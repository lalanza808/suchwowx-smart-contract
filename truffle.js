require('dotenv').config();
const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  networks: {
    local: {
     host: "127.0.0.1",
     port: 8545,
     network_id: "*",
    },
    testnet: {
      provider: () => new HDWalletProvider({
        mnemonic: process.env.MNEMONIC,
        providerOrUrl: "https://api.avax-test.network/ext/bc/C/rpc",
        chainId: '43113',
        addressIndex: 0
      }),
      network_id: "*",
      confirmations: 1,
      timeoutBlocks: 10,
      skipDryRun: true,
      production: false,
    },
    mainnet: {
      provider: () => new HDWalletProvider({
        mnemonic: process.env.MNEMONIC,
        providerOrUrl: "https://api.avax.network/ext/bc/C/rpc",
        chainId: '43114',
        addressIndex: 0
      }),
      network_id: "*",
      confirmations: 3,
      timeoutBlocks: 30,
      skipDryRun: false,
      production: true,
    },
  },
  compilers: {
    solc: {
      version: "^0.8.0",
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  },
  plugins: [
    'truffle-plugin-verify'
  ],
  api_keys: {
    'snowtrace': process.env.SNOWTRACE_API
  }
};
