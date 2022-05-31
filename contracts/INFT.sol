// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract INFT {
    function mint(address to, string memory tokenURI) external virtual returns (uint256) {}

    function mintBatch(address to, string[] memory tokenURIs) external virtual {}

    function getNFTType(uint256 tokenId) external view virtual returns (uint256 nftType) {}
}
