// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import {TypeCasts} from "@hyperlane-xyz/core/contracts/libs/TypeCasts.sol";
import {GasRouter} from "@hyperlane-xyz/core/contracts/GasRouter.sol";
import {Message} from "./Message.sol";

contract WrappedERC721 is GasRouter {
    using EnumerableMap for EnumerableMap.UintToUintMap;

    uint32 localDomain = 10;

    uint256 nextWrappedTokenId = 1;

    mapping (uint32 => uint256) public nextWrappedTokenIds;

    mapping(address => mapping(uint256 => EnumerableMap.UintToUintMap)) internal _wrappedTokens;

    event AssetTransferRemote(
        uint32 indexed destination,
        bytes32 indexed recipient,
        uint256 amount
    );

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
        uint32 _destinationDomain
    ) public payable returns (bytes32 messageId) {
        uint256 _wrappedTokenId = nextWrappedTokenIds[_destinationDomain];

        _wrappedTokens[_contract][_tokenId].set(_destinationDomain, _wrappedTokenId);

        bytes memory metadata = abi.encodePacked(ERC721(_contract).tokenURI(_tokenId));

        bytes32 _msgSender = TypeCasts.addressToBytes32(msg.sender);
        // change metadata LD style
        messageId = _dispatchWithGas(
            _destinationDomain,
            Message.format(_msgSender, _wrappedTokenId, metadata),
            msg.value, // interchain gas payment
            msg.sender // refund address
        );
        emit AssetTransferRemote(_destinationDomain, _msgSender, _wrappedTokenId);

        nextWrappedTokenIds[_destinationDomain] += 1;
    }

    function _handle(
        uint32 _origin,
        bytes32,
        bytes calldata _message
    ) internal override {}

    function getWrappedToken(address _contract, uint256 _tokenId, uint32 _domain) public view returns (uint256) {
        return _wrappedTokens[_contract][_tokenId].get(_domain);
    }
}
