// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
// import {MyOAppRead} from "../src/MyOAppRead.sol";
import {LzReadCounter} from "../src/LzReadCounter.sol";

import {TokenMock} from "../src/TokenMock.sol";
import {NFTMock} from "../src/NFTMock.sol";
import {VaultMock} from "../src/VaultMock.sol";

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

        // OLD OAPP PARAMS
        // vm.envAddress(ARBITRUM_LZ_ENDPOINT), // lzEndpoint
        // vm.envAddress(DEPLOYER_PUBLIC_ADDRESS), // delegate
        // vm.envAddress(DEPLOYER_PUBLIC_ADDRESS) // owner

        // deploy OAPP
        LzReadCounter arbOapp = new LzReadCounter{salt: "elephant"}(
            vm.envAddress(ARBITRUM_LZ_ENDPOINT) // lzEndpoint
        );
        console2.log("LzReadCounter OAPP Address: ", address(arbOapp));

        // deploy TOKEN
        TokenMock arbToken = new TokenMock{salt: "elephant"}();
        console2.log("Token Address: ", address(arbToken));

        // deploy VAULT
        VaultMock arbVault = new VaultMock{salt: "elephant"}(arbToken, "vaultToken", "vTKN");
        console2.log("Vault Address: ", address(arbVault));

        // deploy NFT
        NFTMock arbNft = new NFTMock{salt: "elephant"}();
        console2.log("NFT Address: ", address(arbNft));

        vm.stopBroadcast();
    }
}
