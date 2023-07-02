// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ContextUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {TypeCasts} from "@hyperlane-xyz/core/contracts/libs/TypeCasts.sol";
import {GasRouter} from "@hyperlane-xyz/core/contracts/GasRouter.sol";
import {Message} from "./Message.sol";


/// @notice NFT token for stored locked principal tokens
contract PrincipalToken is GasRouter, ERC721 {
    using EnumerableSet for EnumerableSet.UintSet;

    struct Replica {
        uint64 expiry;
        uint32 domain;
        address mudRouter;
    }


    uint256 public nextPrincipalTokenId;

    uint256 public nextReplicaId;

    string public baseURI;


    mapping (address => mapping(uint256 => uint256)) public sourceToPrincipleTokenId;

    // why not public?
    mapping (uint256 => EnumerableSet.UintSet) private principalToReplica;

    mapping (uint256 => Replica) public replicas;

    event AssetTransferRemote(
        uint32 indexed destination,
        bytes32 indexed recipient,
        uint256 amount
    );

    constructor() ERC721("VisaPrincipalToken", "VPT") {}

    function create(address _contract, uint256 _tokenId) external returns (uint256) {
        ERC721(_contract).transferFrom(msg.sender, address(this), _tokenId);
        
        uint256 nextId = _incrementPrincipalTokenId();
        sourceToPrincipleTokenId[_contract][_tokenId] = nextId;
        _mint(msg.sender, nextId);

        return nextId;
    }

    function transferAsset(
        uint256 _prinicpalTokenId,
        uint32 _destinationDomain,
        address _mudRouterContract,
        uint64 _expiry
    ) public payable returns (bytes32) {
        require(ownerOf(_prinicpalTokenId) == msg.sender, "PrincipalToken: not owner");

        Replica memory replica = Replica({
            expiry: _expiry,
            domain: _destinationDomain,
            mudRouter: _mudRouterContract
        });

        uint256 replicaId = _incrementReplicaId();
        replicas[replicaId] = replica;
        principalToReplica[_prinicpalTokenId].add(replicaId);

        bytes32 messageId = _dispatchWithGas(
            _destinationDomain,
            Message.format(TypeCasts.addressToBytes32(msg.sender), replicaId, ""),
            msg.value, // interchain gas payment
            msg.sender // refund address
        );

        emit AssetTransferRemote(_destinationDomain, TypeCasts.addressToBytes32(msg.sender), replicaId);

        return messageId;
    }


    /// INTERNAL FUNCTIONS ///  

    function _handle(
        uint32 _origin,
        bytes32,
        bytes calldata _message
    ) internal override {}

    function _incrementPrincipalTokenId() internal returns (uint256) {
        return nextPrincipalTokenId++;
    }

    function _incrementReplicaId() internal returns (uint256) {
        return nextReplicaId++;
    }

    function setBaseURI(string memory _baseURI) external {
        baseURI = _baseURI;
    }

    // annoying diamond inheritance problem

    function _msgData() internal view override(ContextUpgradeable, Context) returns (bytes calldata) {
        return ContextUpgradeable._msgData();
    }

    function _msgSender() internal view override(ContextUpgradeable, Context) returns (address) {
        return ContextUpgradeable._msgSender();
    }
}
