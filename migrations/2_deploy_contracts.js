const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades');

const BlootDerivative = artifacts.require('BlootDerivative');
// const BlootDerivative1 = artifacts.require('BlootDerivative1');

module.exports = async function (deployer) {
  const existing = await deployProxy(BlootDerivative, [], { deployer });
  console.log("Deployed", existing.address);

  // const existing = await BlootDerivative.deployed();
  // const upgraded = await upgradeProxy(existing.address, BlootDerivative1, { deployer });
  // console.log("Upgraded", upgraded.address);
}