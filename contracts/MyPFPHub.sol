// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Mypfphub is ERC1155, Ownable, ERC1155Supply {
    // Token IDs
    uint256 public constant FRAMES = 0;
    uint256 public constant OVERLAYS = 1;
    uint256 public constant DECORATIONS = 2;

    // Mapping for custom URIs
    mapping(uint256 => string) private _uris;

    // Constructor sets base URI and ownership
    constructor(address initialOwner) 
        ERC1155("https://game.example/api/item/{id}.json") 
        Ownable(initialOwner) 
    {
        // Mint initial supply
        _mint(initialOwner, FRAMES, 10 ** 18, "");
        _mint(initialOwner, OVERLAYS, 10 ** 27, "");
        _mint(initialOwner, DECORATIONS, 1, "");
    }

    // Custom URI getter
    function uri(uint256 tokenId) public view override returns (string memory) {
        if (bytes(_uris[tokenId]).length > 0) {
            return _uris[tokenId];
        }
        return super.uri(tokenId);
    }

    // Custom URI setter, one-time only
    function setTokenUri(uint256 tokenId, string memory tokenUri) public onlyOwner {
        require(bytes(_uris[tokenId]).length == 0, "Cannot set URI twice");
        _uris[tokenId] = tokenUri;
    }

    // Minting functions restricted to the owner
    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyOwner
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }
}