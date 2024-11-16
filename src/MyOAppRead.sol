// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OAppRead} from "@layerzerolabs/oapp-evm/contracts/oapp/OAppRead.sol";
import {OApp, Origin, MessagingFee, MessagingReceipt} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {
    ILayerZeroEndpointV2,
    MessagingFee,
    MessagingReceipt,
    Origin
} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {
    ReadCmdCodecV1,
    EVMCallComputeV1,
    EVMCallRequestV1
} from "lib/layerzero-v2/packages/layerzero-v2/evm/oapp/contracts/oapp/libs/ReadCmdCodecV1.sol";
import {OptionsBuilder} from "lib/layerzero-v2/packages/layerzero-v2/evm/oapp/contracts/oapp/libs/OptionsBuilder.sol";
import {
    IOAppOptionsType3,
    EnforcedOptionParam
} from "lib/layerzero-v2/packages/layerzero-v2/evm/oapp/contracts/oapp/libs/OAppOptionsType3.sol";

/// @title OAppRead
/// @notice An example contract that extends OApRead to handle both messaging and read capabilities.
/// @dev Inherits from OApp and adds functionality specific to lzRead.
contract MyOAppRead is OAppRead {
    /// lzRead responses are sent from arbitrary channels with Endpoint IDs in the range of
    /// `eid > 4294965694` (which is `type(uint32).max - 1600`).
    uint32 constant READ_CHANNEL_EID_THRESHOLD = 4294965694;
    uint32 constant READ_CHANNEL = 4294967295; // the Read Data Path Channel ID for both Base Sepolia & Arb Sepolia

    /// @param _endpoint The address of the LayerZero endpoint.
    /// @param _delegate The address of the delegate contract.
    constructor(address _endpoint, address _delegate, address _owner) OAppRead(_endpoint, _delegate) {
        transferOwnership(_owner);
    }
    /**
     * @notice Sends a read request to LayerZero, querying Uniswap QuoterV2 for WETH/USDC prices on configured chains.
     * @param _extraOptions Additional messaging options, including gas and fee settings.
     * @return receipt The LayerZero messaging receipt for the request.
     */

    function readAverageUniswapPrice(bytes calldata _extraOptions)
        external
        payable
        returns (MessagingReceipt memory receipt)
    {
        bytes memory extraOptions =
            OptionsBuilder.newOptions().addExecutorNativeDropOption(nativeDropGas, addressToBytes32(user));

        bytes memory cmd = getCmd();
        return _lzSend(
            READ_CHANNEL,
            cmd,
            combineOptions(READ_CHANNEL, READ_MSG_TYPE, _extraOptions),
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
    }

    /**
     * @notice Constructs a command to query the Uniswap QuoterV2 for WETH/USDC prices on all configured chains.
     * @return cmd The encoded command to request Uniswap quotes.
     */
    function getCmd() public view returns (bytes memory) {
        uint256 pairCount = targetEids.length;
        EVMCallRequestV1[] memory readRequests = new EVMCallRequestV1[](pairCount);

        for (uint256 i = 0; i < pairCount; i++) {
            uint32 targetEid = targetEids[i];
            ChainConfig memory config = chainConfigs[targetEid];

            // Define the QuoteExactInputSingleParams
            IQuoterV2.QuoteExactInputSingleParams memory params = IQuoterV2.QuoteExactInputSingleParams({
                tokenIn: config.tokenInAddress,
                tokenOut: config.tokenOutAddress,
                amountIn: 1 ether, // amountIn: 1 WETH
                fee: config.fee,
                sqrtPriceLimitX96: 0 // No price limit
            });

            // @notice Encode the function call
            // @dev From Uniswap Docs, this function is not marked view because it relies on calling non-view
            // functions and reverting to compute the result. It is also not gas efficient and should not
            // be called on-chain. We take advantage of lzRead to call this function off-chain and get the result
            // returned back on-chain to the OApp's _lzReceive method.
            // https://docs.uniswap.org/contracts/v3/reference/periphery/interfaces/IQuoterV2
            bytes memory callData = abi.encodeWithSelector(IQuoterV2.quoteExactInputSingle.selector, params);

            readRequests[i] = EVMCallRequestV1({
                appRequestLabel: uint16(i + 1),
                targetEid: targetEid,
                isBlockNum: false,
                blockNumOrTimestamp: uint64(block.timestamp),
                confirmations: config.confirmations,
                to: config.quoterAddress,
                callData: callData
            });
        }

        EVMCallComputeV1 memory computeSettings = EVMCallComputeV1({
            computeSetting: 2, // lzMap() and lzReduce()
            targetEid: ILayerZeroEndpointV2(endpoint).eid(),
            isBlockNum: false,
            blockNumOrTimestamp: uint64(block.timestamp),
            confirmations: 15,
            to: address(this)
        });

        return ReadCodecV1.encode(0, readRequests, computeSettings);
    }
    /// @notice Internal function to handle incoming messages and read responses.
    /// @dev Filters messages based on `srcEid` to determine the type of incoming data.
    /// @param _origin The origin information containing the source Endpoint ID (`srcEid`).
    /// @param _guid The unique identifier for the received message.
    /// @param _message The encoded message data.
    /// @param _executor The executor address.
    /// @param _extraData Additional data.

    function _lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) internal virtual override {
        /**
         * @dev The `srcEid` (source Endpoint ID) is used to determine the type of incoming message.
         * - If `srcEid` is greater than READ_CHANNEL_EID_THRESHOLD (4294965694),
         *   it corresponds to arbitrary channel IDs for lzRead responses.
         * - All other `srcEid` values correspond to standard LayerZero messages.
         */
        if (_origin.srcEid > READ_CHANNEL_EID_THRESHOLD) {
            // Handle lzRead responses from arbitrary channels.
            _readLzReceive(_origin, _guid, _message, _executor, _extraData);
        } else {
            // Handle standard LayerZero messages.
            _messageLzReceive(_origin, _guid, _message, _executor, _extraData);
        }
    }

    /// @notice Internal function to handle standard LayerZero messages.
    /// @dev _origin The origin information (unused in this implementation).
    /// @dev _guid The unique identifier for the received message (unused in this implementation).
    /// @param _message The encoded message data.
    /// @dev _executor The executor address (unused in this implementation).
    /// @dev _extraData Additional data (unused in this implementation).
    function _messageLzReceive(
        Origin calldata, /* _origin */
        bytes32, /* _guid */
        bytes calldata _message,
        address, /* _executor */
        bytes calldata /* _extraData */
    ) internal virtual {
        // Implement message handling logic here.
    }

    /// @notice Internal function to handle lzRead responses.
    /// @dev _origin The origin information (unused in this implementation).
    /// @dev _guid The unique identifier for the received message (unused in this implementation).
    /// @param _message The encoded message data.
    /// @dev _executor The executor address (unused in this implementation).
    /// @dev _extraData Additional data (unused in this implementation).
    function _readLzReceive(
        Origin calldata, /* _origin */
        bytes32, /* _guid */
        bytes calldata _message,
        address, /* _executor */
        bytes calldata /* _extraData */
    ) internal virtual {
        // Implement read handling logic here.
    }

    function setReadChannel(uint32 _channelId, bool _active) public virtual onlyOwner {
        _setPeer(_channelId, _active ? AddressCast.toBytes32(address(this)) : bytes32(0));
    }
}
