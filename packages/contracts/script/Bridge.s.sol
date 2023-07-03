// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Script.sol";

import {PrincipalToken} from "src/bridge/PrincipalToken.sol";
import {MUDRouter} from "src/bridge/MUDRouter.sol";
import {TypeCasts} from "@hyperlane-xyz/core/contracts/libs/TypeCasts.sol";

contract BridgeScript is Script {
    // address on sepolia
    address internal fakeMilady = 0x2A7190418e51bC9ea64ACAbd55200872fF808C1f;
    // manually update this
    address internal pt = address(0x12);
    address internal mud = address(0x13);

    PrincipalToken internal prinicpalToken;
    MUDRouter internal mudRouter;

    uint32 latticeDomain = 4242;
    uint32 sepoliaDomain = 11155111;

    function deployMUDRouter() public {
        vm.startBroadcast();

        mudRouter = new MUDRouter();

        mudRouter.enrollRemoteRouter(latticeDomain, TypeCasts.addressToBytes32(pt));

        vm.stopBroadcast();
    }

    function run() public {
        // check for chainId an deploy
        vm.startBroadcast();

        prinicpalToken = new PrincipalToken();

        vm.stopBroadcast(); 
    }


    
    function deployPT() public {
        // deploy principal token
        vm.startBroadcast();

        prinicpalToken.enrollRemoteRouter(latticeDomain, TypeCasts.addressToBytes32(mud));

        vm.stopBroadcast();

    }

    function createAndTransfer() public {
        // create wrapped token
        uint pId = prinicpalToken.create(fakeMilady, 0);
        // transfer wrapped token
        prinicpalToken.transferAsset(pId, latticeDomain, address(mudRouter), 3600);
    }
}