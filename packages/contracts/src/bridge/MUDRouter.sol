// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.0;

import {GasRouter} from "@hyperlane-xyz/core/contracts/GasRouter.sol";
import {Message} from "./Message.sol";

import {TokenSystem} from "../systems/TokenSystem.sol";

contract MUDRouter is GasRouter {
    using Message for bytes;

    TokenSystem public tokenSystem;
    function _handle(
        uint32 _origin,
        bytes32 sender,
        bytes calldata _message
    ) internal override {
        bytes32 recipient = _message.recipient();
        uint256 amount = _message.amount();
        bytes calldata metadata = _message.metadata();

        tokenSystem.mint(amount, metadata);
    }
}
