const Trees = artifacts.require("Trees");
const WaterBucket = artifacts.require("WaterBucket");
const LotteryPool = artifacts.require("LotteryPool");
const MyForest = artifacts.require("MyForest");

require('dotenv').config();
const StableCoin = process.env.STABLECOIN;

module.exports = deployer => {
  deployer.then(async () => {
    await deployer.deploy(Trees, "TREE", "TREE");
    const TreesInstance = await Trees.deployed();
    console.log(`Trees: Trees deployed at ${Trees.address}.`);
    
    await deployer.deploy(WaterBucket, "WATER_BUCKET, WTRBKT");
    const WaterBucketInstance = await WaterBucket.deployed();
    console.log(`WaterBucket: WaterBucket deployed at ${WaterBucket.address}.`);

    await deployer.deploy(MyForest, WaterBucket.address, Trees.address, StableCoin);
    console.log(`MyForest: MyForest deployed at ${MyForest.address}.`);

    await deployer.deploy(LotteryPool, Trees.address, StableCoin);
    console.log(`Kidnap: Market deployed at ${LotteryPool.address}.`);

    await TreesInstance.setForest(MyForest.address);
    await WaterBucketInstance.setForest(MyForest.address);

    console.log(`Tree: Migration completed!`);
  });
};