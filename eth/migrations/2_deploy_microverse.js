var Microverse = artifacts.require("./Microverse.sol");

module.exports = (deployer, network) => {
  deployer.deploy(Microverse);
};
