// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OAppRead} from "@layerzerolabs/oapp-evm/contracts/oapp/OAppRead.sol";
import {OApp, Origin, MessagingFee, MessagingReceipt} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

/// @title OAppRead
/// @notice An example contract that extends OApRead to handle both messaging and read capabilities.
/// @dev Inherits from OApp and adds functionality specific to lzRead.
contract MyOAppRead is OAppRead {
    /// lzRead responses are sent from arbitrary channels with Endpoint IDs in the range of
    /// `eid > 4294965694` (which is `type(uint32).max - 1600`).
    uint32 constant READ_CHANNEL_EID_THRESHOLD = 4294965694;

    /// @param _endpoint The address of the LayerZero endpoint.
    /// @param _delegate The address of the delegate contract.
    constructor(address _endpoint, address _delegate) OAppRead(_endpoint, _delegate) {}

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
}
