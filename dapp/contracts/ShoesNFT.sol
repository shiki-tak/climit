// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function mint(address to, uint256 amount) external;
}

contract ShoesNFT is ERC721, Ownable {
    IERC20 public CpToken;
    uint256 private _tokenIdCounter;

    enum Model { Low, Middle, Hight }
    struct Shoes {
        string name;
        uint256 durability;
        Model model;
    }

    Shoes[] public shoesList;

    mapping(uint256 => uint256) public shoesPrices;

    constructor(address beneficiary, address cptContractAddress) ERC721("NFT", "M721") Ownable(beneficiary) {
        CpToken = IERC20(cptContractAddress);
    }

      function _baseURI() internal view virtual override returns (string memory) {
        return "ipfs://XXX/";
    }

    // mint nft only smart contract operator
    function mint(uint256 price, string memory name, uint256 durability, Model model) public onlyOwner {
        uint256 tokenId = _tokenIdCounter;

        shoesList.push(Shoes(name, durability, model));

        _mint(address(this), tokenId);
        shoesPrices[tokenId] = price;
        _tokenIdCounter +=1;
    }

    // transfer from contract to user
    function buy(uint256 tokenId) public payable {
        address owner = _requireOwned(tokenId);
        uint256 price = shoesPrices[tokenId];
        require(msg.value >= price, "Insufficient funds");
        _safeTransfer(owner, msg.sender, tokenId);

        shoesPrices[tokenId] = 0;
    }

    // transfer between users
    function trade(uint256 tokenId) public payable  {
        address owner = _requireOwned(tokenId);
        uint256 price = shoesPrices[tokenId];
        require(msg.value >= price, "Insufficient funds");
        payable(owner).transfer(msg.value);
        safeTransferFrom(owner, msg.sender, tokenId);

        shoesPrices[tokenId] = 0;
    }

    // Reduces the durability of shoes depending on the height climbed.
    // Give tokens according to altitude.
    function climb(uint256 tokenId, uint256 altitudeDifference) public {
        address owner = _requireOwned(tokenId);
        require(owner == msg.sender);
         Shoes storage s = shoesList[tokenId];
         require(s.durability != 0);
         uint256 reward = 0;
         uint256 consume = 0;
         // TODO
         if (s.model == Model.Low) {
            // TODO
            reward = altitudeDifference;
            consume = 10;
         } else if (s.model == Model.Middle) {
            reward = altitudeDifference + 10;
            consume = 7;
         } else {
            reward = altitudeDifference + 20;
            consume = 3;
         }
         
         s.durability = s.durability - consume;

         shoesList[tokenId] = s;

        // TODO: call token contract
        CpToken.mint(msg.sender, reward * 10 **18);
    }

    function setPrice(uint256 tokenId, uint256 price) public {
         _requireOwned(tokenId);
        shoesPrices[tokenId] = price;
    }

    function getShoesInfo(uint256 tokenId) public view returns (string memory, uint256, string memory) {
        require(tokenId < shoesList.length, "tokenId not found");
        Shoes storage s = shoesList[tokenId];

        return (s.name, s.durability, modelToString(s.model));
    }

    function getAllShoes() public view returns (Shoes[] memory) {
        return shoesList;
    }

    function modelToString(Model _model) internal pure returns (string memory) {
        if (_model == Model.Low) {
            return "Low";
        } else if (_model == Model.Middle) {
            return "Middle";
        } else {
            return "Hight";
        }
    }
}
