// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

import {TokenRouter} from "./TokenRouter.sol";

contract WrappedERC721 is TokenRouter {
    using EnumerableMap for EnumerableMap.UintToUintMap;

    uint32 localDomain = 10;

    uint256 nextWrappedTokenId = 1;

    mapping (uint32 => uint256) public nextWrappedTokenIds;

    mapping(address => mapping(uint256 => EnumerableMap.UintToUintMap)) internal _wrappedTokens;

    constructor() {}

    function create(address _contract, uint256 _tokenId) external {
        ERC721(_contract).transferFrom(msg.sender, address(this), _tokenId);
        _wrappedTokens[_contract][_tokenId].set(localDomain, 1);
    }

    function transferAssetBatch(
        address _contract,
        uint256 _tokenId,
        uint32[] memory destinationDomains
    ) public {
        uint256 domains = destinationDomains.length;
        for (uint256 i = 0; i < domains; i++) {
            transferAsset(_contract, _tokenId, destinationDomains[i]);
        }
    }

    function transferAsset(
        address _contract,
        uint256 _tokenId,
        uint32 destinationDomain
    ) public {
        uint256 _wrappedTokenId = nextWrappedTokenIds[destinationDomain];

        _wrappedTokens[_contract][_tokenId].set(destinationDomain, _wrappedTokenId);

        // transferRemote()

        nextWrappedTokenIds[destinationDomain] += 1;
    }

    function _transferFromSender(uint256 _tokenId)
        internal
        override
        returns (bytes memory metadata)
    {
        // return ERC721(address(0x1)).tokenURI(_tokenId);
        return new bytes(0);
    }

    function _transferTo(
        address _recipient,
        uint256 _amountOrId,
        bytes calldata metadata
    ) internal override {
    }

    function getWrappedToken(address _contract, uint256 _tokenId, uint32 _domain) public view returns (uint256) {
        return _wrappedTokens[_contract][_tokenId].get(_domain);
    }
}
