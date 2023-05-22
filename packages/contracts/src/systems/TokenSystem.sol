// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";

import {Token, TokenData} from "../codegen/Tables.sol";
import {tokenToEntityKey} from "../toEntityKey.sol";

// import {MUDRouter} from "../bridge/MUDRouter.sol";
import {GasRouter} from "@hyperlane-xyz/core/contracts/GasRouter.sol";

import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {WorldContext} from "@latticexyz/world/src/WorldContext.sol";


contract TokenSystem is System {
    function mint(uint256 _tokenSequence, bytes memory metadata) public {
        bytes32 tokenId = tokenToEntityKey(_tokenSequence);
        TokenData memory token = Token.get(tokenId);
        require(token.tokenId != 0, "already spawned");

        // Token.set(tokenId, true);
        Token.set(tokenId, _tokenSequence, metadata);

    }
}
