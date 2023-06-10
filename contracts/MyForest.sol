pragma solidity ^0.8.0;

import "./Tree.sol";
import "./WaterBucket.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyForest{
    Trees _trees;
    WaterBucket _waterbuckets;

    IERC20 _stablecoin;

    uint256 nonce;

    uint256 priceBucket = 1;
    uint256 priceTree = 1;

    address pool;

    constructor (address trees, address waterbuckets, address stabletoken){
        _trees = Trees(trees);
        _waterbuckets = WaterBucket(waterbuckets);
        _stablecoin = IERC20(stabletoken);
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

    function fetchWaterBucket(uint256 wantedBuckets) public {
        uint256 actualBuckets = pseudoRNG() % wantedBuckets;
        _waterbuckets.mint(msg.sender, actualBuckets);
        _stablecoin.transferFrom(msg.sender, address(this), priceBucket * wantedBuckets);// replace with pool address
    }

    function getTree() public {
        uint256 treeType = pseudoRNG() % 3;
        _trees.mintTree(msg.sender, treeType);
        _stablecoin.transferFrom(msg.sender, address(this), priceTree);
    }

    //connect contracts
}