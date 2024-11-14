// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";

contract TokenMock is ERC20 {
    constructor() ERC20("MyToken", "MTKN", 18) {}

    function mint(address recipient, uint256 amount) external {
        _mint(recipient, amount);
    }
}
