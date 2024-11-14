// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {MyOAppRead} from "../src/MyOAppRead.sol";
import {NFTMock} from "../src/NFTMock.sol";

contract DeployToArbitrum is Script {
    function run() external {
        // ===================
        // === SCRIPT VARS ===
        // ===================

        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        string memory ARBITRUM_LZ_ENDPOINT = "ARBITRUM_SEPOLIA_LZ_ENDPOINT";
        string memory DEPLOYER_PUBLIC_ADDRESS = "DEPLOYER_PUBLIC_ADDRESS";

        // ============================
        // === ARBITRUM DEPLOYMENTS ===
        // ============================

        console2.log("###########################################");
        console2.log("########## Deploying to Arbitrum ##########");
        console2.log("###########################################");

        vm.createSelectFork("arbitrum");

        vm.startBroadcast(deployerPrivateKey);

        // deploy OAPP
        MyOAppRead arbOapp =
            new MyOAppRead{salt: "xyz"}(vm.envAddress(ARBITRUM_LZ_ENDPOINT), vm.envAddress(DEPLOYER_PUBLIC_ADDRESS));
        console2.log("MyOAppRead OAPP Address: ", address(arbOapp));

        // deploy NFT
        NFTMock arbNft = new NFTMock{salt: "xyz"}();
        console2.log("NFT Address: ", address(arbNft));

        vm.stopBroadcast();
    }
}
