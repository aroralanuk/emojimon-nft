// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Script.sol";

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {TypeCasts} from "@hyperlane-xyz/core/contracts/libs/TypeCasts.sol";

import {PrincipalToken} from "src/bridge/PrincipalToken.sol";
import {MUDRouter} from "src/bridge/MUDRouter.sol";

contract BridgeScript is Script {
    // address on sepolia
    address internal fakeMilady = 0x2A7190418e51bC9ea64ACAbd55200872fF808C1f;
    // manually update this
    address internal pt = 0x3C1de29b281BE6BC4399A65512d5CB28d2982c49;
    address internal mud = 0x1F01B669dB0e3F9628e21bb3A8E968c1EfF06522;

    PrincipalToken internal principalToken;
    MUDRouter internal mudRouter;

    uint32 internal latticeDomain = 4242;
    uint32 internal sepoliaDomain = 11155111;

    uint256 pk = vm.envUint("DEPLOYER_PRIVATE_KEY");
    address deployer_address = vm.envAddress("DEPLOYER_ADDRESS");

    function deployMUDRouter() public {
        vm.startBroadcast(pk);

        mudRouter = new MUDRouter();

        mudRouter.initialize(0xbeDb55A71de1ba8B41F9963492930fC5611032e1, 0x9Afdb102911Df0b6CdDd9De2bAB5eF6b5094c9F3);
        mudRouter.enrollRemoteRouter(sepoliaDomain, TypeCasts.addressToBytes32(pt));

        vm.stopBroadcast();
    }

    function run() public {
        // check for chainId an deploy
        vm.startBroadcast(pk);

        principalToken = new PrincipalToken();
        principalToken.initialize(0xCC737a94FecaeC165AbCf12dED095BB13F037685, 0xAE2a1e436A9842eedFbb5cb5AcC8087Ee10b5fe9);

        vm.stopBroadcast(); 
    }


    
    function deployPT() public {
        // deploy principal token
        vm.startBroadcast(pk);

        principalToken = PrincipalToken(pt);
        principalToken.enrollRemoteRouter(latticeDomain, TypeCasts.addressToBytes32(mud));

        vm.stopBroadcast();

    }

    function createAndTransfer() public {
        vm.startBroadcast(pk);

        principalToken = PrincipalToken(pt);
        // create wrapped token
        ERC721(fakeMilady).approve(address(principalToken), 0);
        uint pId = principalToken.create(fakeMilady, 0);
        // transfer wrapped token
        principalToken.transferAsset(pId, latticeDomain, address(mudRouter), 3600);

        vm.stopBroadcast();
    }
}