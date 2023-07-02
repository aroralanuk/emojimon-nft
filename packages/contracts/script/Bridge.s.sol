// SPDX-License-Identifier: MIT
// pragma solidity >=0.8.0;

// import "forge-std/Script.sol";

// import {WrappedERC721} from "../src/bridge/WrappedERC721.sol";

// contract BridgeScript is Script {
//     WrappedERC721 public originChainWERC721;
    
//     function run() public {
//         // deploy wrappedERC721
//         originChainWERC721 = new WrappedERC721();
//     }

//     function createAndTransfer() public {
//         // create wrapped token
//         originChainWERC721.create(address(this), 0);
//         // transfer wrapped token
//         originChainWERC721.transferAsset(address(this), 1, 10);
//     }
// }