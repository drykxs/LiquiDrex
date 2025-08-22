// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RealTokenMintable is ERC20 {
    address public owner;

    constructor() ERC20("RealToken (Mock CBDC)", "REAL") {
        owner = msg.sender;
        _mint(msg.sender, 1_000_000e18);
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == owner, "not-owner");
        _mint(to, amount);
    }
}
