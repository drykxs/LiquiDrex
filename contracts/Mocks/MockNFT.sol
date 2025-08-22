// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockNFT is ERC721 {
    uint256 public nextId;
    address public owner;

    constructor() ERC721("Mock Collateral NFT", "mNFT") {
        owner = msg.sender;
    }

    function mint(address to) external returns (uint256 id) {
        require(msg.sender == owner, "not-owner");
        id = nextId++;
        _mint(to, id);
    }
}
