pragma solidity ^0.4.22;

import "./SafeMath.sol";

contract JackpotRules {
  using SafeMath for uint256;

  constructor() public {}

  // NOTE: The next methods *must* add up to 100%

  // 50%
  function _winnerJackpot(uint256 jackpot) internal pure returns (uint256) {
    return jackpot.div(2);
  }

  // 40%
  function _landholderJackpot(uint256 jackpot) internal pure returns (uint256) {
    return (jackpot.mul(2)).div(5);
  }

  // 5%
  function _nextPotJackpot(uint256 jackpot) internal pure returns (uint256) {
    return jackpot.div(20);
  }

  // 5%
  function _teamJackpot(uint256 jackpot) internal pure returns (uint256) {
    return jackpot.div(20);
  }
}
