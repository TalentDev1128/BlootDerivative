const { deployProxy, upgradeProxy } = require("@openzeppelin/truffle-upgrades");

const MyPFPland = artifacts.require("MyPFPland");
const MyPFPlandv2 = artifacts.require("MyPFPlandv2");

describe("deploy", () => {
  it("works", async () => {
    const myPFPlandv2 = await deployProxy(MyPFPlandv2, []);
    // const myPFPlandv2 = await upgradeProxy(MyPFPlandv2.address, MyPFPlandv2);
    let estimatedGas;
    await myPFPlandv2.setBatchCollectionRect(
      [0],
      [0],
      [10],
      [11],
      ["0xbA8886bf3a6f0740e622AF240c54c9A6439DE0bE"],
      1
    );
    await myPFPlandv2.setBatchMekakeyWhitelist(
      [
        "0xe81C32a1c8c5b3f50CC75eFf170CA3D0cC171BF8",
        "0xe81C32a1c8c5b3f50CC75eFf170CA3D0cC171BF8",
      ],
      1
    );

    estimatedGas = await myPFPlandv2.setBatchCollectionRect.estimateGas(
      [0],
      [0],
      [10],
      [11],
      ["0x287be825bCeCeD75C2AbbD313efe0E1DcB8C260a"],
      1
    );
    console.log(
      "setBatchCollectionRect === ",
      (estimatedGas * 100000000000) / 1000000000000000000
    );

    estimatedGas = await myPFPlandv2.claimLand.estimateGas(1, 1, 0, {
      value: 30000000000000000,
      from: "0xe81C32a1c8c5b3f50CC75eFf170CA3D0cC171BF8",
    });
    console.log(
      "claimLand === ",
      (estimatedGas * 100000000000) / 1000000000000000000
    );

    estimatedGas = await myPFPlandv2.setPauseClaimingToy.estimateGas(true);
    console.log(
      "setPauseClaimingToy === ",
      (estimatedGas * 100000000000) / 1000000000000000000
    );

    estimatedGas = await myPFPlandv2.updateLandRoyalMetaData.estimateGas(
      1,
      1,
      0,
      0
    );
    console.log(
      "updateLandRoyalMetaData === ",
      (estimatedGas * 100000000000) / 1000000000000000000
    );
  });
});
