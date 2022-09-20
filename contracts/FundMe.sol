/* 
    Order of Statements, Definitions in Contract

    1. Pragma
    2. Imports
    3. errors 
        a. Prefix with contract name like FundMe__
    4. Interfaces
    5. Libraries
    6. Contracts
        a. Type declarations (Like using libraries)
        b. State variables
        c. Events
        d. Modifiers
        e. Functions
            i.      constructor
            ii.     receive
            iii.    fallback
            iv.     external
            v.      public
            vi.     internal
            vii.    private
            viii.   view / pure
 */

/* 
    * Get funds from users
    * Withdraw funds
    * Set a minimum funding value in USD

 */

// SPDX-License-Identifier: None

pragma solidity ^0.8.0;

import "./PriceConverter.sol";

error FundMe__NotOwner();

/** @title A contract for crowd funding
 *  @author Ameer Hamza
 *  @notice This contract is to demo a sample funding contract
 *  @dev This implements price feeds as our library
 */
contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 50 * 1e18;
    // 21,415 gas - constant
    // 23,515 gas - non-constant

    address[] public funders;

    mapping(address => uint256) public addressToAmountFunded;

    address public immutable iOwner;

    // 21,508 gas - immutable
    // 23,644 gas - non-immutable

    AggregatorV3Interface public immutable priceFeed;

    modifier onlyOwner() {
        if (msg.sender != iOwner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    constructor(address _priceFeedAddress) {
        iOwner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    /** @notice This function collect funds and save into FundMe contract
     *  @dev This function gets conversion rate (Eth -> USD) from PriceConverter library
     */
    function fund() public payable {
        require(
            msg.value.getConversionRate(priceFeed) >= MINIMUM_USD,
            "Didn't send enough"
        );
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // Reset the array
        funders = new address[](0);

        // Actually withdraw the funds

        // Call - forward all remaining gas, returns bool
        // (bool callSuccess, ) = payable(msg.sender).call{
        //     value: address(this).balance
        // }("");
        // require(callSuccess, "Call Failed");

        // Transfer - 2300 gas, throws error if fails
        payable(msg.sender).transfer(address(this).balance);

        // // Send - 2300 gas, returns false if fails
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess,"Send Failed");
    }
}
