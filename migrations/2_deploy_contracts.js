const { deployProxy, upgradeProxy } = require("@openzeppelin/truffle-upgrades");

const MyPFPland = artifacts.require("MyPFPland");
const MyPFPlandv2 = artifacts.require("MyPFPlandv2");

module.exports = async function (deployer) {
  // const existing = await deployProxy(MyPFPland, [], { deployer });
  // console.log("Deployed", existing.address);

  const existing = await MyPFPland.deployed();
  const upgraded = await upgradeProxy(existing.address, MyPFPlandv2, {
    deployer,
  });
  console.log("Upgraded", upgraded.address);
};
