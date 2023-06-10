pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WaterBucket is ERC20, Ownable{
    address _forest;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _forest = address(0);
    }

    function setForest(address forest) public {
        _forest = forest;
        renounceOwnership();
    }

    function mint(address to, uint256 amount) public{
        require(_msgSender() == _forest, "Only forest contract is allowed to mint buckets");
        _mint(to, amount);
    }

    function use(address to, uint256 amount) public {
        require(_msgSender() == _forest, "Only forest contract is allowed to use buckets");
        _burn(to, amount);
    }
}