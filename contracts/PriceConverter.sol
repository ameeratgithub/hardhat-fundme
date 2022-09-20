// SPDX-License-Identifier: None

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        // ABI
        // Address (Rinkeby)	0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        (, int256 price, , , ) = priceFeed.latestRoundData();

        /**
         * ETH In terms of USD
         * 'price' has 8 decimals
         * 'msg.value' has 18 decimals
         * multiply by 1e10 to make it equal to 1e18
         */

        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed)
        internal
        view
        returns (uint256)
    {
        uint256 ethPriceInUSD = getPrice(priceFeed);
        uint256 ethAmountInUSD = (ethPriceInUSD * ethAmount) / 1e18;
        return ethAmountInUSD;
    }
}
