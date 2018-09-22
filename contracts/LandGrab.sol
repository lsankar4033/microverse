pragma solidity ^0.4.22;

import "./SafeMath.sol";
import "./PullPayment.sol";

import "./HexBoard2.sol";

// TODO: Make HexBoard4
contract LandGrab is HexBoard2, PullPayment {
  // Tx methods:
  // - buy(tileId, newPrice) payable
  // - setPrice(tileId, newPrice) payable

  // Visibility methods:
  // - getPrice(tileId)
  // - getNeighbors(tileId)
  // - getOwner(tileId)
  // - getJackpotSize()
  // - getJackpotTimeRemaining()
  // - getBalance()
  // - withdraw()

  // Annoying gotchas:
  // - tile numbering/neighboring (likely has to be statically defined or generated code)
  // - round timer management
  //   - calculation of neighbor differential
  // - fee splitting

  using SafeMath for uint256;

  mapping(uint8 => address) public landRegistry;

  // TODO: How is this initialized? Perhaps use a default value
  mapping(uint8 => uint256) public tileToPrice;

  uint256 public jackpot;
  uint256 public nextJackpot;

  constructor() public {}

  function setPrice(uint8 tileId, uint256 newPrice) public payable {
    // must be owner
    require(landRegistry[tileId] == msg.sender);

    uint256 tax = _computeTax(newPrice);

    // must pay tax
    require(msg.value >= tax);

    _distributeTax(msg.value);
    tileToPrice[tileId] = newPrice;
  }

  function buy(uint8 tileId, uint256 newPrice) public payable {
    // can't buy from self
    require(landRegistry[tileId] != msg.sender);

    uint256 tax = _computeTax(newPrice);

    // must pay tax + seller price
    require(msg.value >= tax.add(tileToPrice[tileId]));

    // pay seller
    _asyncTransfer(landRegistry[tileId], tileToPrice[tileId]);

    uint256 actualTax = msg.value.sub(tileToPrice[tileId]);
    _distributeTax(actualTax);
    tileToPrice[tileId] = newPrice;
  }

  // NOTE: Currently haven't implemented sidepot or 'referrals'
  function _distributeTax(uint256 tax) private {
    // jackpot
    // land holder dividends
    // sidepot (optional)
    // team fee
    // next pot
    // referral (optional)

    jackpot = jackpot.add(_computeJackpotTax(tax));

    _distributeLandholderTax(_computeTotalLandholderTax(tax));

    // TODO: Distribute team fee

    nextJackpot = nextJackpot.add(_computeNextPotTax(tax));
  }

  function _distributeLandholderTax(uint256 landholderTax) private {
    // TODO! Iterate through all landholders to distribute dividends
  }

  // 10%
  function _computeTax(uint256 price) private pure returns (uint256) {
    return price.div(10);
  }

  // NOTE: The next 4 methods *must* add up to 100%

  // 50%
  function _computeJackpotTax(uint256 tax) private pure returns (uint256) {
    return tax.div(2);
  }

  // 40%
  function _computeTotalLandholderTax(uint256 tax) private pure returns (uint256) {
    return (tax.mul(2)).div(5);
  }

  // 5%
  function _computeTeamTax(uint256 tax) private pure returns (uint256) {
    return tax.div(20);
  }

  // 5%
  function _computeNextPotTax(uint256 tax) private pure returns (uint256) {
    return tax.div(20);
  }


}
