// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IShoefyFarm{

    event GeneralNFTFarmed(address userAddress,bytes32 category,uint256 farmId);
    event RapidNFTFarmed(address userAddress,bytes32 category,uint256 farmId);
    event GeneralNFTMinted(address userAddress,bytes32 category,uint256 farmId);
    event RapidNFTMinted(address userAddress,bytes32 category,uint256 farmId);

// function for general and rapid farming of shoefy NFT
    function farmNFT(bytes32 category_, uint256 farmAmount_, bool generalFarm_) external;

// function to harvest NFT once it is farmed through general or rapid farming
    function harvestNFT(uint256[] memory farmIds_, string[] memory tokenURIs_, bytes[] memory signatures_, bool generalFarm) external;

}