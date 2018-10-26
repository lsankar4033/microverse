var Microverse = artifacts.require("./Microverse.sol");

module.exports = (deployer, network) => {
  // NOTE: Constructor arg here determines which contract stage to start in
  deployer.deploy(Microverse, 1);
};
