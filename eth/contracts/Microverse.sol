pragma solidity ^0.4.22;

// Zeppelin libs
import "./Math.sol";
import "./Ownable.sol";
import "./PullPayment.sol";
import "./SafeMath.sol";

// Microverse libs
import "./HexBoard3.sol";
import "./JackpotRules.sol";
import "./TaxRules.sol";

contract Microverse is
    HexBoard3,
    PullPayment,
    Ownable,
    TaxRules,
    JackpotRules {
    using SafeMath for uint256;
    using Math for uint256;

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

    event TileOwnerChange(
        uint8 indexed tileId,
        address indexed oldOwner,
        address indexed newOwner,
        uint256 oldPrice,
        uint256 newPrice
    );

    //////////
    // Auction
    //////////

    event AuctionStarted(
        uint256 startingAuctionPrice,
        uint256 endingAuctionPrice,
        uint256 auctionDuration,
        uint256 startTime
    );

    event AuctionEnded(
        uint256 endTime
    );

    uint256 constant public startingAuctionPrice = 1 ether;
    uint256 constant public endingAuctionPrice = 0.1 ether;

    uint256 constant public auctionDuration = 7 days; // period over which land price decreases linearly

    uint256 public numBoughtTiles;
    uint256 public auctionStartTime;

    function buyTileAuction(uint8 tileId, uint256 newPrice) public payable atStage(Stage.DutchAuction) {
        // tile must not already have been bought
        require(tileToOwner[tileId] == address(0) && tileToOwner[tileId] == 0);

        uint256 tax = _priceToTax(newPrice);
        uint256 price = getTilePriceAuction();

        // must be paying the full price!
        require(msg.value >= tax.add(price));

        _sendToTeam(tax.add(price));

        tileToOwner[tileId] = msg.sender;
        _changeTilePrice(tileId, newPrice);

        numBoughtTiles = numBoughtTiles.add(1);

        emit TileOwnerChange(tileId, address(0), msg.sender, price, newPrice);

        if (numBoughtTiles >= numTiles) {
            endAuction();
        }
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

    function endAuction() private {
        // Slightly redundant check
        require(numBoughtTiles >= numTiles);

        stage = Stage.GameRounds;
        _startGameRound();

        emit AuctionEnded(now);
    }

    function _startAuction() private {
        auctionStartTime = now;
        numBoughtTiles = 0;

        emit AuctionStarted(startingAuctionPrice,
                            endingAuctionPrice,
                            auctionDuration,
                            auctionStartTime);
    }

    ///////
    // Game
    ///////

    // Used to ensure a round ends
    uint256 constant public startingRoundExtension = 24 hours;
    uint256 constant public halvingVolume = 100 ether; // tx volume before next duration halving
    uint256 constant public minRoundExtension = 10 seconds; // could set to 1 second

    uint256 public curExtensionVolume;
    uint256 public curRoundExtension;

    uint256 public roundEndTime;

    uint256 public jackpot;
    uint256 public nextJackpot;

    ////////////////////////////////////
    // [Game] Round extension management
    ////////////////////////////////////

    function roundTimeRemaining() public view atStage(Stage.GameRounds) returns (uint256)  {
        if (_roundOver()) {
            return 0;
        } else {
            return roundEndTime.sub(now);
        }
    }

    function _extendRound() private {
        roundEndTime = now + curRoundExtension;
    }

    function _startGameRound() private {
        curExtensionVolume = 0 ether;
        curRoundExtension = startingRoundExtension;

        jackpot = nextJackpot;
        nextJackpot = 0;

        _extendRound();
    }

    function _roundOver() private view returns (bool) {
        return now >= roundEndTime;
    }

    modifier duringRound() {
        require(!_roundOver());
        _;
    }

    // NOTE: Must be called for all volume we want to count towards round extension halving
    function _logRoundExtensionVolume(uint256 amount) private {
        curExtensionVolume = curExtensionVolume.add(amount);

        if (curExtensionVolume >= halvingVolume) {
            curRoundExtension = curRoundExtension.div(2).max(minRoundExtension);
            curExtensionVolume = 0 ether;
        }
    }

    ////////////////////////
    // [Game] Player actions
    ////////////////////////

    function endGameRound() public atStage(Stage.GameRounds) {
        require(_roundOver());

        _distributeJackpot();
        _startGameRound();
    }

    function setTilePrice(uint8 tileId, uint256 newPrice)
        public
        payable
        atStage(Stage.GameRounds)
        duringRound {
        // must be owner
        require(tileToOwner[tileId] == msg.sender);

        uint256 tax = _priceToTax(newPrice);

        // must pay tax
        require(msg.value >= tax);

        _distributeTax(msg.value);
        _changeTilePrice(tileId, newPrice);

        // NOTE: Currently we extend round for 'every' tile price change. Alternatively could do only on
        // increases or decreases or changes exceeding some magnitude
        _extendRound();
        _logRoundExtensionVolume(msg.value);
    }

    function buyTile(uint8 tileId, uint256 newPrice)
        public
        payable
        atStage(Stage.GameRounds)
        duringRound {
        // can't buy from self
        address oldOwner = tileToOwner[tileId];
        require(oldOwner != msg.sender);

        uint256 tax = _priceToTax(newPrice);

        // must pay tax + seller price
        uint256 oldPrice = tileToPrice[tileId];
        require(msg.value >= tax.add(oldPrice));

        // pay seller
        asyncSend(oldOwner, tileToPrice[tileId]);
        tileToOwner[tileId] = msg.sender;

        uint256 actualTax = msg.value.sub(oldPrice);
        _distributeTax(actualTax);

        _changeTilePrice(tileId, newPrice);
        _extendRound();
        _logRoundExtensionVolume(msg.value);

        emit TileOwnerChange(tileId, oldOwner, msg.sender, oldPrice, newPrice);
    }

    ///////////////////////////////////////
    // [Game] Dividend/jackpot distribution
    ///////////////////////////////////////

    function _distributeJackpot() private {
        uint256 winnerJackpot = _winnerJackpot(jackpot);
        uint256 landholderJackpot = _landholderJackpot(jackpot);
        _distributeWinnerAndLandholderJackpot(winnerJackpot, landholderJackpot);

        _sendToTeam(_teamJackpot(jackpot));
        nextJackpot = nextJackpot.add(_nextPotJackpot(jackpot));
    }

    function _distributeWinnerAndLandholderJackpot(uint256 winnerJackpot, uint256 landholderJackpot) private {
        uint256[] memory complements = new uint256[](numTiles + 1); // inc necessary b/c tiles are 1-indexed
        uint256 totalPriceComplement = 0;

        uint256 bestComplement = 0;
        uint8 winningTile = 0;
        for (uint8 i = minTileId; i <= maxTileId; i++) {
            uint256 priceComplement = totalTileValue.sub(tileToPrice[i]);

            // update winner
            if (bestComplement == 0 || priceComplement > bestComplement) {
                bestComplement = priceComplement;
                winningTile = i;
            }

            complements[i] = priceComplement;
            totalPriceComplement = totalPriceComplement.add(priceComplement);
        }

        // distribute jackpot
        asyncSend(tileToOwner[winningTile], winnerJackpot);

        // distribute landholder things
        for (i = minTileId; i <= maxTileId; i++) {
            // NOTE: We don't exclude the jackpot winner here, so the winner is paid 'twice'
            uint256 landholderAllocation = complements[i].mul(landholderJackpot).div(totalPriceComplement);

            asyncSend(tileToOwner[i], landholderAllocation);
        }
    }

    function _distributeTax(uint256 tax) private {
        jackpot = jackpot.add(_jackpotTax(tax));

        _distributeLandholderTax(_totalLandholderTax(tax));
        _sendToTeam(_teamTax(tax));
        nextJackpot = nextJackpot.add(_nextPotTax(tax));
    }

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
