// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Mypfphub is ERC1155, Ownable, ERC1155Supply {
    // Token Categories
    uint256 public constant BACKGROUNDS = 0;
    uint256 public constant FRAMES = 1;
    uint256 public constant OVERLAYS = 2;
    uint256 public constant DECORATIONS = 3;
    
    // Pricing and limits
    mapping(uint256 => uint256) public mintPrices;
    mapping(uint256 => uint256) public maxSupply;
    
    // Platform integration mappings
    mapping(address => mapping(string => uint256[])) public userProfiles; // user -> platform -> tokenIds
    
    // Metadata URI management
    mapping(uint256 => string) private _uris;
    
    // Events
    event ProfileUpdated(address indexed user, string platform, uint256[] tokenIds);
    event PriceUpdated(uint256 indexed tokenId, uint256 price);
    
    constructor(address initialOwner) 
        ERC1155("ipfs://{id}.json") 
        Ownable(initialOwner) 
    {
        // Set initial max supply limits
        maxSupply[BACKGROUNDS] = 1000;
        maxSupply[FRAMES] = 5000;
        maxSupply[OVERLAYS] = 10000;
        maxSupply[DECORATIONS] = 2000;
        
        // Set initial prices (in wei)
        mintPrices[BACKGROUNDS] = 0.1 ether;
        mintPrices[FRAMES] = 0.05 ether;
        mintPrices[OVERLAYS] = 0.03 ether;
        mintPrices[DECORATIONS] = 0.08 ether;
    }

    // Public minting function with payment
    function mint(uint256 tokenId, uint256 amount) public payable {
        require(msg.value >= mintPrices[tokenId] * amount, "Insufficient payment");
        require(totalSupply(tokenId) + amount <= maxSupply[tokenId], "Exceeds max supply");
        
        _mint(msg.sender, tokenId, amount, "");
    }

    // Update user's profile for a specific platform
    function updateProfile(string memory platform, uint256[] memory tokenIds) public {
        require(tokenIds.length <= 4, "Too many items"); // Max 4 items per profile
        
        // Verify ownership of all tokens
        for(uint i = 0; i < tokenIds.length; i++) {
            require(balanceOf(msg.sender, tokenIds[i]) > 0, "Must own all tokens");
        }
        
        userProfiles[msg.sender][platform] = tokenIds;
        emit ProfileUpdated(msg.sender, platform, tokenIds);
    }

    // Owner functions
    function setMintPrice(uint256 tokenId, uint256 price) public onlyOwner {
        mintPrices[tokenId] = price;
        emit PriceUpdated(tokenId, price);
    }

    function setMaxSupply(uint256 tokenId, uint256 supply) public onlyOwner {
        require(supply >= totalSupply(tokenId), "Cannot set below current supply");
        maxSupply[tokenId] = supply;
    }

    // URI management
    function uri(uint256 tokenId) public view override returns (string memory) {
        if (bytes(_uris[tokenId]).length > 0) {
            return _uris[tokenId];
        }
        return super.uri(tokenId);
    }

    function setTokenUri(uint256 tokenId, string memory tokenUri) public onlyOwner {
        _uris[tokenId] = tokenUri;
    }

    // Override required by Solidity
    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }
}