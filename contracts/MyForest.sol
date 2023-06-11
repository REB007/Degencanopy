pragma solidity ^0.8.0;

import "./Tree.sol";
import "./WaterBucket.sol";
import "./ACT.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyForest{
    Trees _trees;
    WaterBucket _waterbuckets;
    ACT _act;
    IERC20 _stablecoin;

    address _actAddress;
    address _poolAddress;

    uint256 nonce;

    uint256 priceBucket = 0.10 * 10 ** 18;
    uint256 priceTree = 5 * 10 ** 18;

    address pool;

    constructor (address trees, address waterbuckets, address stabletoken, address act){
        _trees = Trees(trees);
        _waterbuckets = WaterBucket(waterbuckets);
        _stablecoin = IERC20(stabletoken);
        _act = ACT(act);
        nonce = 0;
    }

    function pseudoRNG() public returns(uint256) {
        nonce++;
        return uint256(keccak256(abi.encodePacked(nonce, msg.sender, blockhash(block.number - 1))));
    }

    function waterTree(uint256 treeId, uint256 buckets) public {
        _waterbuckets.use(msg.sender, buckets);
        _trees.waterTree(treeId, buckets);
    }

    function handlePaymentDistrib(uint256 payment) internal {
        _stablecoin.transferFrom(msg.sender, address(this), payment);
        uint256 half = payment / 2;
        _stablecoin.transfer(_poolAddress, half);
        _stablecoin.transfer(_actAddress, half);
        _act.swapUSDC_BCT(half);
        _act.redeemAndOffset(half);
    }

    function fetchWaterBucket(uint256 wantedBuckets) public {
        uint256 actualBuckets = pseudoRNG() % wantedBuckets;
        _waterbuckets.mint(msg.sender, actualBuckets);
        handlePaymentDistrib(priceBucket * wantedBuckets);
    }

    function getTree() public {
        uint256 treeType = pseudoRNG() % 3;
        _trees.mintTree(msg.sender, treeType);
        handlePaymentDistrib(priceTree);
    }
}