// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Ownable.sol";
import "./IFarming.sol";
import "./INFT.sol";
import "./SignRecovery.sol";

/*
* @title ShoefyFarm
* @author Usman Fazil
* @notice Shoefy Farming contract
*/

contract ShoefyFarm is Ownable, IShoefyFarm, SignRecovery {
    uint256 public userFarmLimit;
    uint256 public farmId;

    bytes32 public constant generalFarm = keccak256("GENERAL");
    bytes32 public constant rapidFarm = keccak256("RAPID");

    // farm category => nfts left
    mapping(bytes32 => uint256) public generalFarmsLeft;
    mapping(bytes32 => uint256) public rapidFarmsLeft;
    // total layers in each category.
    mapping(bytes32 => uint256) public totalLayers;
    // farm category => staking tokens required
    mapping(bytes32 => uint256) public generalTokensRequired;
    mapping(bytes32 => uint256) public rapidTokensRequired;
    // time required for each category
    mapping(bytes32 => uint256) public generalFarmTime;
    mapping(bytes32 => uint256) public rapidFarmTime;
    // mappings to store farm information
    mapping(uint256 => address) public farmOwner;
    mapping(uint256 => uint256) public farmTimestamp;
    mapping(uint256 => bytes32) public farmCategory;
    mapping(uint256 => bytes32) public farmType;
    mapping(uint256 => bool) public farmHarvested;

    mapping(bytes => bool) private usedSign;

    address public signerAddress;
    IERC20 internal shoefyToken;
    INFT internal nftContract;

    constructor(
        address shoefyContract_,
        address nftContract_,
        string[] memory categories_,
        uint256[] memory totalGeneralNFTs,
        uint256[] memory totalRapidNFTs,
        uint256[] memory generalFarmTimes_,
        uint256[] memory rapidFarmtimes_,
        uint256[] memory generalTokensRequired_,
        uint256[] memory rapidTokensRequired_,
        address _signerAddress
    ) {
        require(
            _signerAddress != address(0),
            "Signer Address could not be empty"
        );
        userFarmLimit = 10;
        farmId = 1;
        shoefyToken = IERC20(shoefyContract_);
        nftContract = INFT(nftContract_);

        signerAddress = _signerAddress;
        bytes32 category_;

        for (uint256 i = 0; i < categories_.length; i++) {
            category_ = keccak256(abi.encodePacked(categories_[i]));
            generalFarmsLeft[category_] = totalGeneralNFTs[i];
            rapidFarmsLeft[category_] = totalRapidNFTs[i];
            generalFarmTime[category_] = generalFarmTimes_[i];
            rapidFarmTime[category_] = rapidFarmtimes_[i];
            generalTokensRequired[category_] = generalTokensRequired_[i];
            rapidTokensRequired[category_] = rapidTokensRequired_[i];
        }
    }

    /*
    * @dev farm new Shoefy NFTs
    * @param category_ category of farm 
    * @param farmAmount_ total number of NFTs to farm
    * @param generalFarm_ bool value to check the type of farm (true for general, false for rapid)
    * @notice approve shoe tokens to farming contract before calling farm funciton
    */
    function farmNFT(bytes32 category_, uint256 farmAmount_, bool generalFarm_)
        external
        override
    { 
        _farmValidation(category_, farmAmount_, generalFarm_);

        bytes32 userFarmType;
        generalFarm_ ? userFarmType = generalFarm : userFarmType = rapidFarm;

        for (uint256 i = 0; i < farmAmount_; i++) {
            uint256 newFarmId = _getNextFarmId();
            farmTimestamp[newFarmId] = block.timestamp;
            farmOwner[newFarmId] = msg.sender;
            farmCategory[newFarmId] = category_;

            farmType[newFarmId] = userFarmType;
             _incrementFarmId();

            if (generalFarm_){
                _decrementGeneralFarm(category_);
                emit GeneralNFTFarmed(msg.sender, category_, newFarmId);
            }else{
                _decrementRapidFarm(category_);
                emit RapidNFTFarmed(msg.sender, category_, newFarmId);
            }
        }
        require(
            shoefyToken.transferFrom( msg.sender, address(this),
            farmAmount_ * generalTokensRequired[category_]), "Token transfer failed" );
    }

    // function to harvest NFT once it is farmed through general farming
    /*
    * @dev harvest user's farms 
    * @param farmIds_ array of farm ids 
    * @param tokenURIs_ array of token uris. 
    * @param signatures_ array of signatures created by admin for verification
    * @param generalFarm_ bool value to check the type of farm (true for general, false for rapid)
    * @notice function will call shoefyNFT contract batchMint function to mint new NFTs.
    */
    function harvestNFT(
        uint256[] memory farmIds_,
        string[] memory tokenURIs_,
        bytes[] memory signatures_,
        bool generalFarm_
    ) external override {
        require(farmIds_.length == tokenURIs_.length && tokenURIs_.length == signatures_.length, "Invalid array length");
        
        bytes32 userFarmType;
        generalFarm_ ? userFarmType = generalFarm : userFarmType = rapidFarm;

        for (uint256 i = 0; i < farmIds_.length; i++) {
            _harvestValidation(msg.sender,farmIds_[i], userFarmType, tokenURIs_[i], signatures_[i]);
            
            farmHarvested[farmIds_[i]] = true;
            usedSign[signatures_[i]] = true;

            if (generalFarm_){
                emit GeneralNFTMinted(msg.sender, farmCategory[farmIds_[i]], farmIds_[i]);
            }else{
                emit RapidNFTMinted(msg.sender, farmCategory[farmIds_[i]], farmIds_[i]);
            }
        }
        nftContract.mintBatch(msg.sender, tokenURIs_);
    }

    // admin function to update the address of message signer.
    function updateSignerAddress(address _signerAddress) public onlyOwner {
        require(
            _signerAddress != address(0),
            "Signer Address could not be empty"
        );
        signerAddress = _signerAddress;
    }
    
    // admin function to update initial configuration values
    function updateFarmConfig(
        string[] memory categories_,
        uint256[] memory totalGeneralNFTs,
        uint256[] memory totalRapidNFTs,
        uint256[] memory generalFarmTimes_,
        uint256[] memory rapidFarmtimes_,
        uint256[] memory generalTokensRequired_,
        uint256[] memory rapidTokensRequired_
    )external onlyOwner{
        bytes32 category_;

        for (uint256 i = 0; i < categories_.length; i++) {
            category_ = keccak256(abi.encodePacked(categories_[i]));
            generalFarmsLeft[category_] = totalGeneralNFTs[i];
            rapidFarmsLeft[category_] = totalRapidNFTs[i];
            generalFarmTime[category_] = generalFarmTimes_[i];
            rapidFarmTime[category_] = rapidFarmtimes_[i];
            generalTokensRequired[category_] = generalTokensRequired_[i];
            rapidTokensRequired[category_] = rapidTokensRequired_[i];
        }
    }

    // internal helper functions
    function _getNextFarmId() internal view returns (uint256) {
        return farmId;
    }

    function _incrementFarmId() internal {
        farmId += 1;
    }

    function _decrementGeneralFarm(bytes32 category_) internal {
        generalFarmsLeft[category_] -= 1;
    }

    function _decrementRapidFarm(bytes32 category_) internal {
        rapidFarmsLeft[category_] -= 1;
    }

    // internal function to verify the user provided signature
    function _verifySign(address userAddress_, uint256 farmId_,string memory tokenURI_, 
            bytes memory sign_)internal view returns (bool verfied){

        address recoveredAddress = recoverSigner(
            keccak256(abi.encodePacked(userAddress_, farmId_, tokenURI_)),sign_ );

        (recoveredAddress == signerAddress) ? verfied = true : verfied = false;

        return verfied;
    }

    // internal function to validate farm function parameters 
    function _farmValidation(bytes32 category_, uint256 farmAmount_, bool generalFarm_)internal view{
        require( farmAmount_ <= userFarmLimit, "Can not Farm more than user Farming Limit");

        if (generalFarm_){
            require( generalFarmsLeft[category_] > 0, "General Farm limit reached for provided category");
        }else{
            require( rapidFarmsLeft[category_] > 0, "Rapid Farm limit reached for provided category");
        } 
    }

    // internal function to validate the parameters and farm state before harvestation
    function _harvestValidation(
        address user_, 
        uint256 farmId_, 
        bytes32 farmType_,
        string memory tokenURI_,
        bytes memory sign_
        )internal view{

        require(farmOwner[farmId_] == user_,"Only owner can harvest the farm");
        require(farmType[farmId_] == farmType_, "Invalid farm type");
        require(!usedSign[sign_], "Signature already used");

        uint256 timeDiff = block.timestamp - farmTimestamp[farmId_];
        bytes32 category = farmCategory[farmId_];

        if (farmType_ == generalFarm){
            require(timeDiff > generalFarmTime[category], "Can not harvest during farming period");
        }else{
            require(timeDiff > rapidFarmTime[category], "Can not harvest during farming period");
        }

        require(_verifySign(user_, farmId_, tokenURI_, sign_), "Invalid signature");
    }

}
