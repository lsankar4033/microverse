pragma solidity ^0.4.22;

import "./Ownable.sol";
import "./PullPayment.sol";
import "./SafeMath.sol";

import "./HexBoard2.sol";
import "./TaxRules.sol";

// TODO: Make HexBoard4
contract LandGrab is HexBoard2, PullPayment, Ownable, TaxRules {
  // TODO Visibility methods:
  // - getJackpotSize()
  // - getJackpotTimeRemaining()

  // Annoying gotchas:
  // - tile numbering/neighboring (likely has to be statically defined or generated code)
  // - round timer management
  //   - calculation of neighbor differential
  // - fee splitting

  using SafeMath for uint256;

  mapping(uint8 => address) public landRegistry;

  // TODO: Ok to initialize these to 0?
  mapping(uint8 => uint256) public tileToPrice;
  uint256 public totalTileValue;

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

    uint256 oldPrice = tileToPrice[tileId];
    tileToPrice[tileId] = newPrice;
    totalTileValue = totalTileValue.add(newPrice.sub(oldPrice));
  }

  function buy(uint8 tileId, uint256 newPrice) public payable {
    // can't buy from self
    require(landRegistry[tileId] != msg.sender);

    uint256 tax = _computeTax(newPrice);

    // must pay tax + seller price
    require(msg.value >= tax.add(tileToPrice[tileId]));

    // pay seller
    asyncSend(landRegistry[tileId], tileToPrice[tileId]);

    uint256 actualTax = msg.value.sub(tileToPrice[tileId]);
    _distributeTax(actualTax);

    uint256 oldPrice = tileToPrice[tileId];
    tileToPrice[tileId] = newPrice;
    totalTileValue = totalTileValue.add(newPrice.sub(oldPrice));
  }

  // NOTE: Currently haven't implemented sidepot or 'referrals'
  function _distributeTax(uint256 tax) private {
    jackpot = jackpot.add(_computeJackpotTax(tax));

    _distributeLandholderTax(_computeTotalLandholderTax(tax));

    // TODO: Change this once we define 'team'
    asyncSend(owner, _computeTeamTax(tax));

    nextJackpot = nextJackpot.add(_computeNextPotTax(tax));
  }

  // NOTE: Perf test for Hex4 before deployment. Because loops
  function _distributeLandholderTax(uint256 landholderTax) private {
    for (uint8 tile = minTileId; tile <= maxTileId; tile++) {

      // NOTE: This assumes no unowned land with value!
      if (landRegistry[tile] != address(0)) {
        uint256 tilePrice = tileToPrice[tile];
        uint256 allocation = landholderTax.mul(tilePrice).div(totalTileValue);

        asyncSend(landRegistry[tile], allocation);
      }
    }
  }
}
