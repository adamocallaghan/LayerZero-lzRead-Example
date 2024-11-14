// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";

contract envBytes32 is Script {
    function run() external {
        // Oapp Bytes32 format Address (Same address all chains)
        // bytes32 OAPP_BYTES32 = 0x000000000000000000000000DC2586e87a02866C385bd42260AC943A8848E69B;
        bytes32 OAPP_BYTES32 = vm.envBytes32("OAPP_BYTES32");
        console2.log("OAPP Bytes32 Address: ");
        console2.logBytes32(OAPP_BYTES32);
    }
}
