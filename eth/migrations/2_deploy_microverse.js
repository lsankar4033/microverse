var Microverse = artifacts.require("./Microverse.sol");

var TestAuction = artifacts.require("./test/TestAuction.sol");
var TestGameRounds = artifacts.require("./test/TestGameRounds.sol");

module.exports = (deployer, network) => {
  // NOTE: Constructor arg here determines which contract stage to start in
  deployer.deploy(Microverse, 0);

  if (network == "development") {
    deployer.deploy(TestAuction);
    deployer.deploy(TestGameRounds);
  }
};
