// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "lib/forge-std/src/Script.sol";
// import {MyOAppRead} from "../src/MyOAppRead.sol";
import {LzReadCounter} from "../src/LzReadCounter.sol";

contract DeployToBase is Script {
    function run() external {
        // ===================
        // === SCRIPT VARS ===
        // ===================

        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        string memory BASE_LZ_ENDPOINT = "BASE_SEPOLIA_LZ_ENDPOINT";
        string memory DEPLOYER_PUBLIC_ADDRESS = "DEPLOYER_PUBLIC_ADDRESS";

        // ========================
        // === BASE DEPLOYMENTS ===
        // ========================

        console2.log("#######################################");
        console2.log("########## Deploying to Base ##########");
        console2.log("#######################################");

        vm.createSelectFork("base");

        vm.startBroadcast(deployerPrivateKey);

        // deploy OAPP
        LzReadCounter baseOapp = new LzReadCounter{salt: "goat"}(
            vm.envAddress(BASE_LZ_ENDPOINT), // lzEndpoint
            vm.envAddress(DEPLOYER_PUBLIC_ADDRESS) // owner
        );
        console2.log("LzReadCounter OAPP Address: ", address(baseOapp));

        vm.stopBroadcast();
    }
}
