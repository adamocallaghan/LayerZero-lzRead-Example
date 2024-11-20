// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
// import {MyOAppRead} from "../src/MyOAppRead.sol";
import {LzReadCounter} from "../src/LzReadCounter.sol";
import {
    ILayerZeroEndpointV2,
    MessagingFee,
    MessagingReceipt,
    Origin
} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {OAppRead} from "@layerzerolabs/oapp-evm/contracts/oapp/OAppRead.sol";

interface IMyOAppRead {
    function setPeer(uint32, bytes32) external;
}

contract SetPeers is Script {
    function run() external {
        // ===================
        // === SCRIPT VARS ===
        // ===================

        uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        // Oapp Bytes32 format Address (Same address all chains)
        // bytes32 OAPP_BYTES32 = 0x000000000000000000000000DC2586e87a02866C385bd42260AC943A8848E69B;
        bytes32 OAPP_BYTES32 = vm.envBytes32("OAPP_BYTES32");
        // Oapp Address (same address all chains)
        address OAPP_ADDRESS = vm.envAddress("OAPP_ADDRESS");

        // === BASE ===
        uint256 baseLzEndIdUint = vm.envUint("BASE_SEPOLIA_LZ_ENDPOINT_ID");
        uint32 BASE_SEPOLIA_LZ_ENDPOINT_ID = uint32(baseLzEndIdUint);

        // === BASE LZ-ENDPOINT ===
        address baseLzEndpoint = vm.envAddress("BASE_SEPOLIA_LZ_ENDPOINT");
        // uint32 BASE_SEPOLIA_LZ_ENDPOINT = uint32(baseLzEndpoint);

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

        // OAPP Wire-Ups
        IMyOAppRead(OAPP_ADDRESS).setPeer(ARBITRUM_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);

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

        // OAPP Wire-Ups
        IMyOAppRead(OAPP_ADDRESS).setPeer(BASE_SEPOLIA_LZ_ENDPOINT_ID, OAPP_BYTES32);

        vm.stopBroadcast();

        // ========================
        // === SET READ LIBRARY ===
        // ========================

        // Initialize the endpoint contract
        ILayerZeroEndpointV2 endpoint = ILayerZeroEndpointV2(baseLzEndpoint);
        address _readLib = 0x54320b901FDe49Ba98de821Ccf374BA4358a8bf6;

        vm.createSelectFork("base");

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Set the send library
        endpoint.setSendLibrary(OAPP_ADDRESS, BASE_SEPOLIA_LZ_ENDPOINT_ID, _readLib);
        console2.log("Send library set to Read Lib.");

        // Set the receive library
        endpoint.setReceiveLibrary(OAPP_ADDRESS, BASE_SEPOLIA_LZ_ENDPOINT_ID, _readLib, 0);
        console2.log("Receive library set to Read Lib.");

        // Set the config
        // endpoint.setConfig();

        // Set the channelId
        OAppRead(OAPP_ADDRESS).setReadChannel(4294967294, true);

        vm.stopBroadcast();
    }
}
