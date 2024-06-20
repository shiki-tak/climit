// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CPToken is ERC20 {
    constructor() ERC20("ClimbPointToken", "CPT") {}

    function mint(address account, uint256 value) public {
        _mint(account, value);
    }
}
