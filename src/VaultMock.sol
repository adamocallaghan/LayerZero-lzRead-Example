// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC4626} from "lib/solmate/src/tokens/ERC4626.sol";
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";

contract VaultMock is ERC4626 {
    constructor(ERC20 _asset, string memory _name, string memory _symbol) ERC4626(_asset, _name, _symbol) {}

    function _deposit(uint256 _assets) public {
        require(_assets > 0, "Zero assets deposited");
        deposit(_assets, msg.sender);
    }

    function _withdraw(uint256 _shares) public {
        // checks
        require(_shares > 0, "Zero shares sent to withdraw against");

        // interactions
        redeem(_shares, msg.sender, msg.sender);
    }

    function totalAssets() public view override returns (uint256) {
        return asset.balanceOf(address(this));
    }

    function totalSharesOfUser(address _user) public view returns (uint256) {
        return this.balanceOf(_user);
    }
}
