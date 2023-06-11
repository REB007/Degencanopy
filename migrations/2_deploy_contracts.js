const Trees = artifacts.require("Trees");
const WaterBucket = artifacts.require("WaterBucket");
const LotteryPool = artifacts.require("LotteryPool");
const MyForest = artifacts.require("MyForest");
const ACT = artifacts.require("ACT");

require('dotenv').config();
const USDC = process.env.USDC;
const BCT = process.env.BCT;
const UNISAP_PAIR = process.env.UNISAP_PAIR;
const ROOTER = process.env.ROOTER;

module.exports = deployer => {
  deployer.then(async () => {
    await deployer.deploy(Trees, "TREE", "TREE");
    const TreesInstance = await Trees.deployed();
    console.log(`DegenCanopy: Trees deployed at ${Trees.address}.`);
    
    await deployer.deploy(WaterBucket, "WATER_BUCKET, WTRBKT");
    const WaterBucketInstance = await WaterBucket.deployed();
    console.log(`DegenCanopy: WaterBucket deployed at ${WaterBucket.address}.`);

    await deployer.deploy(ACT, UNISAP_PAIR, ROOTER, USDC, BCT);

    await deployer.deploy(MyForest, WaterBucket.address, Trees.address, USDC, ACT.address);
    console.log(`DegenCanopy: MyForest deployed at ${MyForest.address}.`);

    await deployer.deploy(LotteryPool, Trees.address, StableCoin);
    console.log(`DegenCanopy: Market deployed at ${LotteryPool.address}.`);

    await TreesInstance.setForest(MyForest.address);
    await WaterBucketInstance.setForest(MyForest.address);

    console.log(`DegenCanopy: Migration completed!`);
  });
};