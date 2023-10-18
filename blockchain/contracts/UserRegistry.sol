// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./PropertyFactory.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title User Registry
 * @dev Stores User Status and Property Metadata
 */
contract UserRegistry is Ownable {
    mapping(address => UserStruct) userBase;

    PropertyMetaDataStruct[] public properties;

    event PropertyAdded(
        address indexed tokenAddress,
        string name,
        string symbol,
        uint256 initialSupply,
        uint256 limitedSupply
    );

    enum KYCSTATUS {
        NO_USER,
        NOT_STARTED,
        PENDING,
        COMPLETED
    }

    struct PropertyMetaDataStruct {
        address contractAddress;
        bool verified;
    }
    struct UserStruct {
        KYCSTATUS kycStatus;
        string kycUrl;
        PropertyMetaDataStruct[] personalProperties;
    }
    struct UserData {
        KYCSTATUS kycStatus;
        PropertyMetaDataStruct[] personalProperties;
    }

    /**
     * @dev Ain't no use of Constructor .
     */
    constructor() Ownable(msg.sender) {}

    /**
     * @dev Let user submit their information for KYC verification
     * @param URI URL of the KYC Information
     */
    function addUserDetails(string calldata URI) public {
        require(
            userBase[msg.sender].kycStatus != KYCSTATUS.PENDING,
            "Already Applied"
        );
        require(
            userBase[msg.sender].kycStatus != KYCSTATUS.COMPLETED,
            "Already Verified"
        );
        userBase[msg.sender].kycStatus = KYCSTATUS.PENDING;
        userBase[msg.sender].kycUrl = URI;
    }

    /**
     * @dev Verify Users KYC status
     * @param user address of the user to verify the KYC for
     */
    function verifyUser(address user) public onlyOwner {
        require(
            userBase[msg.sender].kycStatus == KYCSTATUS.PENDING,
            "Can't verify. "
        );
        userBase[user].kycStatus = KYCSTATUS.COMPLETED;
    }
    /**
     * @dev Get the msg.sender parameter
     */
    function getSender() public view returns (address ) {
        // Ensure that the caller is the owner of the data
        return msg.sender;
    }

    /**
     * @dev Verify Users KYC status
     * @param user address of the user to get the details for
     */
    function getUserData(address user) public view returns (UserData memory) {
        // Ensure that the caller is the owner of the data
        require(msg.sender == user, "Only the owner of the data can access it");
        UserStruct storage userData = userBase[user];
        UserData memory userDataSubset;
        userDataSubset.kycStatus = userData.kycStatus;
        userDataSubset.personalProperties = userData.personalProperties;
        return userDataSubset;
    }

    /**
     * @dev Add Property Owned by user
     * @param name Name of the Property Token Intented
     * @param symbol Symbol of the token to be minted
     * @param initialSupply How many tokens does the owner of property want to own
     * @param limitedSupply How many tokens to be created that will be in circulation
     */
    function AddProperty(
        string calldata name,
        string calldata symbol,
        uint256 initialSupply,
        uint256 limitedSupply
    ) external {
        require(
            initialSupply <= limitedSupply,
            "Initial supply must be less than or equal to the limited supply."
        );
        PropertyFactory newToken = new PropertyFactory(
            name,
            symbol,
            initialSupply,
            limitedSupply
        );
        newToken.transferOwnership(msg.sender); // Transfer ownership to the caller.
        userBase[msg.sender].personalProperties.push(
            PropertyMetaDataStruct(address(newToken), false)
        );
        emit PropertyAdded(
            address(newToken),
            name,
            symbol,
            initialSupply,
            limitedSupply
        );
    }

    /**
     * @dev Add Property Owned by user
     * @param id Id of the Property meant to be verified
     */
    function VerifyProperty(uint256 id) external onlyOwner {
        userBase[msg.sender].personalProperties[id].verified = true;
    }
}
