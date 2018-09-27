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

  mapping(uint8 => address) public tileToOwner;

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
    require(tileToOwner[tileId] == msg.sender);

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
    require(tileToOwner[tileId] != msg.sender);

    uint256 tax = _priceToTax(newPrice);

    // must pay tax + seller price
    require(msg.value >= tax.add(tileToPrice[tileId]));

    // pay seller
    asyncSend(tileToOwner[tileId], tileToPrice[tileId]);

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
    uint256 winnerJackpot = _winnerJackpot(jackpot);
    uint256 landholderJackpot = _landholderJackpot(jackpot);
    bool distributedJackpot = _distributeWinnerAndLandholderJackpot(winnerJackpot, landholderJackpot);

    _sendToTeam(_teamJackpot(jackpot));

    nextJackpot = nextJackpot.add(_nextPotJackpot(jackpot));

    if (!distributedJackpot) {
      nextJackpot = nextJackpot.add(winnerJackpot).add(landholderJackpot);
    }
  }

  // TODO: This can get very expensive! Must benchmark. Two approaches to test against eachother:
  // 1. iterate once to get all differentials in a memory array, then iterate through that array to  determine
  // how landholder payouts (this is what's implemented now)
  // 2. iterate through all tiles twice. once to get winner, one to get neighbor differentials
  //
  // Returns false if there were no positive differentials this round
  function _distributeWinnerAndLandholderJackpot(uint256 winnerJackpot, uint256 landholderJackpot) private returns (bool) {
    uint256[] memory differentials = new uint256[](numTiles + 1); // inc necessary b/c tiles are 1-indexed
    uint256 numValidDifferentials = 0;

    uint256 bestDifferential = 0;
    uint8 bestTile = 0;

    for (uint8 i = minTileId; i <= maxTileId; i++) {
      // NOTE: Should it be possible to have '0' priced land at round's end? Begging for da bots
      if (tileToOwner[i] != address(0)) {
        uint256 differential = determineNeighborDifferential(i);
        differentials[i] = differential;
        if (differential > 0) {
          numValidDifferentials++;
        }

        if (differential > bestDifferential) {
          bestDifferential = differential;
          bestTile = i;
        }
      }
    }

    // If no winners, return false so that jackpot is xferred to next round
    if (numValidDifferentials == 0) {
      return false;
    }

    // winner
    asyncSend(tileToOwner[bestTile], winnerJackpot);

    // TODO: Make sure there isn't a way for any ether to get lost here
    // other landholders
    for (uint8 j = minTileId; j <= maxTileId; j++) {
      if (differentials[j] > 0) {
        uint256 allocation = landholderJackpot.mul(differentials[j]).div(numValidDifferentials);
        asyncSend(tileToOwner[j], allocation);
      }
    }

    return true;
  }

  // The key jackpot function.
  // Currently, only has a nonzero value if *all* neighbors have a greater value, in which case the *average*
  // price differential is returned
  function determineNeighborDifferential(uint8 tileId) public view returns (uint256) {
    uint8[6] memory neighbors = tileToNeighbors[tileId];

    uint256 numValidNeighbors = 0;
    uint256 totalNeighborDiff = 0;

    for (uint8 i = 0; i < 6; i++) {
      uint8 neighbor = neighbors[i];

      if (neighbor != nullNeighborValue && tileToOwner[neighbor] != address(0)) {
        if (tileToPrice[neighbor] <= tileToPrice[tileId]) {
          return 0;
        }

        // NOTE: This only works b/c of preceding check. If that check changes, this must change too
        uint256 neighborDiff = tileToPrice[neighbor].sub(tileToPrice[tileId]);
        totalNeighborDiff = totalNeighborDiff.add(neighborDiff);
        numValidNeighbors++;
      }
    }

    if (numValidNeighbors == 0) {
      return 0;
    }

    return totalNeighborDiff.div(numValidNeighbors);
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
      if (tileToOwner[tile] != address(0) && tileToPrice[tile] != 0) {
        uint256 tilePrice = tileToPrice[tile];
        uint256 allocation = tax.mul(tilePrice).div(totalTileValue);

        asyncSend(tileToOwner[tile], allocation);
      }
    }
  }

  // TODO: Change this once we define 'team'
  function _sendToTeam(uint256 amount) private {
    asyncSend(owner, amount);
  }
}
