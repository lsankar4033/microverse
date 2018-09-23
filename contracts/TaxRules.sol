pragma solidity ^0.4.22;

import "./SafeMath.sol";

contract TaxRules {
  using SafeMath for uint256;

  constructor() public {}

  // 10%
  function _computeTax(uint256 price) internal pure returns (uint256) {
    return price.div(10);
  }

  // NOTE: The next 4 methods *must* add up to 100%

  // 50%
  function _computeJackpotTax(uint256 tax) internal pure returns (uint256) {
    return tax.div(2);
  }

  // 40%
  function _computeTotalLandholderTax(uint256 tax) internal pure returns (uint256) {
    return (tax.mul(2)).div(5);
  }

  // 5%
  function _computeTeamTax(uint256 tax) internal pure returns (uint256) {
    return tax.div(20);
  }

  // 5%
  function _computeNextPotTax(uint256 tax) internal pure returns (uint256) {
    return tax.div(20);
  }
}
