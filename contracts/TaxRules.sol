pragma solidity ^0.4.22;

import "./SafeMath.sol";

contract TaxRules {
  using SafeMath for uint256;

  constructor() public {}

  // 10%
  function _priceToTax(uint256 price) internal pure returns (uint256) {
    return price.div(10);
  }

  // NOTE: The next methods *must* add up to 100%

  // 50%
  function _jackpotTax(uint256 tax) internal pure returns (uint256) {
    return tax.div(2);
  }

  // 40%
  function _totalLandholderTax(uint256 tax) internal pure returns (uint256) {
    return (tax.mul(2)).div(5);
  }

  // 5%
  function _teamTax(uint256 tax) internal pure returns (uint256) {
    return tax.div(20);
  }

  // 5%
  function _nextPotTax(uint256 tax) internal pure returns (uint256) {
    return tax.div(20);
  }
}
