pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Trees is ERC721, Ownable{
    enum TreeType{
        red, blue, green
    }

    struct Tree {
        uint256 height; // = level
        TreeType treeType;
        uint256 bucketsUntilNextHeight;
    }

    mapping(uint256 => Tree) _treeIdToTree;
    uint256 _tokenCount;

    address _forest;

    constructor(
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {
        _tokenCount = 0;
        _forest = address(0);
    }

    function setForest(address forest) public {
        _forest = forest;
        renounceOwnership();
    }

    function getTree(uint256 tokenId) public view returns(Tree memory) {
        return _treeIdToTree[tokenId];
    }

    function mintTree(address to, uint256 treeType) public {
        require(_msgSender() == _forest, "Only forest contract is allowed to mint");
        _mint(to, _tokenCount++);
        _treeIdToTree[_tokenCount] = Tree(1, TreeType(treeType),1);
    }

    function waterTree(uint256 treeId, uint256 amountOfBuckets) public{
        require(_msgSender() == _forest, "Only forest contract is allowed to water");
        Tree memory tree = _treeIdToTree[treeId];
        if(tree.bucketsUntilNextHeight > amountOfBuckets) {
           tree.bucketsUntilNextHeight -= amountOfBuckets;
        }
        else{
            tree.height++; // lvl up
            tree.bucketsUntilNextHeight = tree.height + tree.bucketsUntilNextHeight - amountOfBuckets;
        }
        _treeIdToTree[treeId] = tree;
    }

    function treeToLotteryTickets(uint256 treeId) public view returns(uint256){
        return _treeIdToTree[treeId].height;
    }
}