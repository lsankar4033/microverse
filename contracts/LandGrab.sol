pragma solidity ^0.4.22;

import "./Ownable.sol";
import "./PullPayment.sol";
import "./SafeMath.sol";

import "./HexBoard2.sol";
import "./JackpotRules.sol";
import "./TaxRules.sol";

// TODO: Make HexBoard4
contract LandGrab is HexBoard2, PullPayment, Ownable, TaxRules, JackpotRules {

  using SafeMath for uint256;

  mapping(uint8 => address) public landRegistry;

  // TODO: Ok to initialize these to 0?
  mapping(uint8 => uint256) public tileToPrice;
  uint256 public totalTileValue;

  uint256 constant public roundDuration = 24 hours;

  uint256 public roundStartTime;
  uint256 public jackpot;
  uint256 public nextJackpot;

  function roundTimeRemaining() public view returns (uint256) {
    if (block.timestamp <= roundStartTime.add(roundDuration)) {
      return 0;
    } else {
      return (roundStartTime.add(roundDuration)).sub(block.timestamp);
    }
  }

  // TODO: Figure out the starting conditions. Maybe we manually start the first round with some jackpot?
  constructor() public {
    _startRound();
  }

  // NOTE: Currently callable by anyone
  function endRound() public {
    require(block.timestamp >= roundStartTime.add(roundDuration));

    _distributeJackpot();

    _startRound();
  }

  // TODO: call end round!
  function setPrice(uint8 tileId, uint256 newPrice) public payable {
    // must be owner
    require(landRegistry[tileId] == msg.sender);

    uint256 tax = _priceToTax(newPrice);

    // must pay tax
    require(msg.value >= tax);

    _distributeTax(msg.value);

    uint256 oldPrice = tileToPrice[tileId];
    tileToPrice[tileId] = newPrice;
    totalTileValue = totalTileValue.add(newPrice.sub(oldPrice));
  }

  // TODO: call end round!
  function buy(uint8 tileId, uint256 newPrice) public payable {
    // can't buy from self
    require(landRegistry[tileId] != msg.sender);

    uint256 tax = _priceToTax(newPrice);

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

  function _startRound() private {
    jackpot = nextJackpot;
    nextJackpot = 0;
    roundStartTime = block.timestamp;
  }

  function _roundOver() private view returns (bool) {
    return block.timestamp >= roundStartTime.add(roundDuration);
  }

  function _distributeJackpot() private {
    _distributeWinnerJackpot(_winnerJackpot(jackpot));

    _distributeLandholderJackpot(_landholderJackpot(jackpot));

    _sendToTeam(_teamJackpot(jackpot));

    nextJackpot = nextJackpot.add(_nextPotJackpot(jackpot));
  }

  function _distributeWinnerJackpot(uint256 winnings) {
    // TODO: Determine winner, send to winner
  }

  function _distributeLandholderJackpot(uint256 winnings) {
    // TODO: Distribute to landholders based on differentials
  }

  // NOTE: Currently haven't implemented sidepot or 'referrals'
  function _distributeTax(uint256 tax) private {
    jackpot = jackpot.add(_jackpotTax(tax));

    _distributeLandholderTax(_totalLandholderTax(tax));

    _sendToTeam(_teamTax(tax));

    nextJackpot = nextJackpot.add(_nextPotTax(tax));
  }

  // NOTE: Perf test for Hex4 before deployment. Because loops
  function _distributeLandholderTax(uint256 tax) private {
    for (uint8 tile = minTileId; tile <= maxTileId; tile++) {

      // NOTE: This assumes no unowned land with value!
      if (landRegistry[tile] != address(0)) {
        uint256 tilePrice = tileToPrice[tile];
        uint256 allocation = tax.mul(tilePrice).div(totalTileValue);

        asyncSend(landRegistry[tile], allocation);
      }
    }
  }

  // TODO: Change this once we define 'team'
  function _sendToTeam(uint256 amount) private {
    asyncSend(owner, amount);
  }
}
