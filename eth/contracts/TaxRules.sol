pragma solidity ^0.4.22;

import "./SafeMath.sol";

contract TaxRules {
    using SafeMath for uint256;

    constructor() public {}

    // 10%
    function _priceToTax(uint256 price) public pure returns (uint256) {
        return price.div(10);
    }

    // NOTE: The next methods *must* add up to 100%

    // 50%
    function _jackpotTax(uint256 tax) public pure returns (uint256) {
        return tax.div(2);
    }

    // 40%
    function _totalLandholderTax(uint256 tax) public pure returns (uint256) {
        return (tax.mul(2)).div(5);
    }

    // 7.5%/5%
    function _teamTax(uint256 tax, bool hasReferrer) public pure returns (uint256) {
        if (hasReferrer) {
            return tax.div(20);
        } else {
            return (tax.mul(15)).div(200);
        }
    }

    // 2.5% although only invoked if _teamTax is lower value
    function _referrerTax(uint256 tax, bool hasReferrer)  public pure returns (uint256) {
        if (hasReferrer) {
            return tax.div(40);
        } else {
            return 0;
        }
    }

    // 2.5%
    function _nextPotTax(uint256 tax) public pure returns (uint256) {
        return tax.div(20);
    }
}
