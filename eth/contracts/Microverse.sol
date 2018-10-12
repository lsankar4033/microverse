pragma solidity ^0.4.22;

import "./Ownable.sol";
import "./PullPayment.sol";
import "./SafeMath.sol";

import "./HexBoard2.sol";
import "./JackpotRules.sol";
import "./TaxRules.sol";

// TODO: Make HexBoard4
contract Microverse is HexBoard2, PullPayment, Ownable, TaxRules, JackpotRules {
  using SafeMath for uint256;

  // states this contract progresses through
  enum Stage {
    DutchAuction,
    GameRounds
  }
  Stage public stage = Stage.DutchAuction;

  modifier atStage(Stage _stage) {
    require(
      stage == _stage,
      "Function cannot be called at this time."
    );
    _;
  }

  constructor() public {
    _startAuction();
  }

  mapping(uint8 => address) public tileToOwner;
  mapping(uint8 => uint256) public tileToPrice;
  uint256 public totalTileValue;

  // TODO: Change this once we define 'team'
  function _sendToTeam(uint256 amount) private {
    asyncSend(owner, amount);
  }

  function _changeTilePrice(uint8 tileId, uint256 newPrice) private {
    uint256 oldPrice = tileToPrice[tileId];
    tileToPrice[tileId] = newPrice;
    totalTileValue = totalTileValue.add(newPrice.sub(oldPrice));
  }

  //////////
  // Auction
  //////////

  uint256 constant public startingAuctionPrice = 1 ether;
  uint256 constant public endingAuctionPrice = 0.1 ether;

  uint256 constant public auctionDuration = 7 days; // period over which land price decreases linearly

  uint256 public auctionStartTime;

  function buyTileAuction(uint8 tileId, uint256 newPrice) public payable atStage(Stage.DutchAuction) {
    // tile must not already have been bought
    require(tileToOwner[tileId] == address(0) && tileToOwner[tileId] == 0);

    uint256 tax = _priceToTax(newPrice);
    uint256 price = getTilePriceAuction();

    // must be paying the full price!
    require(msg.value >= tax + price);

    // NOTE: Team gets all proceeds of auction. Alternatively, this could be allocated to jackpot
    _sendToTeam(tax.add(price));

    tileToOwner[tileId] = msg.sender;
    _changeTilePrice(tileId, newPrice);
  }

  function getTilePriceAuction() public view atStage(Stage.DutchAuction) returns (uint256) {
    uint256 secondsPassed = 0;

    // This should always be the case...
    if (now > auctionStartTime) {
      secondsPassed = now.sub(auctionStartTime);
    }

    if (secondsPassed >= auctionDuration) {
      return endingAuctionPrice;
    } else {
      uint256 maxPriceDelta = startingAuctionPrice.sub(endingAuctionPrice);
      uint256 actualPriceDelta = (maxPriceDelta.mul(secondsPassed)).div(auctionDuration);

      return startingAuctionPrice.sub(actualPriceDelta);
    }
  }

  function endAuction() public atStage(Stage.DutchAuction) {
    // All tiles must be sold to proceed!
    for (uint8 tileId = minTileId; tileId <= maxTileId; tileId++) {
      if (tileToOwner[tileId] == address(0)) {
        require(false);
      }
    }

    stage = Stage.GameRounds;
    _startGameRound();
  }

  function _startAuction() private {
    auctionStartTime = now;
  }

  ///////
  // Game
  ///////

  uint256 constant public roundDuration = 24 hours;

  uint256 public roundStartTime;
  uint256 public jackpot;
  uint256 public nextJackpot;

  function roundTimeRemaining() public view atStage(Stage.GameRounds) returns (uint256)  {
    if (now <= roundStartTime.add(roundDuration)) {
      return 0;
    } else {
      return (roundStartTime.add(roundDuration)).sub(now);
    }
  }

  // NOTE: Currently callable by anyone
  function endGameRound() public atStage(Stage.GameRounds) {
    require(now >= roundStartTime.add(roundDuration));

    _distributeJackpot();

    _startGameRound();
  }

  function setTilePrice(uint8 tileId, uint256 newPrice) public payable atStage(Stage.GameRounds) {
    // must be owner
    require(tileToOwner[tileId] == msg.sender);

    uint256 tax = _priceToTax(newPrice);

    // must pay tax
    require(msg.value >= tax);

    _distributeTax(msg.value);

    _changeTilePrice(tileId, newPrice);
  }

  function buyTile(uint8 tileId, uint256 newPrice) public payable atStage(Stage.GameRounds) {
    // can't buy from self
    require(tileToOwner[tileId] != msg.sender);

    uint256 tax = _priceToTax(newPrice);

    // must pay tax + seller price
    require(msg.value >= tax.add(tileToPrice[tileId]));

    // pay seller
    asyncSend(tileToOwner[tileId], tileToPrice[tileId]);

    uint256 actualTax = msg.value.sub(tileToPrice[tileId]);
    _distributeTax(actualTax);

    _changeTilePrice(tileId, newPrice);
  }

  function _startGameRound() private {
    jackpot = nextJackpot;
    nextJackpot = 0;
    roundStartTime = now;
  }

  function _roundOver() private view returns (bool) {
    return now >= roundStartTime.add(roundDuration);
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

  // TODO: This can get expensive (although maxes out to O(num_tiles) ! Two approaches to test against
  // eachother:
  // 1. iterate once to get all differentials in a memory array, then iterate through that array to determine
  // how landholder payouts (this is what's implemented now)
  // 2. iterate through all tiles twice. once to get winner, once to get neighbor differentials
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

    // all landholders
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
}
