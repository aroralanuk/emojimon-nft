// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC721Enumerable} from "@openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";

contract WrappedERC721 is ERC721Enumerable, TokenRouter {
    uint256 nextWrappedTokenId = 1;
    function create(address _contract, uint256 _tokenId) external {
        ERC721(_contract).transferFrom(msg.sender, address(this), _tokenId);
        _mint(msg.sender, nextWrappedTokenId);

    }
}
