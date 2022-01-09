var SuchWowX = artifacts.require("SuchWowX");

module.exports = function(deployer) {
  let addr;
  if (deployer.network == 'testnet') {
    console.log('[+] Using WOWX testnet address 0xc6B039b1e0be1ba0B433f319898438E782E5dEBA');
    addr = '0xc6B039b1e0be1ba0B433f319898438E782E5dEBA';
  } else {
    console.log('[+] Using WOWX mainnet address 0xba5dc7e77d150816b758e9826fcad2d74820e379');
    addr = '0xba5dc7e77d150816b758e9826fcad2d74820e379';
  }
  deployer.deploy(SuchWowX, addr);
};
