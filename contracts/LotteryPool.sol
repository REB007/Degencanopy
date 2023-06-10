pragma solidity ^0.8.0;

import "./Tree.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LotteryPool {
    Trees _trees;
    IERC20 _stablecoin;

    struct ClaimLottery{
        address winner;
        uint256 value;
        bool reedemed;
        uint256 deadline;
    }

    mapping(uint256 => uint256) _lotteryTickets;
    uint256 _lotteryTicketCount;

    address _curentWeekLotteryWinner;
    bool _winnerClaimedLotteryGains;

    ClaimLottery winnerInfos;

    uint256 nonce;

    constructor (address trees, address stablecoin){
        _trees = Trees(trees);
        _stablecoin = IERC20(stablecoin);
    }

    function pseudoRNG() public returns(uint256) {
        nonce++;
        return uint256(keccak256(abi.encodePacked(nonce, msg.sender, blockhash(block.number - 1))));
    }

    function getDayOfWeek() public view returns (uint8) {
        return uint8((block.timestamp / 86400 + 4) % 7);  
    }

    function winner() public view returns(address){
        return _curentWeekLotteryWinner;
    }

    function enlistToLottery(uint256 treeTokenId) public{
        require(_trees.ownerOf(treeTokenId) == msg.sender, ""); //write message
        uint256 ticketCount = _trees.treeToLotteryTickets(treeTokenId);
        for(uint256 i = _lotteryTicketCount; i < _lotteryTicketCount + ticketCount; i++){
            _lotteryTickets[i] = treeTokenId;
        }
        _lotteryTicketCount += ticketCount;
    }

    function triggerLotterie() public {
        require(winnerInfos.deadline < block.timestamp, "Last Lottery still need to be redeemed");
        require(getDayOfWeek() == 7, "Lottery can only be triggered on Sunday UTC");
        uint256 rng = pseudoRNG();
        uint256 lotteryWinner = rng % _lotteryTicketCount;

        winnerInfos.winner = _trees.ownerOf(_lotteryTickets[lotteryWinner]);
        winnerInfos.value = (5 + rng % 10) / 100 * _stablecoin.balanceOf(address(0));
        winnerInfos.reedemed = false;
        winnerInfos.deadline = block.timestamp + 2 days;
    }

    function claimLottery() public{
        require(winnerInfos.deadline < block.timestamp,"");
        require(msg.sender == winnerInfos.winner,"");
        require(!winnerInfos.reedemed,"");

        winnerInfos.reedemed = true;
        _stablecoin.transfer(msg.sender, winnerInfos.value);
    }
} 