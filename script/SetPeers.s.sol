// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {MyOAppRead} from "../src/MyOAppRead.sol";

interface IVault {
    function setPeer(uint32, bytes32) external;
    function setToken(address) external;
}

interface IToken {
    function setPeer(uint32, bytes32) external;
}

contract SetPeers is Script {
    function run() external {
        // ===================
        // === SCRIPT VARS ===
        // ===================

        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        // Oapp Bytes32 format Address (Same address all chains)
        bytes32 OAPP_BYTES32 = 0x000000000000000000000000DC2586e87a02866C385bd42260AC943A8848E69B;
        // Oapp Address (same address all chains)
        address OAPP_ADDRESS = vm.envAddress("OAPP_ADDRESS");
        // Oft Bytes32 format Address (same address all chains)
        bytes32 OFT_BYTES32 = 0x0000000000000000000000006DB68F8c5eCfaDb33478076D14D18593ff4d3302;
        // Oapp Address (same address all chains)
        address OFT_ADDRESS = vm.envAddress("OFT_ADDRESS");

        // === BASE ===
        uint256 baseLzEndIdUint = vm.envUint("BASE_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 BASE_SEPOLIA_LZ_ENDPOINT_ID = uint32(baseLzEndIdUint);

        // === ARBIRTUM ===
        uint256 arbLzEndIdUint = vm.envUint("ARBITRUM_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 ARBITRUM_SEPOLIA_LZ_ENDPOINT_ID = uint32(arbLzEndIdUint);

        // ====================
        // === BASE WIRE-UP ===
        // ====================

        console2.log("########################################");
        console2.log("########## Setting Base Peers ##########");
        console2.log("########################################");
        console2.log("                                        ");
        console2.log("Setting Base Oapp Peer at: ", OAPP_ADDRESS);

        vm.createSelectFork("base");

        vm.startBroadcast(deployerPrivateKey);

        // StableEngine Wire-Ups
        IVault(OAPP_ADDRESS).setPeer(ARBITRUM_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);

        // StableCoin Wire-Ups
        IToken(OFT_ADDRESS).setPeer(ARBITRUM_SEPOLIA_LZ_ENDPOINT_ID, OFT_BYTES32);

        // set the Token address on the Vault contract
        IVault(OAPP_ADDRESS).setToken(OFT_ADDRESS);

        vm.stopBroadcast();

        // ========================
        // === ARBITRUM WIRE-UP ===
        // ========================

        console2.log("############################################");
        console2.log("########## Setting Arbitrum Peers ##########");
        console2.log("############################################");
        console2.log("                                            ");
        console2.log("Setting Arbirtum Oapp Peer at: ", OAPP_ADDRESS);

        vm.createSelectFork("arbitrum");

        vm.startBroadcast(deployerPrivateKey);

        // StableEngine Wire-Ups
        IVault(OAPP_ADDRESS).setPeer(BASE_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);

        // StableCoin Wire-Ups
        IToken(OFT_ADDRESS).setPeer(BASE_SEPOLIA_LZ_ENDPOINT_ID, OFT_BYTES32);

        // set the Token address on the Vault contract
        IVault(OAPP_ADDRESS).setToken(OFT_ADDRESS);

        vm.stopBroadcast();
    }
}
