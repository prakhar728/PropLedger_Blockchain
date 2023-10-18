// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract PropertyFactory is ERC20, ERC20Burnable {
    address public owner;
    uint256 public initialSupply;
    uint256 public limitedSupply;
    bool public verified;
    uint256 public currentPrice;
    mapping (address=>uint256) holders;
    constructor(
        string memory name,
        string memory symbol,
        uint256 _initialSupply,
        uint256 _limitedSupply
    ) ERC20(name, symbol) {
        owner = msg.sender;
        initialSupply = _initialSupply;
        limitedSupply = _limitedSupply;
        _mint(owner, _initialSupply);
    }

     /** 
     * @dev Transfer ownership of this conract to a different address
     * @param newOwner address of the new owner
     */
    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, "Only the owner can transfer ownership");
        owner = newOwner;
    }

     /** 
     * @dev Enter the current price of the token as compared to USDT value
     * @param _amount current amount in USDT for per-token of property
     */
    function updatePrice(uint256 _amount) public{
        currentPrice = _amount;
    }
    function buyTokens(uint256 amount) external {
        require(msg.sender != owner, "Owner cannot buy tokens.");
        require(totalSupply() + amount <= limitedSupply, "Exceeds limited supply.");
        // Perform USDT transfer to the owner.
        // Mint tokens for the buyer.
        _mint(msg.sender, amount);
    }


    // Implement functions to calculate market value and allow users to sell tokens for USDT.
}